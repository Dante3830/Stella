extends Node

var BlueEnemyA = preload("res://Scenes/Enemy/Enemy A/BlueEnemyA.tscn")
var RedEnemyA = preload("res://Scenes/Enemy/Enemy A/RedEnemyA.tscn")

var BlueEnemyB = preload("res://Scenes/Enemy/Enemy B/BlueEnemyB.tscn")
var RedEnemyB = preload("res://Scenes/Enemy/Enemy B/RedEnemyB.tscn")

var current_wave = 0

var Player = preload("res://Scenes/Player/Player.tscn")
var player = null

func _ready():
	$Comentarios.visible = false
	spawn_player()
	#if level_data:
		#start_waves()

func _physics_process(_delta):
	if player == null and $PlayerRespawn.is_stopped():
		$PlayerRespawn.start()

func spawn_player():
	player = Player.instantiate()
	player.position = Vector2(535, 1097)
	get_node("Characters").add_child(player)

func _on_spawn_timer_timeout():
	var b_enemy_a = BlueEnemyA.instantiate()
	var r_enemy_a = RedEnemyA.instantiate()
	
	b_enemy_a.position = Vector2(randi_range(55, 1025), -56)
	r_enemy_a.position = Vector2(randi_range(55, 1025), -56)
	
	get_node("Characters").add_child(b_enemy_a)
	get_node("Characters").add_child(r_enemy_a)

func _on_player_respawn_timeout():
	if Manager.lives > 0:
		# Conectamos la señal de muerte del jugador
		player.connect("player_died", Callable(self, "_on_player_died"))
		Manager.health = 100
		Manager.power = 0
		Manager.lives -= 1
		spawn_player()
		print("Jugador respawneado")
	else:
		print("Game Over - Sin vidas restantes")
		# Aquí podrías mostrar la pantalla de game over
		#$GameOverSprite

func _on_player_died():
	player = null  # Importante: establecemos player a null cuando muere
