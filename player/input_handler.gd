extends Node

func tick(delta, props, state):
	return {
		"left": Input.is_action_pressed("move_left"),
		"right": Input.is_action_pressed("move_right"),
		"jump": Input.is_action_pressed("jump")
	}