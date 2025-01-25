extends Node

@export var enemy_scenes: Array[PackedScene] = []
@export var enemy_names: Array[String] = []
@export var waves: Array[WaveData] = []

var pools: Array[Array] = []
var current_wave: int = 0
var active_enemies: Array[Node2D] = []

signal wave_completed
signal all_waves_completed

func _ready():
	# Inicializa un array de pool para cada tipo de enemigo
	for i in enemy_scenes.size():
		pools.append([])

func add_to_pool(object: Node2D, enemy_type: int):
	pools[enemy_type].append(object)
	object.set_process(false)
	object.set_physics_process(false)
	object.hide()

func pull_from_pool(enemy_type: int) -> Node2D:
	var object: Node2D
	
	if pools[enemy_type].is_empty():
		object = enemy_scenes[enemy_type].instantiate()
		add_child(object)
		if object.has_signal("defeated"):
			object.defeated.connect(_on_enemy_defeated.bind(object))
	else:
		object = pools[enemy_type][0]
		pools[enemy_type].remove_at(0)
	
	object.set_process(true)
	object.set_physics_process(true)
	object.show()
	
	active_enemies.append(object)
	return object

func _on_enemy_defeated(enemy: Node2D):
	active_enemies.erase(enemy)
	
	# Encuentra el tipo de enemigo y añádelo a su pool
	for i in enemy_scenes.size():
		if enemy.scene_file_path == enemy_scenes[i].resource_path:
			add_to_pool(enemy, i)
			break
	
	if active_enemies.is_empty():
		emit_signal("wave_completed")
		await get_tree().create_timer(2.0).timeout  # Pausa entre oleadas
		start_next_wave()

func start_waves():
	current_wave = 0
	start_next_wave()

func start_next_wave():
	if current_wave >= waves.size():
		emit_signal("all_waves_completed")
		return
	
	var wave = waves[current_wave]
	
	# Spawn enemigos A
	# Azul
	for i in wave.blue_a_enemy_count:
		var enemy = pull_from_pool(0)
		position_enemy(enemy)
	
	# Rojo
	for i in wave.red_a_enemy_count:
		var enemy = pull_from_pool(1)
		position_enemy(enemy)
	
	# Spawn enemigos B
	# Azul
	for i in wave.blue_b_enemy_count:
		var enemy = pull_from_pool(2)
		position_enemy(enemy)
	
	# Rojo
	for i in wave.red_b_enemy_count:
		var enemy = pull_from_pool(3)
		position_enemy(enemy)
	
	# Spawn enemigos C
	# Azul
	for i in wave.blue_c_enemy_count:
		var enemy = pull_from_pool(4)
		position_enemy(enemy)
	
	# Rojo
	for i in wave.red_c_enemy_count:
		var enemy = pull_from_pool(5)
		position_enemy(enemy)
	
	# Spawn enemigos D
	# Azul
	for i in wave.blue_d_enemy_count:
		var enemy = pull_from_pool(6)
		position_enemy(enemy)
	
	# Rojo
	for i in wave.red_d_enemy_count:
		var enemy = pull_from_pool(7)
		position_enemy(enemy)
	
	current_wave += 1

func position_enemy(enemy: Node2D):
	var viewport_size = get_tree().root.get_visible_rect().size
	enemy.position = Vector2( randf_range(0, viewport_size.x), -50 )
