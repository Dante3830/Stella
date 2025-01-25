extends CharacterBody2D

# Balas azules
var Bullet = preload("res://Scenes/Enemy/Bullets/BlueEnemyBulletA.tscn")

@export var speed = 200
@export var health = 1
@onready var spawnPos = $SpawnPos

var Explosion = preload("res://Scenes/Explosion.tscn")

var can_fire = true

signal defeated

# Iniciar el temporizador de disparo cuando el enemigo se crea
func _ready():
	$FireSpeed.start()

func _physics_process(delta):
	var movement = Vector2(0, speed)
	move_and_collide(movement * delta)

func shoot():
	if can_fire:
		var directions = [
			Vector2(-0.5, 1).normalized(),  # Diagonal izquierda
			Vector2.DOWN,                   # Recto
			Vector2(0.5, 1).normalized()    # Diagonal derecha
		]
		
		for dir in directions:
			var bullet = Bullet.instantiate()
			bullet.position = spawnPos.global_position
			bullet.init(dir)
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
		emit_signal("defeated")
		Manager.camera.screen_shake(20.0, 0.3, 1.0)
		var explosion = Explosion.instantiate()
		explosion.global_position = global_position
		get_tree().current_scene.add_child(explosion)
		queue_free()

# Llama a esto cuando recuperes el enemigo de la pool
func reset():
	health = 1
