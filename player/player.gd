extends KinematicBody2D

const max_falling_speed = 960
const max_running_speed = 360
const acceleration = 2.8125
const deceleration = 0.5
const friction = 2.8125
const top_speed = 6.0
const jump_power = 6.5
const slope_factor = 0.125
const slope_roll_up = 0.78125
const slope_roll_down = 0.3125
const fall = 2.5
const gravity = 13.125


# xpos and ypos are held by KinematicBody2D
var state = "standing"
var input = { "left": false, "right": false, "jump": false }
var speed: Vector2 = Vector2(0, 0)
var ground_speed: float = 0.0
var slope: float = 0.0
var ground_angle: float = 0.0

func _physics_process(delta):
	update_state()
	update_input()
	var new_speed = speed
	if state == "standing" or state == "balancing":
		new_speed = ground_movement(delta)
	elif state == "falling":
		new_speed = air_movement(delta)
	move_and_collide(new_speed)
	speed = new_speed
	
func ground_movement(delta):
	speed.y = 0
	if input["left"] == true:
		ground_speed -= acceleration * delta
	if input["right"] == true:
		ground_speed += acceleration * delta
	if input["left"] == false && input["right"] == false:
		if ground_speed < 0:
			if ground_speed > -(friction * delta):
				ground_speed = 0
			else:
				ground_speed += friction * delta
		else:
			if ground_speed < friction * delta:
				ground_speed = 0
			else:
				ground_speed -= friction *delta
	if ground_speed > max_running_speed:
		ground_speed = max_running_speed
	var new_speed = Vector2(ground_speed * cos(0), ground_speed * -sin(0))
	return new_speed

func air_movement(delta):
	speed.y += gravity * delta
	if speed.y > max_falling_speed:
		speed.y = max_falling_speed
	return speed

func update_state():
	var standing = $floor_left.is_colliding() && $floor_right.is_colliding()
	var balancing = $floor_left.is_colliding() || $floor_right.is_colliding()
	if standing:
		state = "standing"
	elif balancing:
		state = "balancing"
	else:
		state = "falling"

func update_input():
	input = {
		"left": Input.is_action_pressed("move_left"),
		"right": Input.is_action_pressed("move_right"),
		"jump": Input.is_action_pressed("jump")
	}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

