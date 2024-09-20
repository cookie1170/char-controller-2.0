extends CharacterBody2D
class_name Player


# movement variables
@export var jump_height: float
@export var time_peak: float
@export var time_fall: float
@export var speed: float
@export var accel_time: float

# math
@onready var jump_vel: float = ((2.0 * jump_height) / time_peak) * -1.0
@onready var jump_grav: float = ((-2.0 * jump_height) / (time_peak * time_peak)) * -1.0
@onready var fall_grav: float = ((-2.0 * jump_height) / (time_fall * time_fall)) * -1.0
@onready var accel: float = speed / accel_time
