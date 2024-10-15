extends CharacterBody2D
class_name Player


## movement variables
@export var jump_height : float
@export var time_peak : float
@export var time_fall : float
@export var speed : float
@export var accel_time : float

## math
@onready var jump_vel : float = ((2.0 * jump_height) / time_peak) * -1.0
@onready var jump_grav : float = ((-2.0 * jump_height) / (time_peak * time_peak)) * -1.0
@onready var fall_grav : float = ((-2.0 * jump_height) / (time_fall * time_fall)) * -1.0
@onready var accel : float = speed / accel_time


## nodes
@onready var sprite : Sprite2D = $Sprite
@onready var jump_buffer : Timer = $JumpBuffer
@onready var coyote_timer : Timer = $CoyoteTimer
@onready var ledge_block : RayCast2D = $LedgeGrabRaycasts/HorizontalBlock
@onready var ledge_hor : RayCast2D = $LedgeGrabRaycasts/HorizontalRaycast
@onready var ledge_ver : RayCast2D = $LedgeGrabRaycasts/VerticalRaycast


## other variables
var grav_mult : float = 1.0
var direction : int = 0
var jump_buffered : bool = false
var can_jump : bool = true


func _physics_process(delta):

	## accelerate towards input direction

	velocity.x = move_toward(velocity.x, Input.get_axis('left', 'right') * speed, accel * delta)

	if Input.is_action_just_pressed('left'):
		sprite.flip_h = true
	
	if Input.is_action_just_pressed('right'):
		sprite.flip_h = false

	## adds gravity

	if not is_on_floor():
		velocity.y += get_grav() * grav_mult * delta

	## jump with jump buffering and coyote time

	if is_on_floor(): can_jump = true

	if not is_on_floor() and coyote_timer.is_stopped():
		coyote_timer.start()

	if Input.is_action_just_pressed('jump'):
		jump_buffered = true
		jump_buffer.start()

	if can_jump and jump_buffered: jump()


	if get_ledge_pos() != Vector2(0, 0):
		$LedgeMarkerTemp.global_position = get_ledge_pos()
		$LedgeMarkerTemp.visible = true
	else:
		$LedgeMarkerTemp.visible = false	

	
	## slow for testing
	if Input.is_action_just_pressed('slow'):
		if Engine.time_scale == 1:
			Engine.time_scale = 0.5
		else:
			Engine.time_scale = 1


	move_and_slide()


func jump() -> void:
	velocity.y = jump_vel


func get_grav() -> float:
	## makes it so you use fall gravity only if you're well falling
	return jump_grav if velocity.y < 0 else fall_grav


func get_grav_mult() -> float:
	if not Input.is_action_pressed('down'):
		return 0.5 if velocity.y in range(-20, 20) else 1.0
	else:
		return 1.5
	

func get_ledge_pos() -> Vector2:
	var ledge_pos = Vector2.ZERO

	$LedgeGrabRaycasts.scale.x = 1.0 if not sprite.flip_h else -1.0

	if ledge_hor.is_colliding():

		ledge_ver.global_position.x = ledge_hor.get_collision_point().x
		
		if not ledge_block.is_colliding():
			ledge_pos = ledge_ver.get_collision_point()
		if ledge_block.is_colliding():
			ledge_pos = Vector2.ZERO
	else:
		ledge_pos = Vector2.ZERO
	

	return ledge_pos


func _on_jump_buffer_timeout() -> void:
	jump_buffered = false


func _on_coyote_timeout() -> void:
	can_jump = false
