class_name WaveManager
extends Node

# Array de oleadas que se puede editar desde el editor
@export var waves: Array[Wave]

# Variables para el control del spawning
var current_wave_index: int = 0
var current_enemy_index: int = 0
var enemies_spawned: int = 0
var wave_in_progress: bool = false

# Referencias a nodos
@onready var spawn_timer: Timer = $"../SpawnTimer"
@onready var wave_timer: Timer = $"../WaveTimer"

# Señales
#signal wave_started(wave_number: int)
#signal wave_completed_(wave_number: int)
#signal all_waves_completed

func _ready():
	spawn_timer = Timer.new()
	wave_timer = Timer.new()
	add_child(spawn_timer)
	add_child(wave_timer)
	
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	wave_timer.timeout.connect(_on_wave_timer_timeout)

func start_waves():
	if waves.size() > 0:
		current_wave_index = 0
		start_current_wave()

func start_current_wave():
	if current_wave_index >= waves.size():
		emit_signal("all_waves_completed")
		return
	
	var current_wave = waves[current_wave_index]
	wave_in_progress = true
	current_enemy_index = 0
	enemies_spawned = 0
	
	emit_signal("wave_started", current_wave_index + 1)
	
	if current_wave.enemies.size() > 0:
		spawn_next_enemy()

func spawn_next_enemy():
	if not wave_in_progress:
		return
	
	var current_wave = waves[current_wave_index]
	var current_enemy = current_wave.enemies[current_enemy_index]
	
	if enemies_spawned < current_enemy.count:
		var enemy_instance = current_enemy.enemy_scene.instantiate()
		add_child(enemy_instance)
		# Configura la posición inicial del enemigo según tu juego
		# enemy_instance.position = get_spawn_position()
		
		enemies_spawned += 1
		spawn_timer.start(current_enemy.spawn_delay)
	else:
		current_enemy_index += 1
		enemies_spawned = 0
		
		if current_enemy_index >= current_wave.enemies.size():
			wave_completed()
		else:
			spawn_next_enemy()

func wave_completed():
	wave_in_progress = false
	emit_signal("wave_completed_", current_wave_index + 1)
	
	current_wave_index += 1
	if current_wave_index < waves.size():
		wave_timer.start(waves[current_wave_index - 1].wave_delay)
	else:
		emit_signal("all_waves_completed")

func _on_spawn_timer_timeout():
	spawn_next_enemy()

func _on_wave_timer_timeout():
	start_current_wave()
