extends CharacterBody2D

@export var speed = 400
@export var acceleration = 1500
@export var friction = 1200

@onready var axis = Vector2.ZERO

@onready var blue_sprite = $BlueSprite
@onready var red_sprite = $RedSprite

var playerBullet = preload("res://Scenes/Player/PlayerBullet.tscn")
var can_fire = true

@onready var spawnPos = $SpawnPos

@onready var muzzleFlash = $MuzzleFlash

func _ready():
	update_sprite_visibility()

func _physics_process(delta):
	move(delta)

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

func apply_friction(amount):
	if velocity.length() > amount:
		velocity -= velocity.normalized() * amount
	else:
		velocity = Vector2.ZERO

func apply_movement(accel):
	velocity += accel
	velocity = velocity.limit_length(speed)

func _process(_delta):
	if Input.is_action_pressed("Fire") and can_fire:
		shoot()
	
	if Input.is_action_just_pressed("Change"):
		change_color()

func shoot():
	var bullet = playerBullet.instantiate()
	bullet.position = spawnPos.global_position
	get_tree().current_scene.add_child(bullet)
	
	if Manager.is_red:
		muzzleFlash.play("RedMuzzleflash")
	else:
		muzzleFlash.play("BlueMuzzleflash")
	
	$FireSpeed.start()
	can_fire = false

func change_color():
	Manager.is_red = not Manager.is_red
	update_sprite_visibility()

func update_sprite_visibility():
	blue_sprite.visible = not Manager.is_red
	red_sprite.visible = Manager.is_red

func player_hit():
	Manager.health -= 1
	if Manager.health <= 0:
		queue_free()
		print("MORISTE")

func _on_fire_speed_timeout():
	can_fire = true
