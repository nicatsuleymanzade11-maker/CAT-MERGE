extends ColorRect

@export var sfx_slider: HSlider
@export var music_slider: HSlider

func _ready():
	# Hide the giant overlay screen when the game first starts
	hide()
	
	if !sfx_slider and has_node("VBoxContainer/SFXSlider"):
		sfx_slider = $VBoxContainer/SFXSlider
	if !music_slider and has_node("VBoxContainer/MusicSlider"):
		music_slider = $VBoxContainer/MusicSlider

func open_menu():
	show()
	# This freezes the physics engine and dropper movements!
	get_tree().paused = true

func _on_resume_button_pressed():
	hide()
	# Wakes the physics world right back up
	get_tree().paused = false

func _on_home_button_pressed():
	get_tree().paused = false
	print("🏠 Heading back to the Main Menu... (Placeholder active!)")

func _on_sfx_slider_value_changed(value: float):
	print("🔊 SFX Volume: ", value)

func _on_music_slider_value_changed(value: float):
	print("🎵 Music Volume: ", value)
