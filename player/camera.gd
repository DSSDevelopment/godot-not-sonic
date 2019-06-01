extends Camera2D

const X_AXIS_TOLERANCE = 9.0
const Y_AXIS_TOLARANCE = 38.0

var player

func set_player(player):
	self.player = player

func _physics_process(delta):
	if player == null:
		return
	var player_position = player.position
	var player_screen_position = Vector2(position.x - player_position.x, player_position.y - position.y)
	if player_screen_position.x < -X_AXIS_TOLERANCE:
		position = Vector2(player_position.x - X_AXIS_TOLERANCE, position.y)
	elif player_screen_position.x > X_AXIS_TOLERANCE:
		position = Vector2(player_position.x + X_AXIS_TOLERANCE, position.y)

func _ready():
	set_physics_process(true)