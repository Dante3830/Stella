extends CharacterBody2D

@export var speed = 200
@export var health = 1
@onready var spawnPos = $SpawnPos

var Bullet = preload("res://Scenes/Enemy/BlueEnemyBullet.tscn")
var Explosion = preload("res://Scenes/Explosion.tscn")

var can_fire = true

func _ready():
	# Iniciar el temporizador de disparo cuando el enemigo se crea
	$FireSpeed.start()

func _physics_process(delta):
	var movement = Vector2(0, speed)
	move_and_collide(movement * delta)

func shoot():
	if can_fire:
		var bullet = Bullet.instantiate()
		bullet.position = spawnPos.global_position
		bullet.init(Vector2.DOWN)
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