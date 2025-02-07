extends Node

var health = 100
var lives = 4
var score = 0
var power = 0

var enemies_down = 0

var time = 0
var minutes : int
var seconds : float

var is_red = true

var camera = null

var level = 1

func _process(delta):
	time += delta
	minutes = int(time / 60)
	seconds = fmod(time, 60.0)
	
	if power >= 100:
		power = 100

func init_data():
	time = 0
	enemies_down = 0
	lives = 4
	power = 0
	health = 100
	score = 0

func format_time() -> String:
	return "%02d:%05.2f" % [minutes, seconds]
