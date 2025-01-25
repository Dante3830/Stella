extends CharacterBody2D

var Bullet = preload("res://Scenes/Enemy/Bullets/RedEnemyBulletA.tscn")

@export var speed = 100  # Velocidad de movimiento lateral
@export var health = 1
@onready var spawnPos = $SpawnPos

var Explosion = preload("res://Scenes/Explosion.tscn")

var can_fire = true
var move_direction = 1  # 1 para derecha, -1 para izquierda
var screen_edge_reached = false

func _ready():
	$FireSpeed.start()

func _physics_process(delta):
	# Movimiento lateral estilo Space Invaders
	var movement = Vector2(speed * move_direction, 0)
	move_and_collide(movement * delta)
	
	# Cambiar dirección al tocar el borde
	if screen_edge_reached:
		position.y += 50  # Bajar una fila
		move_direction *= -1
		screen_edge_reached = false

func shoot():
	if can_fire:
		var directions = [Vector2.DOWN, Vector2(-1, 1), Vector2(1, 1)]
		for direction in directions:
			var bullet = Bullet.instantiate()
			bullet.position = spawnPos.global_position
			bullet.init(direction)
			get_tree().current_scene.add_child(bullet)
		
		can_fire = false
		$FireSpeed.start()

func _on_fire_speed_timeout():
	can_fire = true
	shoot()

func _on_screen_exited():
	print("Enemigo fuera")
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

func _on_screen_edge_detected():
	screen_edge_reached = true
