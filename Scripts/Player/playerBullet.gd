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

func _on_destroy_timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		body.enemy_hit()
		Manager.score += 100
		Manager.enemies_down += 1
		queue_free()
	elif body.is_in_group("Boss"):
		body.enemy_hit()
		Manager.score += 100
		queue_free()
