extends Area2D

@export var speed = 500

func _physics_process(delta):
	position.y -= delta * speed

func _process(_delta):
	pass
