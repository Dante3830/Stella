extends CharacterBody2D

@onready var descent_speed = 50.0
var phase = 1
var target_y_position = 200

@onready var explosion = preload("res://Scenes/Explosion.tscn")

@onready var red_bullet = preload("res://Scenes/Enemy/Bullets/RedEnemyBulletA.tscn")
@onready var blue_bullet = preload("res://Scenes/Enemy/Bullets/BlueEnemyBulletA.tscn")

@onready var warning = $CanvasLayer/WARNING/Warning
@onready var mothership = $CanvasLayer/WARNING/Mothership
@onready var shipName = $CanvasLayer/WARNING/Name
@onready var noRefuge = $CanvasLayer/WARNING/NoRefuge

var times = 0
var all_text_visible = false

var can_fire = false
var player = null
var has_reached_position = false

# Salud para cada fase
@export var phase1_health = 50
@export var phase2_health = 75
@export var phase3_health = 150
var current_phase_health = 0
var current_phase_max_health = 0

var travel = false
var startPos = 0
var distance = 300
var center_x = 539

@onready var left_wing = $"LEFT WING"
@onready var leftWingSpawnPos1 = $"LEFT WING/SpawnPoint1"
@onready var leftWingSpawnPos2 = $"LEFT WING/SpawnPoint2"
@onready var leftWingSpawnPos3 = $"LEFT WING/SpawnPoint3"

@onready var right_wing = $"RIGHT WING"
@onready var rightWingSpawnPos1 = $"RIGHT WING/SpawnPoint4"
@onready var rightWingSpawnPos2 = $"RIGHT WING/SpawnPoint5"
@onready var rightWingSpawnPos3 = $"RIGHT WING/SpawnPoint6"

@onready var baseSpawnPos = $"BASE/SpawnPoint7"

@onready var leftWingCollisionShape = $"LEFT WING/LeftCollisionShape"
@onready var rightWingCollisionShape = $"RIGHT WING/RightCollisionShape"
@onready var baseCollisionShape = $BASE/BaseCollisionShape

var use_blue_bullet = true

@onready var healthBar = $"CanvasLayer/Boss Health/HealthBar"

var explosions_remaining = 30
@onready var explosions_timer = $ExplosionsTimer

func _ready():
	$CanvasLayer/WARNING.visible = true
	
	position = Vector2(539, -420)
	startPos = position.x
	
	warning.visible_ratio = 0
	mothership.visible_ratio = 0
	shipName.visible_ratio = 0
	noRefuge.visible_ratio = 0
	
	current_phase_health = phase1_health
	current_phase_max_health = phase1_health 
	
	leftWingCollisionShape.disabled = true
	rightWingCollisionShape.disabled = true
	baseCollisionShape.disabled = true

func _physics_process(delta):
	var movement = Vector2.ZERO
	
	if not has_reached_position and position.y < target_y_position:
		movement = Vector2(0, descent_speed * delta)
	elif position.y >= target_y_position and not has_reached_position:
		has_reached_position = true
		player = true
	
	if player and has_reached_position:
		handle_phase_behavior()
		if can_fire:
			shoot()
	
	move_and_collide(movement)

func _process(delta):
	if not all_text_visible:
		warning.visible_ratio += delta
		mothership.visible_ratio += delta
		shipName.visible_ratio += delta
		noRefuge.visible_ratio += delta
		
		if (warning.visible_ratio >= 1 and mothership.visible_ratio >= 1 
			and shipName.visible_ratio >= 1 and noRefuge.visible_ratio >= 1):
			all_text_visible = true
			$CanvasLayer/WARNING/VisibleTimer.start()
	
	healthBar.max_value = current_phase_max_health
	healthBar.value = current_phase_health

func _on_visible_timer_timeout():
	if $CanvasLayer/WARNING.visible == true:
		$CanvasLayer/WARNING.visible = false
	else:
		$CanvasLayer/WARNING.visible = true
	
	times += 1
	
	if times >= 10:
		$CanvasLayer/WARNING.visible = false
		$CanvasLayer/WARNING/VisibleTimer.stop()

func _on_fire_speed_timeout():
	can_fire = true

func handle_phase_behavior():
	match phase:
		1:
			$"CanvasLayer/Boss Health".visible = true
			leftWingCollisionShape.disabled = false
			if position.x < startPos + distance:
				right()
		2:
			rightWingCollisionShape.disabled = false
			if position.x > startPos - distance:
				left()
		3:
			baseCollisionShape.disabled = false
			var target_x = center_x
			if position.x < target_x - 5:
				right()
			elif position.x > target_x + 5:
				left()

