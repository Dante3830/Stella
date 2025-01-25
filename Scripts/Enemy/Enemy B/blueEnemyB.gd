extends CharacterBody2D

var Bullet = preload("res://Scenes/Enemy/Bullets/BlueEnemyBulletB.tscn")

@export var speed = 100  # Velocidad reducida para movimiento más controlado
@export var health = 1
@onready var spawnPos = $SpawnPos
@onready var player = get_tree().get_first_node_in_group("Player")

var Explosion = preload("res://Scenes/Explosion.tscn")

var can_fire = true

func _ready():
	$FireSpeed.start()

func _physics_process(delta):
	if player:
		# Calcular dirección hacia el jugador
		var direction_to_player = (player.global_position - global_position).normalized()
		
		# Mover suavemente hacia el jugador
		move_and_collide(direction_to_player * speed * delta)

func shoot():
	if can_fire and player:
		# Calcular ángulo hacia el jugador
		var angle_to_player = (player.global_position - global_position).angle()
		
		# Disparar balas con ángulos variables
		var spread_angles = [-0.5, 0, 0.5]
		for spread in spread_angles:
			var bullet_direction = Vector2.RIGHT.rotated(angle_to_player + spread)
			var bullet = Bullet.instantiate()
			bullet.position = spawnPos.global_position
			bullet.init(bullet_direction)
			get_tree().current_scene.add_child(bullet)
		
		can_fire = false
		$FireSpeed.start()

func _on_fire_speed_timeout():
	can_fire = true
	shoot()

func _on_screen_exited():
	queue_free()

func _on_collision_body_entered(body):
	if body.is_in_group("Player"):
		Manager.health -= 10
		queue_free()

func enemy_hit():
	health -= 1
	if health <= 0:
		Manager.camera.screen_shake(20.0, 0.3, 1.0)
		var explosion = Explosion.instantiate()
		explosion.global_position = global_position
		get_tree().current_scene.add_child(explosion)
		queue_free()

func reset():
	health = 1
