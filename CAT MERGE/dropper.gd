extends Marker2D

var ball_scene = preload("res://test_ball.tscn")
var particle_scene = preload("res://merge_particles.tscn")

var current_level: int = 1
var next_level: int = 1

@export var visual_preview: Sprite2D
@export var next_cat_ui: TextureRect
@export var score_label: Label
@export var cat_textures: Array[Texture2D] = []

@export var box_left_x: float = 51.0
@export var box_right_x: float = 669.0
@export var base_cat_radius: float = 90.0

var is_dragging = false
var score: int = 0
var can_drop: bool = true

var level_colors = [
	Color(1, 0.4, 0.4), Color(1, 0.6, 0.2), Color(1, 0.9, 0.3),
	Color(0.4, 0.9, 0.4), Color(0.3, 0.6, 1), Color(0.4, 0.4, 0.9),
	Color(0.7, 0.3, 0.9), Color(1, 0.4, 0.8), Color(0.9, 0.9, 0.9),
	Color(0.5, 0.5, 0.5), Color(1, 0.84, 0)
]

func _ready():
	if !visual_preview and has_node("Sprite2D"):
		visual_preview = $Sprite2D
	elif !visual_preview and has_node("Icon"):
		visual_preview = $Icon
		
	randomize_balls()
	update_preview_visuals()
	update_score_display()
	
	# ⚡ THE FIX: Warm up the cache immediately on boot
	warm_up_cache()

func warm_up_cache():
	# 1. Spawn a dummy ball, make it invisible, and instantly delete it
	var dummy_ball = ball_scene.instantiate()
	dummy_ball.level = 2
	dummy_ball.position = Vector2(200, 200)
	dummy_ball.modulate = Color(1, 1, 1, 0.01)
	dummy_ball.freeze = true
	
	var dummy_particles = particle_scene.instantiate()
	dummy_particles.position = Vector2(200, 200)
	dummy_particles.modulate = Color(1, 1, 1, 0.01)
	dummy_particles.emitting = true
	
	get_parent().call_deferred("add_child", dummy_ball)
	get_parent().call_deferred("add_child", dummy_particles)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	if is_instance_valid(dummy_ball):
		dummy_ball.queue_free()
	if is_instance_valid(dummy_particles):
		dummy_particles.queue_free()
	
func _unhandled_input(event):
	if not can_drop: return
	
	if (event is InputEventScreenTouch or event is InputEventMouseButton) and event.is_pressed():
		is_dragging = true
		update_dropper_position(get_global_mouse_position().x)
	elif (event is InputEventScreenDrag or event is InputEventMouseMotion) and is_dragging:
		update_dropper_position(get_global_mouse_position().x)
	elif (event is InputEventScreenTouch or event is InputEventMouseButton) and event.is_released() and is_dragging:
		is_dragging = false
		update_dropper_position(get_global_mouse_position().x)
		spawn_ball()

func update_dropper_position(target_x: float):
	var size_multiplier = 0.2 + (current_level - 1) * 0.1
	var current_radius = base_cat_radius * size_multiplier
	var min_x = box_left_x + current_radius
	var max_x = box_right_x - current_radius
	global_position.x = clamp(target_x, min_x, max_x)

func randomize_balls():
	current_level = randi_range(1, 5)
	next_level = randi_range(1, 5)

func update_preview_visuals():
	if visual_preview:
		if cat_textures.size() >= current_level and cat_textures[current_level - 1] != null:
			visual_preview.texture = cat_textures[current_level - 1]
			visual_preview.modulate = Color.WHITE
		else:
			visual_preview.modulate = level_colors[current_level - 1]
			
		var size_multiplier = 0.2 + (current_level - 1) * 0.1 
		visual_preview.scale = Vector2(size_multiplier, size_multiplier)

	if next_cat_ui:
		if cat_textures.size() >= next_level and cat_textures[next_level - 1] != null:
			next_cat_ui.texture = cat_textures[next_level - 1]

func spawn_ball():
	can_drop = false
	visual_preview.visible = false
	
	var new_ball = ball_scene.instantiate()
	new_ball.level = current_level
	new_ball.position = global_position
	get_parent().add_child(new_ball)
	
	await get_tree().create_timer(0.5).timeout
	
	current_level = next_level
	next_level = randi_range(1, 5)
	update_preview_visuals()
	
	visual_preview.visible = true
	can_drop = true

func spawn_merged_ball(spawn_position, new_level):
	var upgraded_ball = ball_scene.instantiate()
	upgraded_ball.level = new_level
	upgraded_ball.position = spawn_position
	get_parent().add_child(upgraded_ball)
	
	var particles = particle_scene.instantiate()
	particles.position = spawn_position
	
	var color_index = clampi(new_level - 1, 0, level_colors.size() - 1)
	particles.modulate = level_colors[color_index]
	
	get_parent().add_child(particles)
	
	var points_earned = new_level * 10
	score += points_earned
	update_score_display()

func update_score_display():
	if score_label:
		score_label.text = "Score: " + str(score)
