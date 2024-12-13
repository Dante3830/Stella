extends Node

const CONFIG_FILE_PATH = "user://game_settings.cfg"

var settings = {
	"brightness": 1.0 #, # Valor por defecto de brillo
	# Aquí puedes agregar más configuraciones en el futuro
}

func _ready():
	load_settings()

func save_settings():
	var config = ConfigFile.new()
	
	# Recorre todas las configuraciones y las guarda
	for key in settings.keys():
		config.set_value("Settings", key, settings[key])
	
	# Guarda el archivo de configuración
	var err = config.save(CONFIG_FILE_PATH)
	if err != OK:
		print("Error al guardar la configuración: ", err)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE_PATH)
	
	if err == OK:
		# Carga todas las configuraciones guardadas
		for key in settings.keys():
			if config.has_section_key("Settings", key):
				settings[key] = config.get_value("Settings", key)

func set_brightness(value: float):
	# Asegura que el valor esté entre 0 y 1
	settings["brightness"] = clamp(value, 0.0, 1.0)
	save_settings()

func get_brightness() -> float:
	return settings["brightness"]

func apply_brightness():
	RenderingServer.global_shader_parameter_set("global_brightness", settings["brightness"])
