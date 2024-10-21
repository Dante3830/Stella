extends CharacterBody2D

var SPEED = 300.0

@onready var warning = $WARNING/Warning
@onready var mothership = $WARNING/Mothership
@onready var shipName = $WARNING/Name
@onready var noRefuge = $WARNING/NoRefuge

var times = 0
var allTextVisible = false

func _ready():
	warning.visible_ratio = 0
	mothership.visible_ratio = 0
	shipName.visible_ratio = 0
	noRefuge.visible_ratio = 0
	position = Vector2(539, -420)

func _physics_process(delta):
	move_and_slide()

func _process(delta):
	if not allTextVisible:
		warning.visible_ratio += delta
		mothership.visible_ratio += delta
		shipName.visible_ratio += delta
		noRefuge.visible_ratio += delta
		
		if warning.visible_ratio >= 1 and mothership.visible_ratio >= 1 and shipName.visible_ratio >= 1 and noRefuge.visible_ratio >= 1:
			allTextVisible = true
			$WARNING/VisibleTimer.start()

func _on_visible_timer_timeout():
	if $WARNING.visible == true:
		$WARNING.visible = false
	else:
		$WARNING.visible = true
	
	times += 1
	
	if times >= 10:
		$WARNING.visible = false
		$WARNING/VisibleTimer.stop()
