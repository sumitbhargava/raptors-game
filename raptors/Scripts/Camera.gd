extends Camera2D

export(NodePath) var target_path

var target = null

onready var track_offset = $target_offset

func _ready():
	target = get_node_or_null(target_path)
	
func _process(delta):
	if target:
		global_position.x = target.global_position.x
		global_position.y = target.global_position.y - track_offset.position.y
