extends Node

var sensors

func _ready():
	var wall_sensor_left = $'../../wall_sensor_left'
	var wall_sensor_right = $'../../wall_sensor_right'
	var ceiling_sensor_left = $'../../ceiling_sensor_left'
	var ceiling_sensor_right = $'../../ceiling_sensor_right'
	var floor_sensor_left = $'../../floor_sensor_left'
	var floor_sensor_right = $'../../floor_sensor_right'
	var validSensors = wall_sensor_left and wall_sensor_right and ceiling_sensor_left and ceiling_sensor_right and floor_sensor_left and floor_sensor_right
	if validSensors == false:
		print("ERROR: Missing one or more player collision sensors.")
		return
	sensors = {
		"wall_left": wall_sensor_left,
		"wall_right": wall_sensor_right,
		"ceiling_left": ceiling_sensor_left,
		"ceiling_right": ceiling_sensor_right,
		"floor_left": floor_sensor_left,
		"floor_right": floor_sensor_right
	}

func tick(delta, props, state):
	#TODO: figure out which sensors to use given ground mode derived from angle
	var flat_ground = state['angle'] == 0 or state['angle'] == -90
	for sensor in [sensors['floor_left'], sensors['floor_right']]:
		sensor.set_position(Vector2(sensor.position.x, 8.0 if flat_ground else 0.0))
	
	for sensor in sensors:
		state['collisions'][sensor] = {
			'colliding': sensors[sensor].is_colliding(),
			'position': sensors[sensor].get_collision_point(),
			'normal': sensors[sensor].get_collision_normal()
		}
	
	if not state['collisions']['floor_left']['colliding'] and not state['collisions']['floor_right']['colliding']:
		state['movement_mode'] = 'air'
