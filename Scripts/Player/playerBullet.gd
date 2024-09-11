extends Area2D

@onready var blue_sprite = $BlueSprite
@onready var red_sprite = $RedSprite

@export var speed = 500

func _ready():
	update_bullet_color()

func _physics_process(delta):
	position.y -= delta * speed

func update_bullet_color():
	blue_sprite.visible = not Manager.is_red
	red_sprite.visible = Manager.is_red
