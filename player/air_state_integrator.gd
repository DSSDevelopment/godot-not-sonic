extends Node

func tick(delta, props, state):
	var velocity_x = state['velocity'].x
	var velocity_y = state['velocity'].y

	if velocity_y < 0 and velocity_y > -4:
    	velocity_x -= ((velocity_x / 0.125) / 256)

	velocity_y += props['gravity']
	if velocity_y > props['max_falling_speed']:
		velocity_y = props['max_falling_speed']

	if state['input']['left']:
		velocity_x -= (props['acceleration'] * 2)
	elif state['input']['right']:
		velocity_x += (props['acceleration'] * 2)

	if state['collisions']['wall_left']['colliding']:
		velocity_x = 0
	elif state['collisions']['wall_right']['colliding']:
		velocity_x = 0
	
	if state['collisions']['ceiling_left']['colliding'] or state['collisions']['ceiling_right']['colliding']:
		velocity_y = 0
	
	if state['collisions']['floor_left']['colliding'] and velocity_y - state['host'].position.y > 0:
		#velocity_y = state['collisions']['floor_left']['position'].y - state['host'].position.y
		state['ground_speed'] = velocity_x
	if state['collisions']['floor_right']['colliding'] and velocity_y - state['host'].position.y > 0:
		#velocity_y = state['collisions']['floor_right']['position'].y - state['host'].position.y
		state['ground_speed'] = velocity_x

	return Vector2(velocity_x, velocity_y)
	