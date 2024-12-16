extends Control

@onready var score_text = $RESULTS/ScoreDP
@onready var enemies_text = $RESULTS/EnemiesDownDP
@onready var time_text = $RESULTS/TimeDP
@onready var rank_text = $RESULTS/RankDP

func _process(_delta):
	score_text.text = str(Manager.score)
	enemies_text.text = str(Manager.enemies_down)
	time_text.text = Manager.format_time()
	
	if Manager.level == 1:
		#if Manager.score == 10000:
		#	if Manager.enemies_down == 30:
		#		if Manager.time == 
		#		rank_text = "A"
		#		rank_text = "B"
		#		rank_text = "C"
		#		rank_text = "D"
		#	
		pass

func _on_restart_level_button_pressed() -> void:
	pass # Replace with function body.

func _on_menu_button_pressed() -> void:
	pass # Replace with function body.
