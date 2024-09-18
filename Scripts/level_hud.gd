extends Control

@onready var lives_text = $LIVES/LivesDP
@onready var score_text = $SCORE/ScoreDP
@onready var health_bar = $Power/HealthBar
@onready var power_bar = $Power/PowerBar

# Definimos los colores para cuando is_red es verdadero
var color_high_red = Color(1, 0.5, 0.5)  # Rosa claro
var color_mid_red = Color(1, 0.25, 0.25) # Rosa medio
var color_low_red = Color(1, 0, 0)       # Rojo

# Definimos los colores para cuando is_red es falso
var color_high_blue = Color(0.5, 0.5, 1)  # Azul claro
var color_mid_blue = Color(0.25, 0.25, 1) # Azul medio
var color_low_blue = Color(0, 0, 1)       # Azul oscuro

func _ready():
	# Aseguramos que el estilo de la barra de salud esté configurado correctamente
	if not power_bar.get("theme_override_styles/fill"):
		power_bar.set("theme_override_styles/fill", StyleBoxFlat.new())

func _process(_delta):
	# Vidas del jugador
	lives_text.text = str(Manager.lives)
	
	# Puntaje
	score_text.text = str(Manager.score)
	
	# Salud y poder de disparo del jugador
	health_bar.value = Manager.health
	
	power_bar.value = Manager.power
	update_power_bar_color()

func update_power_bar_color():
	var bg_style = power_bar.get("theme_override_styles/background")
	var fill_style = power_bar.get("theme_override_styles/fill")
	
	if fill_style is StyleBoxFlat and bg_style is StyleBoxFlat:
		if Manager.is_red:
			bg_style.bg_color = color_high_red
			bg_style.shadow_color = color_mid_red
			bg_style.border_color = Color.BLACK
			
			fill_style.bg_color = color_low_red
			fill_style.shadow_color = color_mid_red
			fill_style.border_color = color_high_red
		else:
			bg_style.bg_color = color_high_blue
			bg_style.shadow_color = color_mid_blue
			bg_style.border_color = Color.BLACK
			
			fill_style.bg_color = color_low_blue
			fill_style.shadow_color = color_mid_blue
			fill_style.border_color = color_high_blue
		
		# Actualizamos el estilo para que los cambios surtan efecto
		power_bar.set("theme_override_styles/fill", fill_style)
		power_bar.set("theme_override_styles/background", bg_style)
