extends StaticBody3D
@export var rotation_dgrees = 0.02

func _process(delta):
	global_rotation.y += rotation_dgrees
