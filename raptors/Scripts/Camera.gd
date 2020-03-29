extends Camera2D

export(NodePath) var target_path

var target = null

var prev = Vector2()
var goal = Vector2()


onready var track_offset = $target_offset

func _ready():
	target = get_node_or_null(target_path)
	
func _process(delta):
	if target:
		goal = Vector2(target.global_position.x, target.global_position.y - track_offset.position.y)
		var dir = goal - prev
		global_position.x = lerp(global_position.x, goal.x, 0.1)
		dir.y = max(-2, dir.y)
		global_position.y = lerp(global_position.y, goal.y + dir.y * 20, 0.2)
		prev = goal
