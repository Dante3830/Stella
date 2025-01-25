extends CharacterBody2D

var Bullet = preload("res://Scenes/Enemy/Bullets/BlueEnemyBulletA.tscn")

@export var speed = 200
@export var health = 1
@export var target_position = Vector2.ZERO  # Posición objetivo antes de detenerse
@onready var spawnPos = $SpawnPos

var Explosion = preload("res://Scenes/Explosion.tscn")

var can_fire = true
var player = null
var is_positioned = false

func _ready():
	$FireSpeed.start()

func _physics_process(delta):
	if not is_positioned:
		# Moverse a la posición objetivo
		var movement = position.direction_to(target_position) * speed
		if position.distance_to(target_position) > 10:
			move_and_collide(movement * delta)
		else:
			is_positioned = true
	
	if is_positioned and player:
		# Disparar apuntando al jugador
		shoot_at_player()

func shoot_at_player():
	if can_fire:
		var direction_to_player = (player.position - position).normalized()
		var bullet = Bullet.instantiate()
		bullet.position = spawnPos.global_position
		bullet.init(direction_to_player)
		get_tree().current_scene.add_child(bullet)
		
		can_fire = false
		$FireSpeed.start()

func _on_fire_speed_timeout():
	can_fire = true
	shoot_at_player() if is_positioned and player else null

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

func _on_detection_body_entered(body):
	if body.name == "Player":
		player = body
