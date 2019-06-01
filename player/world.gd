extends Node2D

func _ready():
	print($camera)
	print($player)
	$camera.set_player($player)