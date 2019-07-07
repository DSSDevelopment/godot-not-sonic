extends Node

var sensor_collider
var input_handler
var ground_state_integrator
var air_state_integrator
var animation_player
var camera

var idle_anim = 'Idle1'

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
		"jumped": false,
		"braking": false,
		"looking_up": false,
		"looking_down": false,
		"rolling": false,
		"pushing": false
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
	if $"../sprite/animation_player":
		animation_player = $"../sprite/animation_player"
	var initialized = sensor_collider and input_handler and ground_state_integrator and air_state_integrator and animation_player
	if initialized:
		set_physics_process(true)
	else:
		print("ERROR: Unable to initialize movement controller. Missing child node(s).")

func _process(delta):
	if $"/root/world/camera":
		$"/root/world/camera".align()

func _physics_process(delta):
	var collisions_update = sensor_collider.tick(delta, properties, state)
	if state['collisions']['move_mode'] != collisions_update['move_mode']:
		update_move_mode(state['collisions']['move_mode'], collisions_update['move_mode'])
	state['collisions'] = collisions_update
	state['input'] = input_handler.tick(delta, properties, state)
	var floor_normal = Vector2(0, 0)
	if state['collisions']["move_mode"] == "ground":
		state['ground_speed'] = ground_state_integrator.tick(delta, properties, state)
		if state['collisions']['floor_left']['colliding'] and state['collisions']['floor_right']['colliding']:
			floor_normal = state['collisions']['floor_left']['normal'] if state['collisions']['floor_left']['position'].y < state['collisions']['floor_right']['position'].y else state['collisions']['floor_right']['normal']
		elif state['collisions']['floor_left']['colliding'] and not state['collisions']['floor_right']['colliding']:
			floor_normal = state['collisions']['floor_left']['normal']
		elif state['collisions']['floor_right']['colliding'] and not state['collisions']['floor_left']['colliding']:
			floor_normal = state['collisions']['floor_right']['normal']
		state['collisions']['angle'] = floor_normal.angle_to(Vector2(0, -1))
		state['velocity'] = Vector2(state['ground_speed'] * cos(state['collisions']['angle']), state['ground_speed'] * -sin(state['collisions']['angle']))
	else:
		state['velocity'] = air_state_integrator.tick(delta, properties, state)
	var jumping = state['input']['jumped'] and state['flags']['canjump'] and not (state['collisions']['ceiling_left']['colliding'] or state['collisions']['ceiling_right']['colliding'])
	if jumping:
		jump()
	var stick_to_ground = state['collisions']['move_mode'] == 'ground' and (state['collisions']['floor_left']['colliding'] and state['collisions']['floor_right']['colliding'])
	state['host'].move_and_slide(state['velocity'] + (Vector2(0, 1) * 150) if stick_to_ground else state['velocity'])
	animation_step()
	if $"/root/world/camera":
		$"/root/world/camera".update_camera()

func update_move_mode(from, to):
	state['flags']['canjump'] = true if (from == "air" and to == "ground") else false
	if from == "air" and to == "ground":
		state['flags']['jumped'] = false
		state['ground_speed'] = state['velocity'].x
		state['flags']['rolling'] = false

func jump():
	state['velocity'] = Vector2(state['velocity'].x - (properties['jump_power'] * sin(state['collisions']['angle'])), state['velocity'].y - (properties['jump_power'] * cos(state['collisions']['angle'])))
	var new_move_mode = "air"
	update_move_mode(state['collisions']['move_mode'], new_move_mode)
	state['collisions']['move_mode'] = new_move_mode
	state['flags']['jumped'] = true
	state['flags']['rolling'] = true

func animation_step():
	var anim_name = idle_anim
	var anim_speed = 1.0
	var abs_gsp = abs(state['ground_speed'])
	var play_once = false
	
	var moving_in_air = state['collisions']['move_mode'] == 'air' and abs(state['velocity']['x']) > .1
	var walking_on_ground =  abs_gsp > .1 and !state['flags']['braking']
	if moving_in_air or walking_on_ground:
		idle_anim = 'Idle1'
		if !state['flags']['rolling']:
			anim_name = 'Walk'
			if abs_gsp >= 360:
 				anim_name = 'Run'
			anim_speed = max(-(8.0 / 60.0 - (abs_gsp / 120.0)), 1.0)
		else:
			anim_speed = max(2.0, -((5.0 / 60.0) - (abs_gsp / 120.0)))
		
		if Input.is_action_pressed("ui_right"):
			$"../sprite".scale.x = 1
		elif Input.is_action_pressed("ui_left"):
			$"../sprite".scale.x = -1
	elif state['flags']['braking']:
		anim_name = 'Brake'
		anim_speed = 1.0
	else:
		if state['flags']['looking_down']:
			idle_anim = 'Idle1'
			anim_name = 'LookDown'
			play_once = true
		elif state['flags']['looking_up']:
			idle_anim = 'Idle1'
			anim_name = 'LookUp'
			play_once = true
		elif state['flags']['pushing']:
			idle_anim = 'Idle1'
			anim_name = 'Pushing'
	if state['flags']['rolling']:
		anim_name = 'Roll'
		anim_speed = 2.0
	
	animation_player.animate(anim_name, anim_speed, play_once)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == 'Brake':
		state['flags']['braking'] = false
	if anim_name == 'Idle1':
		idle_anim = 'Idle2'
