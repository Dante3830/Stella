# AZUL
extends Area2D

@export var speed = 500

func _physics_process(delta):
	position.y += delta * speed

func _on_body_entered(body):
	if body.name == "Player":
		if Manager.is_red:
			Manager.health -= randi_range(5, 10)
			queue_free()
		else:
			Manager.power += 5

func _on_destroy_timer_timeout():
	queue_free()
