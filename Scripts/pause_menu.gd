extends Control

func _ready() -> void:
	$BoxContainer.visible = false
	$BoxContainer/OptionsContainer.visible = false

func resume():
	$BoxContainer.visible = false
	$AnimationPlayer.play("close")

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("open")

func _input(event: InputEvent):
	if event.is_action_pressed("Pause") and !get_tree().paused:
		pause()
	elif event.is_action_pressed("Pause") and get_tree().paused:
		resume()

func _on_resume_button_pressed():
	resume()

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "close":
		get_tree().paused = false
	elif anim_name == "open":
		$BoxContainer.visible = true

# MAIN
func _on_options_button_pressed():
	$BoxContainer/MainContainer.visible = false
	$BoxContainer/OptionsContainer.visible = true

# OPTIONS
func _on_game_button_pressed():
	$BoxContainer/OptionsContainer.visible = false
	$BoxContainer/GameOptContainer.visible = true

func _on_sound_button_pressed():
	$BoxContainer/SoundOptContainer.visible = true
	$BoxContainer/OptionsContainer.visible = false

func _on_back_button_pressed():
	$BoxContainer/MainContainer.visible = true
	$BoxContainer/OptionsContainer.visible = false

# GAME
func _on_game_opt_back_button_pressed():
	$BoxContainer/OptionsContainer.visible = true
	$BoxContainer/GameOptContainer.visible = false

# SOUND
func _on_sound_opt_back_button_pressed():
	$BoxContainer/SoundOptContainer.visible = false
	$BoxContainer/GameOptContainer.visible = true

# GRAPHICS


# CONTROLS
