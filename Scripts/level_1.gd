extends Node

var BlueEnemy = preload("res://Scenes/Enemy/BlueEnemy.tscn")
var RedEnemy = preload("res://Scenes/Enemy/RedEnemy.tscn")

func _on_spawn_timer_timeout():
	var b_enemy = BlueEnemy.instantiate()
	var r_enemy = RedEnemy.instantiate()
	
	b_enemy.position = Vector2(randi_range(55, 1025), -56)
	r_enemy.position = Vector2(randi_range(55, 1025), -56)
	
	add_child(b_enemy)
	add_child(r_enemy)
