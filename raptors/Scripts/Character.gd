extends KinematicBody2D

enum State {
	IDLE,
	WALK,
	JUMP,
	FALL,
	ATTACK,
	DEAD
}

export var speed = 200
export var gravity = 600
export var jump_force = 580

var velocity = Vector2.ZERO
var boost = Vector2.ZERO
var move_dir
var facing_dir = 1

var on_ground_timer = 0.0
var soft_grounded = false

var state = State.IDLE

onready var sprite = $AnimatedSprite
onready var support = $SupportFinder
onready var support2 = $SupportFinder2
onready var obj_detector = $ObjectDetector
onready var obj_detector_shape = $ObjectDetector/CollisionShape2D


func _ready():
	pass
	
func is_on_ground():
	return support.is_colliding() or support2.is_colliding()
	
#Todo: Change to Area, cuz 2 raycast aren't enought for skinny colliders
func resolve_support_position():
	if is_on_ground() and velocity.y > 0.0:
		var ground_y = max(support.get_collision_point().y, support2.get_collision_point().y)
		if ground_y > global_position.y:
			global_position.y = ground_y - support.cast_to.y * -0.2
			velocity.y = 0

func _physics_process(delta):
	velocity.y += gravity * delta
	
	if is_on_ground() and velocity.y > 0:
		velocity.y = 0
	
	process_input()
	
	resolve_support_position()
	
	
	on_ground_timer -= delta
	
	if is_on_ground():
		soft_grounded = true
		on_ground_timer = 0.5
	if on_ground_timer < 0:
		soft_grounded = false
		
	process_state(delta)
		
	
	#velocity = move_and_slide(velocity)
	#move_and_collide(velocity * delta)
	move_and_slide(velocity + boost)
	boost = boost * delta * delta

func _input(event):
	if Input.is_action_pressed("attack"):
		transition_state(State.ATTACK)
	
	if event.is_action_pressed("jump"):
		if soft_grounded and not velocity.y < 0:
			transition_state(State.JUMP)
			on_ground_timer = 0
			soft_grounded = false

func jump():
	velocity.y = -jump_force * max(int(not(abs(move_dir))), 0.9)
	velocity.x += move_dir * jump_force * 0.2

func process_input():
	var left = 0
	var right = 0
	
	move_dir = int(right) - int(left)
	if soft_grounded and not velocity.y < 0:
		velocity.x = lerp(velocity.x, speed * move_dir, 0.7)
	else:
		if velocity.y > 0:
			velocity.x = lerp(velocity.x, speed * move_dir, 0.05)
		
	if move_dir:
		facing_dir = move_dir
	
	if right and sprite.flip_h:
		sprite.set_flip_h(false)
	if left and not sprite.flip_h:
		sprite.set_flip_h(true)
		
func transition_state(goal):
	match state:
		State.IDLE, State.WALK:
			if goal == State.JUMP:
				jump()
			state = goal
		State.JUMP:
			pass
		State.FALL:
			if sprite.animation == "fall" and not sprite.frame == 21: #sprite.is_playing's broke 
				return
			state = goal
		State.ATTACK:
			pass
		_:
			pass

func process_state(delta):
	match state:
		State.IDLE:
			if abs(velocity.x) > 0.2:
				state = State.WALK
		State.WALK:
			if abs(velocity.x) < 0.2:
				state = State.IDLE
			sprite.play("walk")
		State.JUMP:
			if velocity.y > 0.1:
				state = State.FALL
			if sprite.animation != "jump":
				sprite.play("jump")
		State.FALL:
			if not is_on_ground():
				sprite.play("falling")
			else:
				if sprite.animation != "fall":
					sprite.play("fall")
				transition_state(State.IDLE)
		State.ATTACK:
			if sprite.animation != "attack":
				sprite.play("attack")
			elif not sprite.playing:
				state = State.IDLE
		_:
			pass
