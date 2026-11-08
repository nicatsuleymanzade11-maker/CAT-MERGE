extends RigidBody2D

var level = 1
var is_merging = false

var level_colors = [
	Color(1, 0.4, 0.4), Color(1, 0.6, 0.2), Color(1, 0.9, 0.3),
	Color(0.4, 0.9, 0.4), Color(0.3, 0.6, 1), Color(0.4, 0.4, 0.9),
	Color(0.7, 0.3, 0.9), Color(1, 0.4, 0.8), Color(0.9, 0.9, 0.9),
	Color(0.5, 0.5, 0.5), Color(1, 0.84, 0)
]

@export var cat_sprite: Sprite2D
@export var collision_shape: CollisionShape2D
@export var cat_textures: Array[Texture2D] = []

func _ready():
	add_to_group("balls")

	if !cat_sprite and has_node("Sprite2D"):
		cat_sprite = $Sprite2D
	elif !cat_sprite and has_node("Icon"):
		cat_sprite = $Icon

	if !collision_shape and has_node("CollisionShape2D"):
		collision_shape = $CollisionShape2D

	if cat_sprite and cat_textures.size() >= level and cat_textures[level - 1] != null:
		cat_sprite.texture = cat_textures[level - 1]
	else:
		var color_index = clampi(level - 1, 0, 10)
		modulate = level_colors[color_index]
	
	var size_multiplier = 0.2 + (level - 1) * 0.1
	
	# Set up physics shape boundary scale securely
	if collision_shape and collision_shape.shape:
		collision_shape.shape = collision_shape.shape.duplicate()
		if collision_shape.shape is CircleShape2D:
			collision_shape.shape.radius = collision_shape.shape.radius * size_multiplier

	# JUICE: Animate the sprite popping outwards with a tiny bounce!
	if cat_sprite:
		var target_scale = Vector2(size_multiplier, size_multiplier)
		cat_sprite.scale = Vector2.ZERO # Start invisible
		
		var tween = create_tween()
		# TRANS_BACK + EASE_OUT makes it overshoot slightly and settle back down nicely
		tween.tween_property(cat_sprite, "scale", target_scale, 0.25)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)

func _on_body_entered(body):
	if is_merging: return
	
	if body.is_in_group("balls"):
		if body.level == level and level < 11 and not body.is_merging:
			if get_instance_id() > body.get_instance_id():
				is_merging = true
				body.is_merging = true
				
				var dropper = get_tree().current_scene.get_node_or_null("Dropper")
				if dropper and dropper.has_method("spawn_merged_ball"):
					dropper.call_deferred("spawn_merged_ball", global_position, level + 1)
				
				queue_free()
				body.queue_free()
