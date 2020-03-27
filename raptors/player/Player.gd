extends KinematicBody2D

export var speed = 1000
export var gravity = 1000
export var jump_force = 1000

var velocity = Vector2.ZERO
var move_dir

onready var sprite = $AnimatedSprite


func _ready():
	pass


func _physics_process(delta):
	get_input()
	apply_gravity(delta)
	handle_movement()


func _input(event):
	if event.is_action_pressed("jump"):
		if is_on_floor():
			jump()


func jump():
	velocity.y = -jump_force


func get_input():
	var left = Input.is_action_pressed("move_left")
	var right = Input.is_action_pressed("move_right")
	
	move_dir = int(right) - int(left)
	velocity.x = lerp(velocity.x, speed * move_dir, get_h_weight())
	if not left and not right and is_on_floor():
		velocity.x = 0
	
	if right and sprite.flip_h:
		sprite.set_flip_h(false)
	if left and not sprite.flip_h:
		sprite.set_flip_h(true)


# calculate speed of linear interpolation in get_input()
func get_h_weight():
	return 0.2 if is_on_floor() else 0.1


func handle_movement():
	velocity = move_and_slide(velocity, Vector2.UP)


func apply_gravity(delta):
	velocity.y += gravity * delta
