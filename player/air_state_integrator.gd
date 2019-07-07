extends Node

func tick(delta, props, state):
	var velocity_x = state['velocity'].x
	var velocity_y = state['velocity'].y

	if state['collisions']['ceiling_left']['colliding'] or state['collisions']['ceiling_right']['colliding']:
		print('ceiling.')
		velocity_y = 0

	if velocity_y < 0 and velocity_y > -240:
    	velocity_x -= (floor(velocity_x / 0.125) / 256)

	velocity_y += props['gravity']
	if velocity_y > props['max_falling_speed']:
		velocity_y = props['max_falling_speed']

	if state['input']['left']:
		velocity_x -= (props['acceleration'] * 2)
	elif state['input']['right']:
		velocity_x += (props['acceleration'] * 2)

	if velocity_x < 0 and state['collisions']['wall_left']['colliding']:
		velocity_x = 0
	elif velocity_x > 0 and state['collisions']['wall_right']['colliding']:
		velocity_x = 0
	
	if not state['input']['jump'] and (state['flags']['jumped'] and velocity_y < -240):
		velocity_y = -240
	
	if state['collisions']['floor_left']['colliding'] and velocity_y > 0:
		state['ground_speed'] = velocity_x
	elif state['collisions']['floor_right']['colliding'] and velocity_y > 0:
		state['ground_speed'] = velocity_x
	
	if velocity_x > props['max_running_speed']:
		velocity_x = props['max_running_speed']
	if velocity_x < -props['max_running_speed']:
		velocity_x = -props['max_running_speed']

	return Vector2(velocity_x, velocity_y)
	