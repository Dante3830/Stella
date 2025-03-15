extends CPUParticles2D

func _ready():
	emitting = true
	$ExplosionSound.play()

func _process(_delta):
	if !emitting:
		queue_free()
