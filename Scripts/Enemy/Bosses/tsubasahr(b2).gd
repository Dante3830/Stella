extends CharacterBody2D

var all_text_visible = false
var has_reached_position = false
var can_fire = false
var use_blue_bullet = true
var times = 0
var explosions_remaining = 30
var damage : int
var current_phase_health : int
var current_phase_max_health : int
var current_mill_angle = 0.0

@export var shoot_interval = 1.0
var shoot_timer = 0.0

var phase = 0
# 0 = Intro
# 1 = Wings 1
# 2 = Wings 2
# 3 = Wings 3

@export var phase1_health = 50
@export var phase2_health = 75
@export var phase3_health = 100

@export var descent_speed = 100.0

@onready var healthBar = $"CanvasLayer/Boss Health/HealthBar"
@onready var explosion_scene = preload("res://Scenes/Explosion.tscn")

@onready var bullet_scenes = {
	"red_a": preload("res://Scenes/Enemy/Bullets/RedEnemyBulletA.tscn"),
	"blue_a": preload("res://Scenes/Enemy/Bullets/BlueEnemyBulletA.tscn"),
	"red_b": preload("res://Scenes/Enemy/Bullets/RedEnemyBulletB.tscn"),
	"blue_b": preload("res://Scenes/Enemy/Bullets/BlueEnemyBulletB.tscn")
}

var wing_fire_data = {
	"left": {"timer": 0.0, "can_fire": true},
	"right": {"timer": 0.0, "can_fire": true}
}

var wing_health = {
	"left": 50,  # Salud para cada ala izquierda
	"right": 50  # Salud para cada ala derecha
}

func _ready():
	setup_initial_state()

func _physics_process(delta):
	handle_descent(delta)
	handle_phase_behavior()
	handle_text_visibility(delta)
	update_health_display()
	
	if position.y > 408:
		phase = 1
		has_reached_position = true
		can_fire = true
	
	if has_reached_position and can_fire:
		handle_phase_behavior()
		shooting_phase_pattern(phase)
	
	#shoot_timer -= delta
	#if shoot_timer <= 0:
		#shoot_at_player()
		#shoot_timer = shoot_interval

func setup_initial_state():
	$CanvasLayer/WARNING.visible = true
	
	var text_elements = [
		$CanvasLayer/WARNING/Warning,
		$CanvasLayer/WARNING/Mothership,
		$CanvasLayer/WARNING/Name,
		$CanvasLayer/WARNING/NoRefuge
	]
	
	for element in text_elements:
		element.visible_ratio = 0
	
	current_phase_health = phase1_health
	current_phase_max_health = phase1_health
	healthBar.max_value = phase1_health
	healthBar.value = phase1_health

#func shoot_at_player():
	#var player_position = get_player_position()
	#var direction = (player_position - $BASE/SpawnPoint.global_position).normalized()
	#
	# Obtener el color actual de la bala
	#var current_color = "blue_a"
	#
	#var current_bullet_type = current_color[0]
	#
	# Crear la bala con el color actual
	#var bullet = bullet_scenes[current_color].instantiate()
	#bullet.position = $BASE/SpawnPoint.global_position
	#bullet.set_direction(direction)
	#bullet.set_color(current_color)  # Pasar el color a la bala
	#get_parent().add_child(bullet)
	#
	# Cambiar al siguiente color para el próximo disparo
	#current_bullet_type = "red_a" if current_bullet_type == "blue_a" else "blue_a"

func _on_fire_speed_timeout():
	can_fire = true

func handle_descent(delta):
	if position.y < 408:
		move_and_collide(Vector2(0, descent_speed * delta))

func handle_phase_behavior():
	match phase:
		1:
			$"CanvasLayer/Boss Health".visible = true
			enable_wing_collision(1)
			shooting_phase_pattern(1)
		2:
			enable_wing_collision(2)
			shooting_phase_pattern(2)
		3:
			enable_wing_collision(3)
			shooting_phase_pattern(3)

