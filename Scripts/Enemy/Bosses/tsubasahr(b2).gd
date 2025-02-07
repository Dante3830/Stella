extends CharacterBody2D

var all_text_visible = false
var has_reached_position = false
var can_fire = false
var times = 0
var explosions_remaining = 30
var damage : int
var current_phase_health : int

@export var descent_speed = 100.0
var current_mill_angle = 0.0

enum Phase { INTRO, WING1, WING2, WING3, BASE }

var phase = Phase.INTRO
var health_stages = {
	Phase.WING1: {"left": 50, "right": 50},
	Phase.WING2: {"left": 75, "right": 75},
	Phase.WING3: {"left": 100, "right": 100},
	Phase.BASE: 200
}

@onready var healthBar = $"CanvasLayer/Boss Health/HealthBar"
@onready var explosion_scene = preload("res://Scenes/Explosion.tscn")

@onready var bullet_scenes = {
	"red_a": preload("res://Scenes/Enemy/Bullets/RedEnemyBulletA.tscn"),
	"blue_a": preload("res://Scenes/Enemy/Bullets/BlueEnemyBulletA.tscn"),
	"red_b": preload("res://Scenes/Enemy/Bullets/RedEnemyBulletB.tscn"),
	"blue_b": preload("res://Scenes/Enemy/Bullets/BlueEnemyBulletB.tscn")
}

@onready var baseCollisionShape = $BASE/BaseCollisionShape

func _ready():
	setup_initial_state()

func _on_fire_speed_timeout():
	can_fire = true

func _physics_process(delta):
	handle_descent(delta)
	handle_phase_behavior()
	handle_text_visibility(delta)
	update_health_display()
	
	if position.y > 408:
		has_reached_position = true
		can_fire = true
	
	if has_reached_position and can_fire:
		handle_phase_behavior()
		shoot_wing_pattern(phase)

func setup_initial_state():
	$CanvasLayer/WARNING.visible = true
	disable_wing_collision_shapes()
	initialize_text_visibility()

func disable_wing_collision_shapes():
	var collision_shapes = [
		$"LEFT WING 1/LeftCollisionShape", 
		$"RIGHT WING 1/RightCollisionShape", 
		$BASE/BaseCollisionShape
	]
	for shape in collision_shapes:
		shape.disabled = true

func initialize_text_visibility():
	var text_elements = [
		$CanvasLayer/WARNING/Warning,
		$CanvasLayer/WARNING/Mothership,
		$CanvasLayer/WARNING/Name,
		$CanvasLayer/WARNING/NoRefuge
	]
	for element in text_elements:
		element.visible_ratio = 0

func handle_descent(delta):
	if position.y < 408:
		move_and_collide(Vector2(0, descent_speed * delta))

func handle_phase_behavior():
	match phase:
		Phase.WING1:
			$"CanvasLayer/Boss Health".visible = true
			enable_wing_collision(1)
			shoot_wing_pattern(1)
		Phase.WING2:
			enable_wing_collision(2)
			shoot_wing_pattern(2)
		Phase.WING3:
			enable_wing_collision(3)
			shoot_wing_pattern(3)
		Phase.BASE:
			pass

func handle_text_visibility(delta):
	if not all_text_visible:
		var text_elements = [
			$CanvasLayer/WARNING/Warning,
			$CanvasLayer/WARNING/Mothership,
			$CanvasLayer/WARNING/Name,
			$CanvasLayer/WARNING/NoRefuge
		]
		
		for element in text_elements:
			element.visible_ratio += delta
		
		all_text_visible = text_elements.all(func(e): return e.visible_ratio >= 1)
		
		if all_text_visible:
			$CanvasLayer/WARNING/VisibleTimer.start()

func update_health_display():
	if healthBar:
		match phase:
			Phase.WING1, Phase.WING2, Phase.WING3:
				healthBar.max_value = health_stages[phase]["left"]
				healthBar.value = current_phase_health
			Phase.BASE:
				healthBar.max_value = health_stages[phase]
				healthBar.value = current_phase_health

func start_death_sequence():
	var shader_material = $BASE/Base.material as ShaderMaterial
	if shader_material:
		shader_material.set_shader_parameter("flicker_intensity", 1.0)
	
	Manager.score += 10000
	
	if is_instance_valid(baseCollisionShape):
		baseCollisionShape.set_deferred("disabled", true)
	
	$FireSpeed.stop()
	$ExplosionsTimer.start()
	$DestroyTimer.start()

func _on_explosions_timer_timeout():
	if explosions_remaining > 0:
		create_random_explosion()
		explosions_remaining -= 1
	else:
		cleanup_and_die()

func _on_destroy_timer_timeout():
	explosion_scene.instantiate()

func create_random_explosion():
	var Explosion = explosion_scene.instantiate()
	var random_x = randf_range(-500, 100)
	var random_y = randf_range(-300, 425)
	Explosion.global_position = global_position + Vector2(random_x, random_y)
	get_parent().add_child(Explosion)

