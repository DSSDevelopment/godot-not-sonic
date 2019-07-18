extends Node

func tick(delta, props, state):
	return {
		"left": Input.is_action_pressed("move_left"),
		"right": Input.is_action_pressed("move_right"),
		"down": Input.is_action_pressed("look_down"),
		"down_started": Input.is_action_just_pressed("look_down"),
		"jump": Input.is_action_pressed("jump"),
		"jumped": Input.is_action_just_pressed("jump"),
		"quit": Input.is_action_just_pressed("quit")
	}