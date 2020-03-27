extends Area2D

onready var infobox = $"../HUD/CanvasLayer/InfoBox"
var die = false

export var die_timer = 2
export(String) var text = ""

func _ready():
	connect("body_entered", self, "body_entered")
	connect("body_exited", self, "ativate_die_timer")
	
func _process(delta):
	if die:
		die_timer -= delta 
	if die_timer < 0:
		infobox.visible = false
		queue_free()
	
func body_entered(body):
	infobox.visible = true
	infobox.get_node("Label").set_text(text)
	
func ativate_die_timer(body):
	die = true