func handle_text_visibility(delta):
	if not all_text_visible:
		var text_elements = [
			$CanvasLayer/WARNING/Warning, $CanvasLayer/WARNING/Mothership,
			$CanvasLayer/WARNING/Name, $CanvasLayer/WARNING/NoRefuge
		]
		
		for element in text_elements:
			element.visible_ratio += delta
		
		all_text_visible = text_elements.all(func(e): return e.visible_ratio >= 1)
		
		if all_text_visible:
			$CanvasLayer/WARNING/VisibleTimer.start()

func update_health_display():
	if healthBar:
		match phase:
			1:
				healthBar.max_value = phase1_health
				healthBar.value = current_phase_health
			2:
				healthBar.max_value = phase2_health
				healthBar.value = current_phase_health
			3:
				healthBar.max_value = phase3_health
				healthBar.value = current_phase_health

func start_death_sequence():
	var shader_material = $BASE/Base.material as ShaderMaterial
	if shader_material:
		shader_material.set_shader_parameter("flicker_intensity", 1.0)
	
	Manager.score += 10000
	
	if is_instance_valid($BASE/BaseCollisionShape):
		$BASE/BaseCollisionShape.set_deferred("disabled", true)
	
	$FireSpeed.stop()
	$ExplosionsTimer.start()
	$DestroyTimer.start()

func _on_explosions_timer_timeout():
	if explosions_remaining > 0:
		create_random_explosion()
		explosions_remaining -= 1
	else:
		cleanup_and_die()

func _on_destroy_timer_timeout():
	explosion_scene.instantiate()

func create_random_explosion():
	var Explosion = explosion_scene.instantiate()
	var random_x = randf_range(-500, 100)
	var random_y = randf_range(-300, 425)
	Explosion.global_position = global_position + Vector2(random_x, random_y)
	get_parent().add_child(Explosion)

func cleanup_and_die():
	$ExplosionsTimer.stop()
	queue_free()

func _on_visible_timer_timeout() -> void:
	$CanvasLayer/WARNING.visible = !$CanvasLayer/WARNING.visible
	times += 1
	
	if times >= 10:
		$CanvasLayer/WARNING.visible = false
		$CanvasLayer/WARNING/VisibleTimer.stop()

func enable_wing_collision(current_phase: int):
	match current_phase:
		1:
			$"LEFT WING 1/LeftCollisionShape".disabled = false
			$"RIGHT WING 1/RightCollisionShape".disabled = false
		2:
			$"LEFT WING 2/LeftCollisionShape".disabled = false
			$"RIGHT WING 2/RightCollisionShape".disabled = false
		3:
			$"LEFT WING 3/LeftCollisionShape".disabled = false
			$"RIGHT WING 3/RightCollisionShape".disabled = false

func update_wing_timers():
	for side in wing_fire_data:
		if wing_fire_data[side]["timer"] > 0:
			wing_fire_data[side]["timer"] -= get_physics_process_delta_time()
			if wing_fire_data[side]["timer"] <= 0:
				wing_fire_data[side]["can_fire"] = true

func shooting_phase_pattern(current_phase: int) -> void:
	match current_phase:
		1:
			# Comportamiento fase 1 (existente)
			if $"LEFT WING 1" and $"RIGHT WING 1":
				shoot_mill_pattern($"LEFT WING 1/SpawnPoint", bullet_scenes["blue_b"], "left")
				shoot_mill_pattern($"RIGHT WING 1/SpawnPoint", bullet_scenes["red_b"], "right")
		
		2:
			# Nuevo comportamiento fase 2
			if $"LEFT WING 2" and $"RIGHT WING 2":
				shoot_arc_pattern($"LEFT WING 2/SpawnPoint", bullet_scenes["red_b"])
				shoot_arc_pattern($"RIGHT WING 2/SpawnPoint", bullet_scenes["blue_b"])
		
		3:
			# Comportamiento fase 3 (existente)
			if $"LEFT WING 3" and $"RIGHT WING 3":
				shoot_superfire_pattern($"LEFT WING 3/SpawnPoint", bullet_scenes["blue_a"])
				shoot_superfire_pattern($"RIGHT WING 3/SpawnPoint", bullet_scenes["red_a"])
	
	$FireSpeed.start()
	can_fire = false

