extends CharacterBody2D

var all_text_visible = false
var has_reached_position = false
var can_fire = false
var use_blue_bullet = true
var times = 0
var explosions_remaining = 30
var damage : int
var current_phase_health : int
var current_phase_max_health : int
var current_mill_angle = 0.0

@export var shoot_interval = 1.0
var shoot_timer = 0.0

var phase = 0
# 0 = Intro
# 1 = Wings 1
# 2 = Wings 2
# 3 = Wings 3

@export var phase1_health = 50
@export var phase2_health = 75
@export var phase3_health = 100

@export var descent_speed = 100.0

@onready var healthBar = $"CanvasLayer/Boss Health/HealthBar"
@onready var explosion_scene = preload("res://Scenes/Explosion.tscn")

@onready var bullet_scenes = {
	"red_a": preload("res://Scenes/Enemy/Bullets/RedEnemyBulletA.tscn"),
	"blue_a": preload("res://Scenes/Enemy/Bullets/BlueEnemyBulletA.tscn"),
	"red_b": preload("res://Scenes/Enemy/Bullets/RedEnemyBulletB.tscn"),
	"blue_b": preload("res://Scenes/Enemy/Bullets/BlueEnemyBulletB.tscn")
}

var mill_shot_fired = false  # Nueva variable para controlar el disparo
var mill_wait_time = 0.5    # Tiempo de espera entre disparos en segundos
var mill_timer = 0.0        # Timer para controlar la espera

func _ready():
	setup_initial_state()

func _physics_process(delta):
	handle_descent(delta)
	handle_phase_behavior()
	handle_text_visibility(delta)
	update_health_display()
	
	if position.y > 408:
		phase = 1
		has_reached_position = true
		can_fire = true
	
	if has_reached_position and can_fire:
		handle_phase_behavior()
		shooting_phase_pattern(phase)
	
	if mill_timer > 0:
		mill_timer -= delta
	if mill_timer <= 0:
		mill_shot_fired = false
	
	#shoot_timer -= delta
	#if shoot_timer <= 0:
		#shoot_at_player()
		#shoot_timer = shoot_interval

func setup_initial_state():
	$CanvasLayer/WARNING.visible = true
	
	var text_elements = [
		$CanvasLayer/WARNING/Warning,
		$CanvasLayer/WARNING/Mothership,
		$CanvasLayer/WARNING/Name,
		$CanvasLayer/WARNING/NoRefuge
	]
	
	for element in text_elements:
		element.visible_ratio = 0
	
	current_phase_health = phase1_health
	current_phase_max_health = phase1_health
	healthBar.max_value = phase1_health
	healthBar.value = phase1_health

#func shoot_at_player():
	#var player_position = get_player_position()
	#var direction = (player_position - $BASE/SpawnPoint.global_position).normalized()
	#
	# Obtener el color actual de la bala
	#var current_color = "blue_a"
	#
	#var current_bullet_type = current_color[0]
	#
	# Crear la bala con el color actual
	#var bullet = bullet_scenes[current_color].instantiate()
	#bullet.position = $BASE/SpawnPoint.global_position
	#bullet.set_direction(direction)
	#bullet.set_color(current_color)  # Pasar el color a la bala
	#get_parent().add_child(bullet)
	#
	# Cambiar al siguiente color para el próximo disparo
	#current_bullet_type = "red_a" if current_bullet_type == "blue_a" else "blue_a"

func _on_fire_speed_timeout():
	can_fire = true

func handle_descent(delta):
	if position.y < 408:
		move_and_collide(Vector2(0, descent_speed * delta))

func handle_phase_behavior():
	match phase:
		1:
			$"CanvasLayer/Boss Health".visible = true
			enable_wing_collision(1)
			shooting_phase_pattern(1)
		2:
			enable_wing_collision(2)
			shooting_phase_pattern(2)
		3:
			enable_wing_collision(3)
			shooting_phase_pattern(3)