func cleanup_and_die():
	$ExplosionsTimer.stop()
	queue_free()

func _on_visible_timer_timeout() -> void:
	$CanvasLayer/WARNING.visible = !$CanvasLayer/WARNING.visible
	times += 1
	
	if times >= 10:
		$CanvasLayer/WARNING.visible = false
		$CanvasLayer/WARNING/VisibleTimer.stop()

func enable_wing_collision(wing_number):
	var left_shape = get_node("LEFT WING %d/LeftCollisionShape" % wing_number)
	var right_shape = get_node("RIGHT WING %d/RightCollisionShape" % wing_number)
	left_shape.disabled = false if left_shape else false
	right_shape.disabled = false if right_shape else false

func shoot_wing_pattern(current_phase):
	var left_spawn = get_node("LEFT WING %d/SpawnPoint1" % current_phase)
	var right_spawn = get_node("RIGHT WING %d/SpawnPoint2" % current_phase)
	
	match current_phase:
		1:
			shoot_mill_pattern(left_spawn, bullet_scenes["blue_b"], true)
			shoot_mill_pattern(right_spawn, bullet_scenes["red_b"], false)
		2:
			shoot_arc_pattern(left_spawn, bullet_scenes["red_b"], true)
			shoot_arc_pattern(right_spawn, bullet_scenes["blue_b"], false)
		3:
			# Aquí puedes agregar un nuevo patrón de disparo para la fase 3
			pass
		4:
			# Comportamiento de la fase final
			pass

func shoot_mill_pattern(spawn_point, bullet_scene, is_left):
	var bullet_count = 4  # 4 aspas
	var base_angle = current_mill_angle
	
	for i in range(bullet_count):
		var angle = deg_to_rad(base_angle + (i * 90.0))
		var direction = Vector2(cos(angle), sin(angle))
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.position = spawn_point.global_position
		bullet_instance.init(direction)
		get_parent().add_child(bullet_instance)
	
	current_mill_angle += 22.5
	if current_mill_angle >= 360:
		current_mill_angle = 0

func shoot_arc_pattern(spawn_point, bullet_scene, is_left):
	var arc_angle = 45.0
	var base_angle = 90.0
	var random_angle = deg_to_rad(base_angle + randf_range(-arc_angle / 2, arc_angle / 2))
	var direction = Vector2(cos(random_angle), sin(random_angle))
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.position = spawn_point.global_position
	bullet_instance.set_direction(direction)
	get_parent().add_child(bullet_instance)

func update_health_bar(current_health):
	healthBar.value = current_health
	healthBar.max_value = health_stages[phase].get("left", health_stages[Phase.BASE])

func enemy_hit():
	match phase:
		Phase.WING1, Phase.WING2, Phase.WING3:
			damage = 2 if Manager.is_red else 1
			var available_sides = []
			if health_stages[phase]["left"] > 0:
				available_sides.append("left")
			if health_stages[phase]["right"] > 0:
				available_sides.append("right")
			
			if available_sides.size() > 0:
				var side = available_sides[randi() % available_sides.size()]
				health_stages[phase][side] -= damage
				current_phase_health = health_stages[phase][side]
				
				if health_stages[phase][side] <= 0:
					if side == "left":
						get_node("LEFT WING %d" % phase).queue_free()
					else:
						get_node("RIGHT WING %d" % phase).queue_free()
					
					check_phase_transition()
		
		Phase.BASE:
			damage = 1
			health_stages[phase] -= damage
			current_phase_health = health_stages[phase]
			
			if health_stages[phase] <= 0:
				start_death_sequence()

func check_phase_transition():
	if health_stages[phase]["left"] <= 0 and health_stages[phase]["right"] <= 0:
		advance_phase()

func advance_phase():
	phase += 1
	play_phase_transition_animation()

func play_phase_transition_animation():
	match phase:
		2:
			$LWAnimationPlayer.play("LeftWing1")
			$RWAnimationPlayer.play("RightWing1")
		3:
			$LWAnimationPlayer.play("LeftWing2")
			$RWAnimationPlayer.play("RightWing2")

# Colisiones (mantén las funciones de colisión como están)

# ALA IZQ 1 (FASE 1)
func _on_left_wing_0_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_left_wing_0_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA DER 1 (FASE 1)
func _on_right_wing_0_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_right_wing_0_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA IZQ 2 (FASE 2)
func _on_left_wing_1_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_left_wing_1_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA DER 2 (FASE 2)
func _on_right_wing_1_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_right_wing_1_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA IZQ 3 (FASE 3)
func _on_left_wing_2_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_left_wing_2_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA DER 3 (FASE 3)
func _on_right_wing_2_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_right_wing_2_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# BASE (FASE 4)
func _on_base_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_base_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()
