extends Control

## Главное меню. Нажатия обрабатываем по зонам поверх готового арт-меню.

@onready var play_area: Button = $PlayArea
@onready var settings_area: Button = $SettingsArea

# Переменные для сердец
var hearts: Array = []
var hearts_container: HBoxContainer
var game_manager: Node

var game_scene = preload("res://game.tscn")
var settings_scene = preload("res://settings.tscn")

func _ready() -> void:
	game_manager = get_node("/root/GameManager")
	
	# Создаем систему сердец в главном меню
	_create_hearts_system()
	
	play_area.pressed.connect(_on_play_pressed)
	settings_area.pressed.connect(_on_settings_pressed)

func _create_hearts_system() -> void:
	# Создаем контейнер для сердец в левом верхнем углу
	hearts_container = HBoxContainer.new()
	hearts_container.name = "HeartsContainer"
	hearts_container.position = Vector2(20, 20)
	hearts_container.add_theme_constant_override("separation", 12)
	add_child(hearts_container)
	
	# Подписываемся на изменение жизней
	game_manager.lives_changed.connect(_update_hearts_display)
	
	# Создаем 3 сердца
	_update_hearts_display(3)

func _update_hearts_display(lives: int) -> void:
	# Очищаем старые сердца
	for heart in hearts:
		if is_instance_valid(heart):
			heart.queue_free()
	hearts.clear()
	
	# Создаем новые сердца
	for i in range(lives):
		var heart = Label.new()
		heart.text = "❤️"
		heart.add_theme_font_size_override("font_size", 36)
		heart.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
		heart.add_theme_constant_override("outline_size", 2)
		heart.add_theme_color_override("font_outline_modulate", Color(0, 0, 0))
		hearts_container.add_child(heart)
		hearts.append(heart)
	
	# Анимация если осталось мало жизней
	if lives < 3:
		_animate_low_health()

func _animate_low_health() -> void:
	for heart in hearts:
		var tween = create_tween()
		tween.tween_property(heart, "modulate", Color(1, 0.5, 0.5), 0.3)
		tween.tween_property(heart, "modulate", Color(1, 0.2, 0.2), 0.3)
		tween.set_loops()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_packed(settings_scene)