func handle_text_visibility(delta):
	if not all_text_visible:
		var text_elements = [
			$CanvasLayer/WARNING/Warning, $CanvasLayer/WARNING/Mothership,
			$CanvasLayer/WARNING/Name, $CanvasLayer/WARNING/NoRefuge
		]
		
		for element in text_elements:
			element.visible_ratio += delta
		
		all_text_visible = text_elements.all(func(e): return e.visible_ratio >= 1)
		
		if all_text_visible:
			$CanvasLayer/WARNING/VisibleTimer.start()

func update_health_display():
	if healthBar:
		match phase:
			1:
				healthBar.max_value = phase1_health
				healthBar.value = current_phase_health
			2:
				healthBar.max_value = phase2_health
				healthBar.value = current_phase_health
			3:
				healthBar.max_value = phase3_health
				healthBar.value = current_phase_health

func start_death_sequence():
	var shader_material = $BASE/Base.material as ShaderMaterial
	if shader_material:
		shader_material.set_shader_parameter("flicker_intensity", 1.0)
	
	Manager.score += 10000
	
	if is_instance_valid($BASE/BaseCollisionShape):
		$BASE/BaseCollisionShape.set_deferred("disabled", true)
	
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

func enable_wing_collision(current_phase: int):
	match current_phase:
		1:
			$"LEFT WING 1/LeftCollisionShape".disabled = false
			$"RIGHT WING 1/RightCollisionShape".disabled = false
		2:
			$"LEFT WING 2/LeftCollisionShape".disabled = false
			$"RIGHT WING 2/RightCollisionShape".disabled = false
		3:
			$"LEFT WING 3/LeftCollisionShape".disabled = false
			$"RIGHT WING 3/RightCollisionShape".disabled = false

func shooting_phase_pattern(current_phase: int) -> void:
	match current_phase:
		1:
			if $"LEFT WING 1" and $"RIGHT WING 1":
				#print("Disparando desde el ala izquierda")
				shoot_mill_pattern($"LEFT WING 1/SpawnPoint", bullet_scenes["blue_b"])
				shoot_mill_pattern($"RIGHT WING 1/SpawnPoint", bullet_scenes["red_b"])
				print("Posición del SpawnPoint izquierdo:", $"LEFT WING 1/SpawnPoint".global_position)
				print("Posición del SpawnPoint derecho:", $"RIGHT WING 1/SpawnPoint".global_position)
				#print("Disparando desde el ala derecha")
		2:
			if $"LEFT WING 2" and $"RIGHT WING 2":
				shoot_arc_pattern($"LEFT WING 2/SpawnPoint", bullet_scenes["red_b"])
				shoot_arc_pattern($"RIGHT WING 2/SpawnPoint", bullet_scenes["blue_b"])
		3:
			if $"LEFT WING 3" and $"RIGHT WING 3":
				shoot_superfire_pattern($"LEFT WING 3/SpawnPoint", bullet_scenes["blue_a"])
				shoot_superfire_pattern($"RIGHT WING 3/SpawnPoint", bullet_scenes["red_a"])
	
	$FireSpeed.start()
	can_fire = false

func shoot_mill_pattern(spawn_point, bullet_scene):
	if mill_shot_fired:
		return
	
	var bullet_count = 4  # 4 aspas
	
	var base_angle = current_mill_angle
	
	for i in range(bullet_count):
		var angle = deg_to_rad(base_angle + (i * 90.0))
		var direction = Vector2(cos(angle), sin(angle))
		
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.position = spawn_point.global_position
		
		if bullet_instance.has_method("init"):
			bullet_instance.init(direction)
		
		get_parent().add_child(bullet_instance)
		
		print("Bala creada en posición: ", bullet_instance.position)
		
		print("Bala instanciada correctamente: ", bullet_instance)
	
	current_mill_angle += 20
	if current_mill_angle >= 360:
		current_mill_angle = 0
	
	mill_shot_fired = true
	mill_timer = mill_wait_time

