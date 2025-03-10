extends CPUParticles2D

func _ready():
	emitting = true
	$ExplosionCrunch000.play()

func _process(_delta):
	if !emitting:
		queue_free()