func shoot():
	match phase:
		1:
			if left_wing:
				spawn_wing_bullets(leftWingSpawnPos1, leftWingSpawnPos2, 
									leftWingSpawnPos3, blue_bullet)
		2:
			if right_wing:
				spawn_wing_bullets(rightWingSpawnPos1, rightWingSpawnPos2, 
									rightWingSpawnPos3, red_bullet)
		3:
			spawn_center_bullet(baseSpawnPos, blue_bullet if use_blue_bullet else red_bullet)
			use_blue_bullet = !use_blue_bullet
	
	$FireSpeed.start()
	can_fire = false

func spawn_wing_bullets(pos1, pos2, pos3, bullet_type):
	var positions = [pos1, pos2, pos3]
	for spawn_pos in positions:
		var bullet = bullet_type.instantiate()
		bullet.position = spawn_pos.global_position
		get_parent().add_child(bullet)

func spawn_center_bullet(pos, bullet_type):
	var bullet = bullet_type.instantiate()
	bullet.position = pos.global_position
	get_parent().add_child(bullet)

func left():
	position.x -= 2

func right():
	position.x += 2

func transition_to_next_phase():
	phase += 1
	match phase:
		2:
			left_wing.queue_free()
			current_phase_health = phase2_health
			current_phase_max_health = phase2_health
			play_explosion_effect(left_wing.global_position)
		3:
			right_wing.queue_free()
			current_phase_health = phase3_health
			current_phase_max_health = phase3_health
			play_explosion_effect(right_wing.global_position)

func play_explosion_effect(pos):
	var Explosion = explosion.instantiate()
	Explosion.global_position = pos
	get_parent().add_child(Explosion)

func _on_left_wing_body_entered(body):
	if body.is_in_group("Player"):
		body.death()
	
	while body.is_in_group("SuperFire"):
		current_phase_health -= 10

func _on_right_wing_body_entered(body):
	if body.is_in_group("Player"):
		body.death()

func _on_base_body_entered(body):
	if body.is_in_group("Player"):
		body.death()

func _on_base_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_left_wing_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_right_wing_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func spawn_multiple_explosions():
	var explosion_count = 5
	var explosion_duration = 3.0
	var timer = Timer.new()
	timer.wait_time = explosion_duration
	timer.one_shot = true
	add_child(timer)
	
	for i in range(explosion_count):
		var Explosion = explosion.instantiate()
		Explosion.global_position = global_position + Vector2(
			randf_range(-50, 50), 
			randf_range(-50, 50)
		)
		get_parent().add_child(Explosion)
		
		# Crear un tween para mover la explosión
		var tween = create_tween()
		tween.tween_property(Explosion, "global_position", 
			global_position + Vector2( randf_range(-100, 100), randf_range(-100, 100)
			), 
			explosion_duration
		)
	
	timer.timeout.connect(func():queue_free())
	timer.start()

func enemy_hit():
	var damage = 1
	
	match phase:
		1:  # Ala izquierda (azul)
			print("Golpe izquierda")
			if Manager.is_red:
				damage = 2
		2:  # Ala derecha (roja)
			print("Golpe derecha")
			if not Manager.is_red:
				damage = 2
		3:  # Base (alterna entre rojo y azul)
			print("Golpe base")
			damage = 1
	
	current_phase_health -= damage
	
	if current_phase_health <= 0:
		if phase < 3:
			transition_to_next_phase()
		elif phase == 3:
			start_death_sequence()

func start_death_sequence():
	var shader_material = $BASE/Base.material as ShaderMaterial
	if shader_material:
		shader_material.set_shader_parameter("flicker_intensity", 1.0)
	
	Manager.score += 10000
	
	# En lugar de queue_free(), intentamos desactivarlo
	if is_instance_valid(baseCollisionShape):
		baseCollisionShape.set_deferred("disabled", true)
	else:
		print("baseCollisionShape no es válido")
	
	can_fire = false
	$FireSpeed.stop()
	
	# Crear y configurar el timer
	explosions_timer.start()
	
	$DestroyTimer.start()

func _on_explosions_timer_timeout():
	if explosions_remaining > 0:
		create_random_explosion()
		explosions_remaining -= 1
	else:
		cleanup_and_die()

func create_random_explosion():
	var Explosion = explosion.instantiate()
	var random_x = randf_range(-500, 100)
	var random_y = randf_range(-300, 425)
	Explosion.global_position = global_position + Vector2(random_x, random_y)
	get_parent().add_child(Explosion)

func cleanup_and_die():
	if explosions_timer:
		explosions_timer.stop()
	queue_free()

func force_death():
	print("Boss force death triggered")
	cleanup_and_die()
