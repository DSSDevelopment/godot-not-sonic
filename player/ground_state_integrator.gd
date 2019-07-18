extends Node

func tick(delta, props, state):
	var ground_speed = state['ground_speed']

	var pushing_left = state['collisions']['wall_left']['colliding']
	var pushing_right = state['collisions']['wall_right']['colliding']
	
	state['flags']['pushing'] = pushing_left and state['input']['left'] or pushing_right and state['input']['right']
	
	var can_roll = abs(state['velocity'].x) > 61.875
	if can_roll and state['input']['down_started']:
		state['flags']['rolling'] = true
	var unroll = abs(state['velocity'].x) < 30
	if unroll:
		state['flags']['rolling'] = false
	
	var slope = props['slope_factor']
	if state['flags']['rolling']:
		if sign(ground_speed) == sign(state['collisions']['angle']):
			slope = props['slope_roll_up']
		else:
			slope = props['slope_roll_down']
	var slope_speed = slope * sin(state['collisions']['angle'])
	ground_speed -= slope_speed
	
	if not state['input']['left'] and not state['input']['right'] or (pushing_left or pushing_right):
		state['flags']['braking'] = false
	
	var max_speed = props['max_running_speed'] if not state['flags']['rolling'] else props['max_rolling_speed']
	if state['input']['left'] and not pushing_left:
		if ground_speed > 0:
			ground_speed -= props['deceleration']
			if abs(ground_speed) > 270:
				state['flags']['braking'] = true
		elif ground_speed > -max_speed and not state['flags']['rolling']:
			ground_speed -= props['acceleration']
	elif state['input']['right'] and not pushing_right:
		if ground_speed < 0:
			ground_speed += props['deceleration']
			if abs(ground_speed) > 270:
				state['flags']['braking'] = true
		elif ground_speed < max_speed and not state['flags']['rolling']:
			ground_speed += props['acceleration']
	if state['flags']['rolling'] or (not state['input']['left'] and not state['input']['right'] and not pushing_left and not pushing_right) and abs(ground_speed) > 0:
		var friction = props['friction'] if not state['flags']['rolling'] else props['friction'] * 0.5
		ground_speed -= min(abs(ground_speed), friction) * sign(ground_speed)
	
	if ground_speed < 0 and state['collisions']['wall_left']['colliding']:
		ground_speed = 0
	elif ground_speed > 0 and state['collisions']['wall_right']['colliding']:
		ground_speed = 0

	if ground_speed > max_speed and not state['input']['right']:
		ground_speed = max_speed
	if ground_speed < -max_speed and not state['input']['left']:
		ground_speed = -max_speed
	return ground_speed