func shoot_arc_pattern(spawn_point, bullet_scene):
	var arc_angle = 45.0  # Ángulo total del arco en grados
	var base_angle = 90.0  # Dirección base (hacia abajo)
	
	# Generar un ángulo aleatorio dentro del arco
	var random_angle = deg_to_rad(base_angle + randf_range(-arc_angle / 2, arc_angle / 2))
	
	# Calcular la dirección basada en el ángulo aleatorio
	var direction = Vector2(cos(random_angle), sin(random_angle))
	
	# Crear la bala
	var bullet_instance = bullet_scene.instantiate()
	bullet_instance.position = spawn_point.global_position
	
	# Asignar la dirección a la bala
	if bullet_instance.has_method("set_direction"):
		bullet_instance.set_direction(direction)
	
	# Añadir la bala a la escena
	get_parent().add_child(bullet_instance)

func shoot_superfire_pattern(spawn_point, bullet_scene):
	pass

func destroy_wing(side):
	var wing_node = get_node("%s WING %d" % [side.to_upper(), phase])
	var explosion = explosion_scene
	explosion.instantiate(wing_node.global_position)
	wing_node.queue_free()

func enemy_hit():
	print("Jefe golpeado! Salud actual: ", current_phase_health)
	match phase:
		1:
			if Manager.is_red:
				damage = 2
			else:
				damage = 1
			
			phase1_health -= damage
			current_phase_health = phase1_health
		2:
			if !Manager.is_red:
				damage = 2
			else:
				damage = 1
			
			phase2_health -= damage
			current_phase_health = phase2_health
		3:
			if Manager.is_red:
				damage = 2
			else:
				damage = 1
			
			phase3_health -= damage
			current_phase_health = phase3_health
			
			if phase3_health <= 0:
				start_death_sequence()
	
	if healthBar:
		healthBar.value = current_phase_health
		print("Salud actualizada en la barra: ", healthBar.value)

func choose_wing_to_damage(wing_health):
	var available_sides = []
	if wing_health["left"] > 0:
		available_sides.append("left")
	if wing_health["right"] > 0:
		available_sides.append("right")
	
	if available_sides.size() > 0:
		return available_sides[randi() % available_sides.size()]
	else:
		return null  # No hay alas disponibles para dañar

func check_phase_transition():
	match phase:
		1:
			phase = 2
			current_phase_health = phase2_health
			current_phase_max_health = phase2_health
			healthBar.max_value = phase2_health
			healthBar.value = phase2_health
			$LWAnimationPlayer.play("LeftWing2")
			$RWAnimationPlayer.play("RightWing2")
			play_phase_transition_effects()
		2:
			phase = 3
			current_phase_health = phase3_health
			current_phase_max_health = phase3_health
			healthBar.max_value = phase3_health
			healthBar.value = phase3_health
			$LWAnimationPlayer.play("LeftWing3")
			$RWAnimationPlayer.play("RightWing3")
			play_phase_transition_effects()

func play_phase_transition_effects():
	# Aquí puedes agregar efectos visuales/sonoros para la transición
	# Por ejemplo, explosiones, partículas, sonidos, etc.
	var transition_explosion = explosion_scene.instantiate()
	transition_explosion.global_position = global_position
	get_parent().add_child(transition_explosion)

# ALA IZQ 1 (FASE 1)
func _on_left_wing_1_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_left_wing_1_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA DER 1 (FASE 1)
func _on_right_wing_1_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_right_wing_1_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA IZQ 2 (FASE 2)
func _on_left_wing_2_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_left_wing_2_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA DER 2 (FASE 2)
func _on_right_wing_2_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_right_wing_2_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA IZQ 3 (FASE 3)
func _on_left_wing_3_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_left_wing_3_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA DER 3 (FASE 3)
func _on_right_wing_3_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_right_wing_3_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# BASE
func _on_base_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

func get_player_position():
	var player_node = get_tree().get_nodes_in_group("Player")
	if player_node.size() > 0:
		return player_node[0].global_position
	else:
		return #pass
