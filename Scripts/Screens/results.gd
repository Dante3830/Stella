extends Control

@onready var score_text = $RESULTS/ScoreDP
@onready var enemies_text = $RESULTS/EnemiesDownDP
@onready var time_text = $RESULTS/TimeDP
@onready var rank_text = $RESULTS/RankDP

func _process(_delta):
	score_text.text = str(Manager.score)
	enemies_text.text = str(Manager.enemies_down)
	time_text.text = str(Manager.time)
	
	#rank_text.text

func _on_restart_level_button_pressed() -> void:
	pass # Replace with function body.

func _on_restart_game_button_pressed() -> void:
	pass # Replace with function body.

func _on_menu_button_pressed() -> void:
	pass # Replace with function body.