func shoot_mill_pattern(spawn_point, bullet_scene, wing_side: String):
	var bullet_count = 4  # 4 aspas
	var base_angle = current_mill_angle
	
	for i in range(bullet_count):
		var angle = deg_to_rad(base_angle + (i * 90.0))
		var direction = Vector2(cos(angle), sin(angle))
		
		var bullet_instance = bullet_scene.instantiate()
		bullet_instance.position = spawn_point.global_position
		
		if bullet_instance.has_method("init"):
			bullet_instance.init(direction)
		
		get_parent().add_child(bullet_instance)
	
	current_mill_angle += 20
	if current_mill_angle >= 360:
		current_mill_angle = 0
	
	# Configura el temporizador solo para esta ala
	wing_fire_data[wing_side]["can_fire"] = false
	wing_fire_data[wing_side]["timer"] = shoot_interval

func shoot_arc_pattern(spawn_point, bullet_scene):
	# Configuración del arco de disparo
	var arc_angle = 45.0  # Ángulo total del arco
	var base_angle = 90.0  # Apuntando hacia abajo
	
	# Calcular dirección aleatoria dentro del arco
	var random_angle = deg_to_rad(base_angle + randf_range(-arc_angle/2, arc_angle/2))
	var direction = Vector2(cos(random_angle), sin(random_angle))
	
	# Crear bala
	var bullet = bullet_scene.instantiate()
	bullet.position = spawn_point.global_position
	
	# Configurar dirección
	if bullet.has_method("init"):
		bullet.init(direction)
	elif bullet.has_method("set_direction"):
		bullet.set_direction(direction)
	
	get_parent().add_child(bullet)
	
	# Efecto de disparo
	#spawn_muzzle_flash(spawn_point.global_position)

func shoot_superfire_pattern(spawn_point, bullet_scene):
	pass

func enemy_hit():
	print("¡Impacto recibido! Fase actual: ", phase)
	
	match phase:
		1:
			# Calcular daño basado en color
			if Manager.is_red:
				damage = 2
			else:
				damage = 1
			
			# Determinar qué ala fue golpeada
			var wing_side = determine_hit_wing()
			if wing_side:
				wing_health[wing_side] -= damage
				print("Daño a ala ", wing_side, ": ", damage, " | Salud restante: ", wing_health[wing_side])
				
				# Verificar si el ala fue destruida
				if wing_health[wing_side] <= 0:
					destroy_wing(wing_side)
			
			# Verificar transición a fase 2 (ambas alas destruidas)
			if wing_health["left"] <= 0 and wing_health["right"] <= 0:
				transition_to_phase_2()
		
		2:
			# Comportamiento de fase 2 (similar pero con diferentes valores)
			if !Manager.is_red:  # Azul hace más daño en fase 2
				damage = 2
			else:
				damage = 1
			
			phase2_health -= damage
			current_phase_health = phase2_health
			print("Daño en fase 2: ", damage, " | Salud restante: ", phase2_health)
			
			if phase2_health <= 0:
				transition_to_phase_3()
		
		3:
			# Comportamiento de fase 3
			if Manager.is_red:
				damage = 2
			else:
				damage = 1
			
			phase3_health -= damage
			current_phase_health = phase3_health
			
			if phase3_health <= 0:
				start_death_sequence()
	
	update_health_display()

func choose_wing_to_damage(wing_health):
	var available_sides = []
	if wing_health["left"] > 0:
		available_sides.append("left")
	if wing_health["right"] > 0:
		available_sides.append("right")
	
	if available_sides.size() > 0:
		return available_sides[randi() % available_sides.size()]
	else:
		return null  # No hay alas disponibles para dañar

func destroy_wing(side: String):
	print("Destruyendo ala ", side)
	
	# Desactivar colisiones y efectos visuales
	match phase:
		1:
			if side == "left":
				$"LEFT WING 1/LeftCollisionShape".disabled = true
				# Añadir efectos de destrucción
				create_wing_explosion($"LEFT WING 1".global_position)
			else:
				$"RIGHT WING 1/RightCollisionShape".disabled = true
				create_wing_explosion($"RIGHT WING 1".global_position)
	
	# Reproducir animación/efecto de ala destruida
	# Puedes añadir partículas, cambiar sprite, etc.

