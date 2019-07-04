extends Camera2D

const X_AXIS_TOLERANCE = 16
const LEFT = -16.0
const RIGHT = 0.0
const Y_AXIS_TOLERANCE = 48.0
export(float) var AIR_TOP = 48
export(float) var AIR_BOTTOM = -16
const VIEWPORT_WIDTH_HALF = 200
const VIEWPORT_HEIGHT_HALF = 114

var player

func set_player(player):
	self.player = player

func update_camera():
	if player == null:
		return
	var proposed_position = position
	if player.position.x < position.x + LEFT:
		proposed_position.x = player.position.x - LEFT#, -X_AXIS_TOLERANCE)
	elif player.position.x > position.x + RIGHT:
		proposed_position.x = player.position.x - RIGHT#, X_AXIS_TOLERANCE)
	if player.position.y < position.y - AIR_TOP:
		proposed_position.y += max(player.position.y - (position.y - AIR_TOP), -16)
	elif player.position.y > position.y + AIR_BOTTOM:
		proposed_position.y += min(player.position.y - (position.y + AIR_BOTTOM), 16)
	var updated_position = position_for_camera_extents(proposed_position)
	set_position(Vector2(round(updated_position.x), round(updated_position.y)))

func position_for_camera_extents(proposed_position):
	if $top_extents.is_colliding() and proposed_position.y > position.y:
		proposed_position.y = position.y
	if $left_extents.is_colliding() and proposed_position.x < position.x:
		proposed_position.x = position.x
	if $bottom_extents.is_colliding() and proposed_position.y < position.y:
		proposed_position.y = position.y
	if $right_extents.is_colliding() and proposed_position.x > position.x:
		proposed_position.x = position.x
	return proposed_position

func resize():
	var new_size = get_viewport().size
	$left_extents.set_cast_to(Vector2(-new_size.x * 0.5, 0))
	$right_extents.set_cast_to(Vector2(new_size.x * 0.5, 0))
	$top_extents.set_cast_to(Vector2(0, -new_size.y * 0.5))
	$bottom_extents.set_cast_to(Vector2(0, new_size.y * 0.5))

func _ready():
	get_tree().get_root().connect("size_changed", self, "resize")