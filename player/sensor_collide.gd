extends Node

var sensors

func _ready():
	var wall_sensor_left = $'../wall_left'
	var wall_sensor_right = $'../wall_right'
	var ceiling_sensor_left = $'../ceiling_left'
	var ceiling_sensor_right = $'../ceiling_right'
	var floor_sensor_left = $'../floor_left'
	var floor_sensor_right = $'../floor_right'
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
	var collisions = state['collisions'].duplicate()
	var flat_ground = state['collisions']['angle'] == 0 or state['collisions']['angle'] == -90
	for sensor in [sensors['wall_left'], sensors['wall_right']]:
    	sensor.set_position(Vector2(sensor.position.x, 8.0 if (flat_ground and collisions['move_mode'] == 'ground') else 0.0))
	
	for sensor in sensors:
		collisions[sensor] = {
			'colliding': sensors[sensor].is_colliding(),
			'position': sensors[sensor].get_collision_point(),
			'normal': sensors[sensor].get_collision_normal()
		}
	if not collisions['floor_left']['colliding'] and not collisions['floor_right']['colliding']:
		collisions['move_mode'] = 'air'
	elif state['velocity'].y > 0:
		if (collisions['floor_left']['colliding'] and state['host']['position'].y + 20 > collisions['floor_left']['position'].y) or (collisions['floor_right']['colliding'] and state['host']['position'].y + 20 > collisions['floor_right']['position'].y):
			collisions['move_mode'] = 'ground'
	return collisions
