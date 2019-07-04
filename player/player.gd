extends KinematicBody2D

const max_falling_speed = 960
const max_running_speed = 360
const acceleration = 2.8125
const deceleration = 30
const friction = 2.8125
const top_speed = 6.0
const jump_power = 6.5
const slope_factor = 0.125
const slope_roll_up = 0.78125
const slope_roll_down = 0.3125
const fall = 2.5
const gravity = 13.125

# xpos and ypos are held by KinematicBody2D
var state = "falling"
var wall_collision = "none"
var input = { "left": false, "right": false, "jump": false }
var speed: Vector2 = Vector2(0, 0)
var ground_speed: float = 0.0
var slope: float = 0.0
var ground_angle: float = 0.0

func _physics_process(delta):
	pass



func process_camera_extents(proposed_position):
	var adjusted_position = proposed_position
	if $wall_left.is_colliding() and proposed_position.x < position.x:
		return $wall_left.get_collision_point().x
	if $wall_right.is_colliding() and proposed_position.x > position.x:
		adjusted_position.x = position.x
	return adjusted_position

func ground_movement(delta):
	if input["left"] == true:
		if ground_speed > 0:
			ground_speed -= deceleration
		elif ground_speed > -max_running_speed:
			ground_speed -= acceleration
	elif input["right"] == true:
		if ground_speed < 0:
			ground_speed += deceleration
		elif ground_speed < max_running_speed:
			ground_speed += acceleration
	else:
		ground_speed -= min(abs(ground_speed), friction) * sign(ground_speed)
	var stop = ground_colliders()
	if stop and ground_speed < 0:
		ground_speed = .0
	var new_speed = Vector2(ground_speed * cos(0), ground_speed * -sin(0))
	return new_speed

func air_movement(delta):
	speed.y += gravity
	if speed.y > max_falling_speed:
		speed.y = max_falling_speed
	var adjusted_speed = air_colliders(speed)
	return adjusted_speed

func air_colliders(position_delta):
	var proposed_position = position + position_delta
	var x_adjustment = 0.0
	var y_adjustment = 0.0
	if $floor_right.is_colliding():
		var collision = $shape/floor_right.get_collision_point()
		if collision.y > proposed_position.y - 20:
			y_adjustment = collision.y - proposed_position.y - 20
			print('delta: %, y_adjustment: %', position_delta.y, y_adjustment)
	var adjusted_delta = Vector2(position_delta.x + x_adjustment, position_delta.y + y_adjustment)
	return adjusted_delta
	
func ground_colliders():
	var x_adjustment = 0.0
	var y_adjustment = 0.0
	#$wall_left.set_cast_to(Vector2(position_delta.x - 10.0, position.y))
	#$wall_left.force_raycast_update()
	if $wall_left.is_colliding() or position.x - 9.0 <= 0:
		#wall_collision = "left"
		#var collision = $shape/wall_left.get_collision_point()
		#x_adjustment = collision.x - position_delta.x - 10.0
		#print('x_adjustment: %s', x_adjustment)
		return true
	#var adjusted_delta = Vector2(position_delta.x - x_adjustment, position_delta.y + y_adjustment)
	return false

func update_state():
	var standing = $floor_left.is_colliding() || $floor_right.is_colliding()
	# var balancing = $floor_left.is_colliding() || $floor_right.is_colliding()
	var balancing = false
	if standing:
		state = "standing"
	elif balancing:
		state = "balancing"
	else:
		state = "falling"
	wall_collision = "none"

func update_input():
	input = {
		"left": Input.is_action_pressed("move_left"),
		"right": Input.is_action_pressed("move_right"),
		"jump": Input.is_action_pressed("jump")
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

