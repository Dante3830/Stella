extends CharacterBody2D

@export var speed = 400
@export var acceleration = 1500
@export var friction = 1200

@onready var axis = Vector2.ZERO
@onready var blue_sprite = $BlueSprite
@onready var red_sprite = $RedSprite
@onready var spawnPos = $SpawnPos
@onready var muzzleFlash = $MuzzleFlash

var PlayerBullet = preload("res://Scenes/Player/PlayerBullet.tscn")
var Explosion = preload("res://Scenes/Explosion.tscn")

var can_fire = true
var can_change = true

# Nuevas variables para los límites de la pantalla
var screen_size
var half_width
var half_height

func _ready():
	update_sprite_visibility()
	# Obtener el tamaño de la pantalla y calcular los límites
	screen_size = get_viewport_rect().size
	half_width = blue_sprite.texture.get_width() / 2
	half_height = blue_sprite.texture.get_height() / 2

func _physics_process(delta):
	move(delta)
	
	if Manager.health <= 0:
		death()

func get_input_axis():
	axis.x = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
	axis.y = int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))
	return axis.normalized()

func move(delta):
	axis = get_input_axis()
	
	if axis == Vector2.ZERO:
		apply_friction(friction * delta)
	else:
		apply_movement(axis * acceleration * delta)
	
	move_and_slide()
	
	# Limitar la posición del jugador dentro de la pantalla
	global_position.x = clamp(global_position.x, half_width, screen_size.x - half_width)
	global_position.y = clamp(global_position.y, half_height, screen_size.y - half_height)

func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO

func apply_movement(accel):
	velocity += accel
	velocity = velocity.limit_length(speed)

func _process(_delta):
	# Disparo normal
	if Input.is_action_pressed("Fire") and can_fire:
		shoot()
	
	# Super disparo
	if Input.is_action_pressed("SuperFire") and Manager.power == 100 and can_fire:
		supershoot()
	
	# Cambiar color
	if Input.is_action_just_pressed("Change") and can_change:
		change_color()

func shoot():
	var bullet = PlayerBullet.instantiate()
	bullet.position = spawnPos.global_position
	get_tree().current_scene.add_child(bullet)
	
	if Manager.is_red:
		muzzleFlash.play("RedMuzzleflash")
	else:
		muzzleFlash.play("BlueMuzzleflash")
	
	$FireSpeed.start()
	can_fire = false

func supershoot():
	Manager.power = 0
	can_change = false
	$SuperFire.visible = true
	$SuperFire/CollisionPolygon2D.disabled = false
	$SuperFire/SuperFireTime.start()
	
	if Manager.is_red:
		$SuperFire/SuperRed.visible = true
		$SuperFire/SuperBlue.visible = false
	elif !Manager.is_red:
		$SuperFire/SuperRed.visible = false
		$SuperFire/SuperBlue.visible = true

func change_color():
	Manager.is_red = not Manager.is_red
	update_sprite_visibility()

func update_sprite_visibility():
	blue_sprite.visible = not Manager.is_red
	red_sprite.visible = Manager.is_red

func _on_fire_speed_timeout():
	can_fire = true

func _on_super_fire_body_entered(body):
	if body.is_in_group("Enemy"):
		body.enemy_hit()
		Manager.score += 100
	elif body.is_in_group("Boss"):
		body.take_damage()
		Manager.score += 100

func _on_super_fire_time_timeout():
	$SuperFire.visible = false
	$SuperFire/CollisionPolygon2D.disabled = true
	can_change = true

func death():
	var explosion = Explosion.instantiate()
	explosion.global_position = global_position
	get_tree().current_scene.add_child(explosion)
	Manager.camera.screen_shake(5.0, 0.1, 0.5)
	queue_free()
