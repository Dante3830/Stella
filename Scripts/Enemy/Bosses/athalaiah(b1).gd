extends CharacterBody2D

var descent_speed = 50.0
var phase = 1
var target_y_position = 100

@onready var explosion = preload("res://Scenes/Explosion.tscn")

@onready var red_bullet = preload("res://Scenes/Enemy/RedEnemyBullet.tscn")
@onready var blue_bullet = preload("res://Scenes/Enemy/BlueEnemyBullet.tscn")

@onready var warning = $WARNING/Warning
@onready var mothership = $WARNING/Mothership
@onready var shipName = $WARNING/Name
@onready var noRefuge = $WARNING/NoRefuge

@onready var left_wing = $"LEFT WING"
@onready var right_wing = $"RIGHT WING"
@onready var main_ship = $BASE

var times = 0
var all_text_visible = false

var can_fire = false
var player = null
var has_reached_position = false

# Salud para cada fase
@export var phase1_health = 150
@export var phase2_health = 100
@export var phase3_health = 50
var current_phase_health = 0

var travel = false
var startPos = 0
var distance = 300
var center_x = 539

@onready var leftWingSpawnPos1 = $"LEFT WING/SpawnPoint1"
@onready var leftWingSpawnPos2 = $"LEFT WING/SpawnPoint2"
@onready var leftWingSpawnPos3 = $"LEFT WING/SpawnPoint3"

@onready var rightWingSpawnPos1 = $"RIGHT WING/SpawnPoint4"
@onready var rightWingSpawnPos2 = $"RIGHT WING/SpawnPoint5"
@onready var rightWingSpawnPos3 = $"RIGHT WING/SpawnPoint6"

@onready var baseSpawnPos = $"BASE/SpawnPoint7"

@onready var leftWingCollisionShape = $"LEFT WING/LeftCollisionShape"
@onready var rightWingCollisionShape = $"RIGHT WING/RightCollisionShape"
@onready var baseCollisionShape = $BASE/BaseCollisionShape

var use_blue_bullet = true

func _ready():
	position = Vector2(539, -420)
	startPos = position.x
	
	warning.visible_ratio = 0
	mothership.visible_ratio = 0
	shipName.visible_ratio = 0
	noRefuge.visible_ratio = 0
	
	current_phase_health = phase1_health
	
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
		
		if warning.visible_ratio >= 1 and mothership.visible_ratio >= 1 and shipName.visible_ratio >= 1 and noRefuge.visible_ratio >= 1:
			all_text_visible = true
			$WARNING/VisibleTimer.start()

func _on_visible_timer_timeout():
	if $WARNING.visible == true:
		$WARNING.visible = false
	else:
		$WARNING.visible = true
	
	times += 1
	
	if times >= 10:
		$WARNING.visible = false
		$WARNING/VisibleTimer.stop()

func _on_fire_speed_timeout():
	can_fire = true

func handle_phase_behavior():
	match phase:
		1:
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
				spawn_wing_bullets(leftWingSpawnPos1, leftWingSpawnPos2, leftWingSpawnPos3, blue_bullet)
		2:
			if right_wing:
				spawn_wing_bullets(rightWingSpawnPos1, rightWingSpawnPos2, rightWingSpawnPos3, red_bullet)
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
			play_explosion_effect(left_wing.global_position)
		3:
			right_wing.queue_free()
			current_phase_health = phase3_health
			play_explosion_effect(right_wing.global_position)

func play_explosion_effect(pos):
	var Explosion = explosion.instantiate()
	Explosion.global_position = pos
	get_parent().add_child(Explosion)

func enemy_hit():
	print("Golpe")
	var damage = 1
	
	# Aplicar daño según el color y la fase
	match phase:
		1:  # Ala izquierda (azul)
			if Manager.is_red:
				damage = 2  # Más daño si el color coincide
		2:  # Ala derecha (roja)
			if not Manager.is_red:
				damage = 2  # Más daño si el color coincide
		3:  # Base (alterna entre rojo y azul)
			damage = 1  # Daño normal en fase final
	
	current_phase_health -= damage
	
	# Comprobar si pasamos a la siguiente fase o terminamos
	if current_phase_health <= 0:
		if phase < 3:
			transition_to_next_phase()
		else:
			Manager.score += 10000
			play_explosion_effect(global_position)
			get_tree().change_scene_to_file("res://Scenes/Victory.tscn")

func _on_left_wing_body_entered(body):
	if body.is_in_group("PlayerBullet"):
		enemy_hit()
	elif body.is_in_group("Player"):
		body.death()

func _on_right_wing_body_entered(body):
	if body.is_in_group("PlayerBullet"):
		enemy_hit()
	elif body.is_in_group("Player"):
		body.death()

func _on_base_body_entered(body):
	if body.is_in_group("PlayerBullet"):
		enemy_hit()
	elif body.is_in_group("Player"):
		body.death()
