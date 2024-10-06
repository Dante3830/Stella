extends Node2D

@onready var sprite2 = $Sprite2D2
@onready var sprite3 = $Sprite2D3

@export var speed1 = 75
@export var speed2 = 100

func _process(delta):
	sprite2.position.y += speed1 * delta
	sprite3.position.y += speed2 * delta
	
	if sprite2.position.y >= 5276:
		sprite2.position.y = 1425
	
	if sprite3.position.y >= 5262:
		sprite3.position.y = 1411
