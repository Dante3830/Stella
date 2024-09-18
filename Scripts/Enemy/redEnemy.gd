extends CharacterBody2D

@export var speed = 200
@onready var spawnPos = $SpawnPos

var Bullet = preload("res://Scenes/Enemy/RedEnemyBullet.tscn")

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
		get_tree().current_scene.add_child(bullet)
		
		can_fire = false
		$FireSpeed.start()

func _on_fire_speed_timeout():
	can_fire = true
	shoot()

# Nueva función para manejar cuando el enemigo sale de la pantalla
func _on_screen_exited():
	print("Enemigo fuera")
	queue_free()
