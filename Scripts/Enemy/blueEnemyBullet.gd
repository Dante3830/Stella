# AZUL
extends Area2D

@export var speed = 500
var direction = Vector2.DOWN  # Vector de dirección por defecto (0, 1)

func init(new_direction: Vector2):
	direction = new_direction.normalized()  # Normalizamos el vector para mantener velocidad constante
	rotation = direction.angle() + PI/2  # Rotamos el sprite (PI/2 es 90 grados)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.name == "Player":
		if Manager.is_red:
			Manager.health -= randi_range(5, 10)
			queue_free()
		else:
			Manager.power += 5
			queue_free()

func _on_destroy_timer_timeout():
	queue_free()
