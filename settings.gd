extends Control

## Экран настроек
@onready var sound_checkbox: CheckBox = $Panel/VBoxContainer/SoundCheckBox
@onready var music_checkbox: CheckBox = $Panel/VBoxContainer/MusicCheckBox
@onready var back_button: Button = $Panel/VBoxContainer/BackButton

var main_menu_scene = preload("res://main_menu.tscn")

func _ready() -> void:
	_setup_checkboxes_style()
	_setup_back_button()
	
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		sound_checkbox.button_pressed = game_manager.sound_enabled
		music_checkbox.button_pressed = game_manager.music_enabled
	
	sound_checkbox.toggled.connect(_on_sound_toggled)
	music_checkbox.toggled.connect(_on_music_toggled)
	back_button.pressed.connect(_on_back_pressed)

func _setup_checkboxes_style() -> void:
	sound_checkbox.add_theme_font_size_override("font_size", 36)
	music_checkbox.add_theme_font_size_override("font_size", 36)
	sound_checkbox.add_theme_constant_override("h_separation", 25)
	music_checkbox.add_theme_constant_override("h_separation", 25)
	
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
	
	if checked:
		for x in range(6, size - 6):
			for y in range(6, size - 6):
				img.set_pixel(x, y, Color(0.2, 0.9, 0.2, 1.0))  # Ярко-зеленый
		
		# Добавляем темно-зеленую рамку
		for x in range(size):
			for y in range(size):
				if (x == 5 or x == size - 6 or y == 5 or y == size - 6) and x >= 4 and x < size - 4 and y >= 4 and y < size - 4:
					img.set_pixel(x, y, Color(0, 0.7, 0, 1.0))
	else:
		for x in range(6, size - 6):
			for y in range(6, size - 6):
				img.set_pixel(x, y, Color(0.15, 0.15, 0.15, 1.0))
		
		for x in range(6, size - 6):
			img.set_pixel(x, 5, Color(0.6, 0.6, 0.6, 1.0))
			img.set_pixel(x, size - 6, Color(0.6, 0.6, 0.6, 1.0))
		for y in range(6, size - 6):
			img.set_pixel(5, y, Color(0.6, 0.6, 0.6, 1.0))
			img.set_pixel(size - 6, y, Color(0.6, 0.6, 0.6, 1.0))
	
	return ImageTexture.create_from_image(img)

func _setup_back_button() -> void:
	back_button.add_theme_font_size_override("font_size", 40)
	back_button.custom_minimum_size = Vector2(600, 60)
	back_button.mouse_entered.connect(func(): 
		var tween = create_tween()
		tween.tween_property(back_button, "scale", Vector2(1.02, 1.02), 0.1)
	)
	back_button.mouse_exited.connect(func(): 
		var tween = create_tween()
		tween.tween_property(back_button, "scale", Vector2(1.0, 1.0), 0.1)
	)

func _on_sound_toggled(button_pressed: bool) -> void:
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		game_manager.sound_enabled = button_pressed
		game_manager.save_settings()
	
		var tween = create_tween()
		tween.tween_property(sound_checkbox, "scale", Vector2(1.1, 1.1), 0.05)
		tween.tween_property(sound_checkbox, "scale", Vector2(1.0, 1.0), 0.1)

func _on_music_toggled(button_pressed: bool) -> void:
	var game_manager = get_node_or_null("/root/GameManager")
	if game_manager:
		game_manager.music_enabled = button_pressed
		game_manager.save_settings()
		
		var tween = create_tween()
		tween.tween_property(music_checkbox, "scale", Vector2(1.1, 1.1), 0.05)
		tween.tween_property(music_checkbox, "scale", Vector2(1.0, 1.0), 0.1)
	
	var game_node = get_tree().get_root().find_child("Game", true, false)
	if game_node and game_node.has_method("_update_music_from_settings"):
		game_node._update_music_from_settings()

func _on_back_pressed() -> void:
	var tween = create_tween()
	tween.tween_property(back_button, "scale", Vector2(0.95, 0.95), 0.05)
	tween.tween_property(back_button, "scale", Vector2(1.0, 1.0), 0.1)
	await tween.finished
	
	get_tree().change_scene_to_file("res://main_menu.tscn")
