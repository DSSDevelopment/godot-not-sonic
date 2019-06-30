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
	"jump_power": 6.5,
	"slope_factor": 0.125,
	"slope_roll_up": 0.78125,
	"slope_roll_down": 0.3125,
	"fall": 2.5,
	"gravity": 13.125
}

var state = {
	"host": null,
	"input": {
		"jump": false,
		"direction": 0
	},
	"velocity": Vector2(0, 0),
	"angle": 0,
	"collisions": {
		"wall_left": {"colliding": false, "position": Vector2(0, 0), "normal": Vector2(0, 0)},
		"wall_right": {"colliding": false, "position": Vector2(0, 0), "normal": Vector2(0, 0)},
		"ceiling_left": {"colliding": false, "position": Vector2(0, 0), "normal": Vector2(0, 0)},
		"ceiling_right": {"colliding": false, "position": Vector2(0, 0), "normal": Vector2(0, 0)},
		"floor_left": {"colliding": false, "position": Vector2(0, 0), "normal": Vector2(0, 0)},
		"floor_right": {"colliding": false, "position": Vector2(0, 0), "normal": Vector2(0, 0)}
	},
	"move_mode": "ground"
}

func _ready():
	set_physics_process(false)
	state["host"] = get_parent()
	if $"./sensor_collider":
		sensor_collider = $"./sensor_collider"
	if $"./input_handler":
		input_handler = $"./input_handler"
	if $"./ground_state_integrator":
		ground_state_integrator = $"./ground_state_integrator"
	if $"./air_state_integrator":
		air_state_integrator = $"./air_state_integrator"
	var initialized = sensor_collider and input_handler and ground_state_integrator and air_state_integrator
	if initialized:
		
		set_physics_process(true)
	else:
		print("ERROR: Unable to initialize movement controller. Missing child node(s).")

func _physics_process(delta):
	sensor_collider.tick(delta, properties, state)
	input_handler.tick(delta, properties, state)
	if state["move_mode"] == "ground":
		ground_state_integrator.tick(delta, properties, state)
	else:
		air_state_integrator.tick(delta, properties, state)
