extends Node3D

func _process(delta):
	$Control/Label.text = str($Player.score)
