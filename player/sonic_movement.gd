extends Node

var sensor_collider
var input_handler
var ground_state_integrator
var air_state_integrator
var camera

const properties = {
	"max_falling_speed": 960,
	"max_running_speed": 360,
	"acceleration": 2.8125,
	"deceleration": 30,
	"friction": 2.8125,
	"top_speed": 6.0,
	"jump_power": 390,
	"slope_factor": 0.125,
	"slope_roll_up": 0.78125,
	"slope_roll_down": 0.3125,
	"fall": 2.5,
	"gravity": 13.125
}

var state = {
	"host": null,
	"input": {
		"left": false,
		"right": false,
		"jump": false,
	},
	"velocity": Vector2(0, 0),
	"ground_speed": 0.0,
	"collisions": {
		"move_mode": "ground",
		"angle": 0,
		"wall_left": {"colliding": false, "position": Vector2(0, 0), "normal": Vector2(0, 0)},
		"wall_right": {"colliding": false, "position": Vector2(0, 0), "normal": Vector2(0, 0)},
		"ceiling_left": {"colliding": false, "position": Vector2(0, 0), "normal": Vector2(0, 0)},
		"ceiling_right": {"colliding": false, "position": Vector2(0, 0), "normal": Vector2(0, 0)},
		"floor_left": {"colliding": false, "position": Vector2(0, 0), "normal": Vector2(0, 0)},
		"floor_right": {"colliding": false, "position": Vector2(0, 0), "normal": Vector2(0, 0)}
	},
	"flags": {
		"canjump": false,
		"jumped": false
	}
}

func _ready():
	set_physics_process(false)
	state["host"] = get_parent()
	if $"../sensor_collider":
		sensor_collider = $"../sensor_collider"
	if $"../input_handler":
		input_handler = $"../input_handler"
	if $"../ground_state_integrator":
		ground_state_integrator = $"../ground_state_integrator"
	if $"../air_state_integrator":
		air_state_integrator = $"../air_state_integrator"
	var initialized = sensor_collider and input_handler and ground_state_integrator and air_state_integrator
	if initialized:
		set_physics_process(true)
	else:
		print("ERROR: Unable to initialize movement controller. Missing child node(s).")

func _physics_process(delta):
	var collisions_update = sensor_collider.tick(delta, properties, state)
	if state['collisions']['move_mode'] != collisions_update['move_mode']:
		update_move_mode(state['collisions']['move_mode'], collisions_update['move_mode'])
	state['collisions'] = collisions_update
	state['input'] = input_handler.tick(delta, properties, state)
	if state['collisions']["move_mode"] == "ground":
		state['ground_speed'] = ground_state_integrator.tick(delta, properties, state)
		state['velocity'] = Vector2(state['ground_speed'] * cos(0), state['ground_speed'] * -sin(0))
	else:
		state['velocity'] = air_state_integrator.tick(delta, properties, state)
	var jumping = state['input']['jump'] and state['flags']['canjump'] and not (state['collisions']['ceiling_left']['colliding'] or state['collisions']['ceiling_right']['colliding'])
	if jumping:
		jump()
	state['host'].move_and_slide(state['velocity'])
	var adjusted_position = collision_popout()
	state['host'].set_position(adjusted_position)

func update_move_mode(from, to):
	state['flags']['canjump'] = true if (from == "air" and to == "ground") else false
	if from == "air" and to == "ground":
		state['flags']['jumped'] = false
		state['ground_speed'] = state['velocity'].x
	if from == "ground" and to == "air":
		state['ground_speed'] = 0.0

func jump():
	print("jumping.")
	state['velocity'] = Vector2(state['velocity'].x, -properties['jump_power'])
	var new_move_mode = "air"
	update_move_mode(state['collisions']['move_mode'], new_move_mode)
	state['collisions']['move_mode'] = new_move_mode
	state['flags']['jumped'] = true

func land():
	ground_popout(state['host'].position)

func ground_popout(proposed_position):
	var position_x = proposed_position.x
	var position_y = proposed_position.y
	if (state['collisions']['floor_left']['colliding'] and not state['collisions']['floor_right']['colliding']):
		position_y = state['collisions']['floor_left']['position'].y - 20.0
		state['velocity'] = Vector2(0, state['velocity'].y)
	elif (state['collisions']['floor_right']['colliding'] and not state['collisions']['floor_left']['colliding']):
		position_y = state['collisions']['floor_right']['position'].y -  20.0
	elif (state['collisions']['floor_left']['colliding'] and state['collisions']['floor_right']['colliding']):
		position_y = max(state['collisions']['floor_left']['position'].y, state['collisions']['floor_right']['position'].y) - 20.0
	return Vector2(position_x, position_y)

func collision_popout():
	var ceiling_offset = 21
	var position_x = state['host'].position.x
	var position_y = state['host'].position.y
	if state['collisions']['ceiling_left']['colliding'] or state['collisions']['ceiling_left']['colliding']:
		if state['collisions']['ceiling_left']['colliding'] and not state['collisions']['ceiling_right']['colliding']:
			position_y = state['collisions']['ceiling_left']['position'].y + ceiling_offset
		elif state['collisions']['ceiling_right']['colliding'] and not state['collisions']['ceiling_left']['colliding']:
			position_y = state['collisions']['ceiling_right']['position'].y + ceiling_offset
		else:
			position_y = max(state['collisions']['ceiling_left']['position'].y + ceiling_offset, state['collisions']['ceiling_right']['position'].y + ceiling_offset)
	if state['collisions']['wall_left']['colliding']:
		position_x = state['collisions']['wall_left']['position'].x + 11
		if state['ground_speed'] < 0:
			state['velocity'] = Vector2(0, state['velocity'].y)
			state['ground_speed'] = 0.0
	if state['collisions']['wall_right']['colliding']:
		position_x = state['collisions']['wall_right']['position'].x - 11
		state['velocity'] = Vector2(0, state['velocity'].y)
		if state['ground_speed'] > 0:
			state['velocity'] = Vector2(0, state['velocity'].y)
			state['ground_speed'] = 0.0
	var proposed_position = Vector2(position_x, position_y)
	if state['collisions']['move_mode'] == 'ground':
		return ground_popout(proposed_position)
	else:
		return proposed_position

