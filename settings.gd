extends Control

## Экран настроек
@onready var sound_checkbox: CheckBox = $Panel/VBoxContainer/SoundCheckBox
@onready var music_checkbox: CheckBox = $Panel/VBoxContainer/MusicCheckBox
@onready var back_button: Button = $Panel/VBoxContainer/BackButton

var main_menu_scene = preload("res://main_menu.tscn")
var game_manager: Node

func _ready() -> void:
	_setup_ui()
	_load_settings()
	_connect_signals()

func _setup_ui() -> void:
	# Настройка VBoxContainer
	var vbox = $Panel/VBoxContainer
	vbox.add_theme_constant_override("separation", 40)
	
	# Настройка чекбоксов
	_setup_checkboxes_style()
	
	# Настройка кнопки назад
	_setup_back_button()

func _setup_checkboxes_style() -> void:
	var checkboxes = [sound_checkbox, music_checkbox]
	
	for checkbox in checkboxes:
		checkbox.add_theme_font_size_override("font_size", 36)
		checkbox.add_theme_constant_override("h_separation", 25)
	
	# Создаем иконки один раз для всех чекбоксов
	var check_off = _create_checkbox_icon(false)
	var check_on = _create_checkbox_icon(true)
	
	sound_checkbox.add_theme_icon_override("unchecked", check_off)
	sound_checkbox.add_theme_icon_override("checked", check_on)
	music_checkbox.add_theme_icon_override("unchecked", check_off)
	music_checkbox.add_theme_icon_override("checked", check_on)

func _create_checkbox_icon(checked: bool) -> ImageTexture:
	var size = 56
	var img = Image.create(size, size, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))
	
	var inner_start = 6
	var inner_end = size - 6
	var border = 5
	
	if checked:
		# Заливка
		for x in range(inner_start, inner_end):
			for y in range(inner_start, inner_end):
				img.set_pixel(x, y, Color(0.2, 0.9, 0.2, 1.0))
		
		# Рамка
		for x in range(inner_start - 1, inner_end + 1):
			for y in [inner_start - 1, inner_end - 1]:
				if x >= inner_start - 1 and x < inner_end:
					img.set_pixel(x, y, Color(0, 0.7, 0, 1.0))
		for y in range(inner_start - 1, inner_end):
			for x in [inner_start - 1, inner_end - 1]:
				img.set_pixel(x, y, Color(0, 0.7, 0, 1.0))
		
		# Галочка
		var check_color = Color(1, 1, 1, 1)
		var center = size / 2
		for i in range(8):
			img.set_pixel(center - 8 + i, center + 4, check_color)
			img.set_pixel(center - 4, center + i, check_color)
	else:
		# Заливка
		for x in range(inner_start, inner_end):
			for y in range(inner_start, inner_end):
				img.set_pixel(x, y, Color(0.15, 0.15, 0.15, 1.0))
		
		# Рамка
		for x in range(inner_start - 1, inner_end + 1):
			img.set_pixel(x, inner_start - 1, Color(0.6, 0.6, 0.6, 1.0))
			img.set_pixel(x, inner_end - 1, Color(0.6, 0.6, 0.6, 1.0))
		for y in range(inner_start - 1, inner_end):
			img.set_pixel(inner_start - 1, y, Color(0.6, 0.6, 0.6, 1.0))
			img.set_pixel(inner_end - 1, y, Color(0.6, 0.6, 0.6, 1.0))
	
	return ImageTexture.create_from_image(img)

func _setup_back_button() -> void:
	# УВЕЛИЧЕННЫЙ РАЗМЕР КНОПКИ
	back_button.add_theme_font_size_override("font_size", 48)  # Было 40, стало 48
	back_button.custom_minimum_size = Vector2(800, 100)  # Было 600x60, стало 800x100
	
	# Добавляем отступы внутри кнопки (padding)
	back_button.add_theme_constant_override("outline_size", 2)
	
	# Эффекты наведения
	back_button.mouse_entered.connect(_on_back_button_hover_start)
	back_button.mouse_exited.connect(_on_back_button_hover_end)

func _on_back_button_hover_start() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(back_button, "scale", Vector2(1.05, 1.05), 0.15)

func _on_back_button_hover_end() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(back_button, "scale", Vector2(1.0, 1.0), 0.1)

func _load_settings() -> void:
	game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		sound_checkbox.button_pressed = game_manager.sound_enabled
		music_checkbox.button_pressed = game_manager.music_enabled

func _connect_signals() -> void:
	sound_checkbox.toggled.connect(_on_sound_toggled)
	music_checkbox.toggled.connect(_on_music_toggled)
	back_button.pressed.connect(_on_back_pressed)

func _on_sound_toggled(button_pressed: bool) -> void:
	if not game_manager:
		game_manager = get_node_or_null("/root/GameManager")
	
	if game_manager:
		game_manager.sound_enabled = button_pressed
		game_manager.save_settings()
		_animate_checkbox(sound_checkbox)

func _on_music_toggled(button_pressed: bool) -> void:
	if not game_manager:
		game_manager = get_node_or_null("/root/GameManager")
	
	if game_manager:
		game_manager.music_enabled = button_pressed
		game_manager.save_settings()
		_animate_checkbox(music_checkbox)
		_update_music_in_game()

func _animate_checkbox(checkbox: CheckBox) -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(checkbox, "scale", Vector2(1.15, 1.15), 0.08)
	tween.tween_property(checkbox, "scale", Vector2(1.0, 1.0), 0.12)

func _update_music_in_game() -> void:
	var game_node = get_tree().get_root().find_child("Game", true, false)
	if game_node and game_node.has_method("_update_music_from_settings"):
		game_node._update_music_from_settings()

func _on_back_pressed() -> void:
	# Анимация нажатия
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_BACK)
	tween.tween_property(back_button, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(back_button, "scale", Vector2(1.0, 1.0), 0.1)
	
	# Ждем анимацию или переходим сразу
	await get_tree().create_timer(0.1).timeout
	
	# Сохраняем настройки перед выходом
	if game_manager:
		game_manager.save_settings()
	
	# Переход в главное меню с эффектом
	var tween_transition = create_tween()
	tween_transition.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.2)
	await tween_transition.finished
	
	get_tree().change_scene_to_file("res://main_menu.tscn")

# Очистка при выходе
func _exit_tree() -> void:
	if game_manager:
		game_manager.save_settings()