func determine_hit_wing():
	# Esta función debería determinar qué ala fue golpeada
	# Necesitarías implementar lógica basada en qué Area2D detectó el impacto
	# Por ahora devolverá alternadamente izquierda/derecha para prueba
	return "left" if randi() % 2 == 0 else "right"

func check_phase_transition():
	if phase == 1 and phase1_health <= 0:
		print("Transición a Fase 2")
		phase = 2
		current_phase_health = phase2_health
		current_phase_max_health = phase2_health
		healthBar.max_value = phase2_health
		healthBar.value = phase2_health
		$LWAnimationPlayer.play("LeftWing2")
		$RWAnimationPlayer.play("RightWing2")
		play_phase_transition_effects()
	
	elif phase == 2 and phase2_health <= 0:
		print("Transición a Fase 3")
		phase = 3
		current_phase_health = phase3_health
		current_phase_max_health = phase3_health
		healthBar.max_value = phase3_health
		healthBar.value = phase3_health
		$LWAnimationPlayer.play("LeftWing3")
		$RWAnimationPlayer.play("RightWing3")
		play_phase_transition_effects()

func play_phase_transition_effects():
	# Aquí puedes agregar efectos visuales/sonoros para la transición
	# Por ejemplo, explosiones, partículas, sonidos, etc.
	var transition_explosion = explosion_scene.instantiate()
	transition_explosion.global_position = global_position
	get_parent().add_child(transition_explosion)

func create_wing_explosion(pos: Vector2):
	var explosion = explosion_scene.instantiate()
	explosion.global_position = pos
	explosion.scale = Vector2(1.5, 1.5)  # Explosión más grande para alas
	get_parent().add_child(explosion)

#func spawn_muzzle_flash(pos: Vector2):
	#var muzzle_flash = preload("res://Effects/MuzzleFlash.tscn").instantiate()
	#muzzle_flash.global_position = pos
	#get_parent().add_child(muzzle_flash)
	#muzzle_flash.emitting = true

func transition_to_phase_2():
	print("TRANSICIÓN A FASE 2")
	phase = 2
	current_phase_health = phase2_health
	current_phase_max_health = phase2_health
	
	# Restablecer salud de alas para fase 2
	wing_health = {"left": 75, "right": 75}
	
	# Actualizar UI
	healthBar.max_value = phase2_health
	healthBar.value = phase2_health
	
	# Animaciones
	$LWAnimationPlayer.play("LeftWing2")
	$RWAnimationPlayer.play("RightWing2")
	
	# Efectos de transición
	play_phase_transition_effects()
	
	# Habilitar nuevo par de alas
	enable_wing_collision(2)

func transition_to_phase_3():
	print("TRANSICIÓN A FASE 3")
	phase = 3
	current_phase_health = phase3_health
	current_phase_max_health = phase3_health
	
	# Restablecer salud de alas para fase 3
	wing_health = {"left": 100, "right": 100}
	
	# Actualizar UI
	healthBar.max_value = phase3_health
	healthBar.value = phase3_health
	
	# Animaciones
	$LWAnimationPlayer.play("LeftWing3")
	$RWAnimationPlayer.play("RightWing3")
	
	# Efectos de transición
	play_phase_transition_effects()
	
	# Habilitar nuevo par de alas
	enable_wing_collision(3)

# ALA IZQ 1 (FASE 1)
func _on_left_wing_1_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_left_wing_1_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA DER 1 (FASE 1)
func _on_right_wing_1_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_right_wing_1_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA IZQ 2 (FASE 2)
func _on_left_wing_2_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_left_wing_2_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA DER 2 (FASE 2)
func _on_right_wing_2_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_right_wing_2_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA IZQ 3 (FASE 3)
func _on_left_wing_3_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_left_wing_3_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# ALA DER 3 (FASE 3)
func _on_right_wing_3_area_entered(area: Area2D):
	if area.is_in_group("PlayerBullet"):
		enemy_hit()
		area.queue_free()

func _on_right_wing_3_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

# BASE
func _on_base_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		body.death()

func get_player_position():
	var player_node = get_tree().get_nodes_in_group("Player")
	if player_node.size() > 0:
		return player_node[0].global_position
	else:
		return #pass
