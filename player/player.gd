extends CharacterBody2D
class_name Player


## movement variable exports
@export_group('Movement variables')
@export var jump_height : float
@export var peak_time_sec : float
@export var fall_time_sec : float
@export var terminal_velocity : float
@export var speed : float
@export var accel_time_sec : float
@export var decel_time_sec : float

## math
@onready var jump_vel : float = (2.0 * jump_height) / peak_time_sec
@onready var jump_grav : float = (-2.0 * jump_height) / (peak_time_sec ** 2)
@onready var fall_grav : float = (-2.0 * jump_height) / (fall_time_sec ** 2)
@onready var accel : float = speed / accel_time_sec
@onready var decel : float = speed / decel_time_sec

## nodes
@onready var coyote_timer : Timer = %CoyoteTimer
@onready var collision_feet : CollisionShape2D = %CollisionBoxFeet

## other variables
var can_jump : bool


# processes physics (duh)
func _physics_process(delta: float) -> void:

	# sets the can_jump variable to true if you're on floor
	if is_on_floor():
		can_jump = true
	
	# sets gravity variable to equal jump gravity if you're going up
	# and fall gravity if you're going down
	var gravity = jump_grav if velocity.y < 0 else fall_grav
	
	# apply gravity
	if not is_on_floor() and velocity.y <= terminal_velocity:
		velocity.y += gravity * delta
	
	# start the coyote timer if you're not on floor and you can jump
	if not is_on_floor() and can_jump and coyote_timer.is_stopped():
		coyote_timer.start()

	# makes it so the feet collision box is only active while you're on the ground or falling
	if not is_on_floor() and velocity.y <= 0:
		collision_feet.disabled = true
	if is_on_floor() or velocity.y > 0:
		collision_feet.disabled = false	

	# makes it so you can't go above terminal velocity
	if velocity.y > terminal_velocity:
		velocity.y = terminal_velocity
	
	var direction = Input.get_axis('left', 'right') # gets the input direction
	
	# accelerates you towards your speed times your input direction (between 1 and -1)
	if direction:
		velocity.x = move_toward(velocity.x, speed * direction, accel * delta)
	# decelerates you if direction is null (equal to 0)
	else:
		velocity.x = move_toward(velocity.x, 0, decel * delta)

	# makes you jump if you press the jump button
	if Input.is_action_just_pressed('jump') and can_jump:
		jump()

	move_and_slide() # move and slide makes the player move


# sets your velocity to the jump velocity if called
func jump():
	velocity.y = jump_vel
	can_jump = false


# set can_jump to false if you run out of coyote time
func _on_coyote_timeout() -> void:
	can_jump = false
