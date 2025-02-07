extends Node

@export var enemy_on = false

var BlueEnemyA = preload("res://Scenes/Enemy/Enemy A/BlueEnemyA.tscn")
var RedEnemyA = preload("res://Scenes/Enemy/Enemy A/RedEnemyA.tscn")

var BlueEnemyB = preload("res://Scenes/Enemy/Enemy B/BlueEnemyB.tscn")
var RedEnemyB = preload("res://Scenes/Enemy/Enemy B/RedEnemyB.tscn")

var BlueEnemyC = preload("res://Scenes/Enemy/Enemy C/BlueEnemyC.tscn")
var RedEnemyC = preload("res://Scenes/Enemy/Enemy C/RedEnemyC.tscn")

var BlueEnemyD = preload("res://Scenes/Enemy/Enemy D/BlueEnemyD.tscn")
var RedEnemyD = preload("res://Scenes/Enemy/Enemy D/RedEnemyD.tscn")

var current_wave = 0

var Player = preload("res://Scenes/Player/Player.tscn")
var player = null

@onready var enemy_pool = $EnemyPool

@export var level_boss : PackedScene
@export var spawn_position_x : int
@export var spawn_position_y : int

func _ready():
	Manager.init_data()
	$Comentarios.visible = false
	spawn_player()
	
	#Configura las escenas de enemigos en el pool
	#enemy_pool.enemy_scenes = [
		#BlueEnemyA,
		#RedEnemyA,
		#BlueEnemyB,
		#RedEnemyB,
		#BlueEnemyC,
		#RedEnemyC,
		#BlueEnemyD,
		#RedEnemyD,
	#]
	
	# Conecta las señales
	enemy_pool.wave_completed.connect(_on_wave_completed)
	enemy_pool.all_waves_completed.connect(_on_all_waves_completed)
	
	if enemy_on:
		# Inicia las oleadas
		enemy_pool.start_waves()
	else:
		_on_all_waves_completed()

func _physics_process(_delta):
	if player == null and $PlayerRespawn.is_stopped() and Manager.lives >= 1:
		$PlayerRespawn.start()

func spawn_player():
	player = Player.instantiate()
	player.position = Vector2(535, 1097)
	get_node("Characters").add_child(player)

func toggle_enemy_spawn():
	$SpawnTimer.stop()

#func _on_spawn_timer_timeout():
	#var enemy
	#get_node("Characters").add_child(enemy)

func _on_player_respawn_timeout():
	if Manager.lives >= 1:
		if player == null:
			spawn_player()
			# Conectar la señal solo si el jugador no es null
			if player != null:
				player.connect("player_died", Callable(self, "_on_player_died"))
			Manager.health = 100
			Manager.power = 0
			Manager.lives -= 1
			print("Jugador respawneado")
	else:
		print("Game Over - Sin vidas restantes")
		show_game_over()

func _on_player_died():
	player = null

func _on_wave_timer_timeout():
	pass

func _on_wave_completed():
	print("¡Oleada completada!")
	# Pasar a la siguiente oleada

func _on_all_waves_completed():
	print("¡Todas las oleadas completadas!")
	
	if level_boss:
		var boss = level_boss.instantiate()
		boss.position = Vector2(spawn_position_x, spawn_position_y)
		get_node("Characters").add_child(boss)
	else:
		print("No se ha definido la escena del jefe")

func show_game_over():
	$PlayerRespawn.stop()
	$AnimationPlayer.play("GameOver")
	await get_tree().create_timer(5.0).timeout
	print("Pasaron 5 segundos. Cambiando a Main Menu")
	get_tree().change_scene_to_file("res://Scenes/Screens/MainMenu.tscn")
