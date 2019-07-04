extends Node

func tick(delta, props, state):
	var velocity_x = state['velocity'].x
	var velocity_y = state['velocity'].y
	var ground_speed = state['ground_speed']

	var pushing_left = state['collisions']['wall_left']['colliding']
	var pushing_right = state['collisions']['wall_right']['colliding']

	if state['input']['left'] and not pushing_left:
		if ground_speed > 0:
			ground_speed -= props['deceleration']
		elif ground_speed > -props['max_running_speed']:
			ground_speed -= props['acceleration']
	elif state['input']['right'] and not pushing_right:
		if ground_speed < 0:
			ground_speed += props['deceleration']
		elif ground_speed < props['max_running_speed']:
			ground_speed += props['acceleration']
	elif not pushing_left and not pushing_right:
		ground_speed -= min(abs(ground_speed), props['friction']) * sign(ground_speed)
	
	if ground_speed < 0 and state['collisions']['wall_left']['colliding']:
		ground_speed = 0
	elif ground_speed > 0 and state['collisions']['wall_right']['colliding']:
		ground_speed = 0

	if ground_speed > props['max_running_speed']:
		ground_speed = props['max_running_speed']
	if ground_speed < -props['max_running_speed']:
		ground_speed = -props['max_running_speed']
	return ground_speed