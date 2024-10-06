extends Camera2D

var start_shake = false
var shake_intensity : float = 0
var shake_dampening : float = 0

@onready var shake_time = $ShakeTime

func _ready():
	Manager.camera = self

func _process(_delta):
	if start_shake:
		offset.x = randf_range(-1, 1) * shake_intensity
		offset.y = randf_range(-1, 1) * shake_intensity
		shake_intensity = lerp(shake_intensity, 0.0, shake_dampening)
		if shake_intensity < 0.3:
			start_shake = false
	else:
		offset = Vector2.ZERO

func screen_shake(intensity, duration, dampening):
	shake_intensity = intensity
	shake_time.wait_time = duration
	shake_dampening = dampening
	start_shake = true
	shake_time.start()

func _on_shake_time_timeout():
	start_shake = false
