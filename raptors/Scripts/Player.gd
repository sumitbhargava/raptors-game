extends KinematicBody2D

export var speed = 200
export var gravity = 600
export var jump_force = 650

var velocity = Vector2.ZERO
var move_dir

var on_ground_timer = 0.0
var soft_grounded = false

onready var sprite = $AnimatedSprite

onready var support = $SupportFinder
onready var support2 = $SupportFinder2


func _ready():
	pass
	
	
func is_on_ground():
	return support.is_colliding() or support2.is_colliding()
	
	
func resolve_support_position():
	if is_on_ground() and velocity.y > 0.0:
		var ground_y = max(support.get_collision_point().y, support2.get_collision_point().y)
		global_position.y = ground_y - support.cast_to.y * -0.2
		velocity.y = 0

func _physics_process(delta):
	velocity.y += gravity * delta
	
	get_input()
	
	resolve_support_position()	
	
	on_ground_timer -= delta
	
	if is_on_ground():
		soft_grounded = true
		on_ground_timer = 0.5
	if on_ground_timer < 0:
		soft_grounded = false
		
	
	velocity = move_and_slide(velocity)


func _input(event):
	if event.is_action_pressed("jump"):
		if soft_grounded:
			jump()
			on_ground_timer = 0
			soft_grounded = false

func jump():
	velocity.y = -jump_force
	velocity.x = move_dir * jump_force * 0.8


func get_input():
	var left = Input.is_action_pressed("move_left")
	var right = Input.is_action_pressed("move_right")
	
	move_dir = int(right) - int(left)
	velocity.x = lerp(velocity.x, speed * move_dir, 0.7 if is_on_ground() else 0.3)
	if not left and not right and is_on_ground():
		velocity.x = 0
	
	if right and sprite.flip_h:
		sprite.set_flip_h(false)
	if left and not sprite.flip_h:
		sprite.set_flip_h(true)


