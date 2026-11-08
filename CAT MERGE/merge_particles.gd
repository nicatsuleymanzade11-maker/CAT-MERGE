# res://merge_particles.gd
extends CPUParticles2D

func _ready():
	emitting = true
	# Wait for the particles to finish flying, then clean up memory
	await get_tree().create_timer(lifetime).timeout
	queue_free()
