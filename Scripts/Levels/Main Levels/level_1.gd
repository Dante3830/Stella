extends Node

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

func _ready():
	Manager.init_data()
	$Comentarios.visible = false
	spawn_player()
	
	# Configura las escenas de enemigos en el pool
	enemy_pool.enemy_scenes = [
		BlueEnemyA,
		RedEnemyA,
		BlueEnemyB,
		RedEnemyB,
		BlueEnemyC,
		RedEnemyC,
		BlueEnemyD,
		RedEnemyD,
	]
	
	# Conecta las señales
	enemy_pool.wave_completed.connect(_on_wave_completed)
	enemy_pool.all_waves_completed.connect(_on_all_waves_completed)
	
	# Inicia las oleadas
	enemy_pool.start_waves()

func _physics_process(_delta):
	if player == null and $PlayerRespawn.is_stopped():
		$PlayerRespawn.start()

func spawn_player():
	player = Player.instantiate()
	player.position = Vector2(535, 1097)
	get_node("Characters").add_child(player)

func toggle_enemy_spawn():
	$SpawnTimer.stop()

func _on_spawn_timer_timeout():
	var enemy
	get_node("Characters").add_child(enemy)

func _on_player_respawn_timeout():
	if Manager.lives > 0:
		player.connect("player_died", Callable(self, "_on_player_died"))
		Manager.health = 100
		Manager.power = 0
		Manager.lives -= 1
		spawn_player()
		print("Jugador respawneado")
	else:
		print("Game Over - Sin vidas restantes")

func _on_player_died():
	player = null

func _on_wave_timer_timeout() -> void:
	pass # Replace with function body.

func _on_wave_completed():
	print("¡Oleada completada!")

func _on_all_waves_completed():
	print("¡Todas las oleadas completadas!")
	# Victoria del nivel, siguiente nivel, etc.
