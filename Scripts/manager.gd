extends Node

var health = 100
var lives = 5
var score = 0
var power = 0

var enemies_down = 0
var time = 0

var is_red = true

func _ready():
	pass

func _process(delta):
	time += 1 * delta
