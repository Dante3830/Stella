# AZUL (blueEnemyD.gd)
extends CharacterBody2D

@export var speed = 200
@export var health = 1
@onready var spawnPos = $SpawnPos

var Bullet = preload("res://Scenes/Enemy/BlueEnemyBullet.tscn")
var Explosion = preload("res://Scenes/Explosion.tscn")

var can_fire = true
var directions = [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]

func _ready():
	$FireSpeed.start()

func _physics_process(delta):
	var movement = Vector2(0, 0)
	move_and_collide(movement * delta)

func shoot():
	if can_fire:
		# Disparar en las cuatro direcciones
		for direction in directions:
			var bullet = Bullet.instantiate()
			bullet.position = spawnPos.global_position
			bullet.init(direction)  # Establecer la dirección de la bala
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
		Manager.score += 100
		var explosion = Explosion.instantiate()
		explosion.global_position = global_position
		get_tree().current_scene.add_child(explosion)
		queue_free()
