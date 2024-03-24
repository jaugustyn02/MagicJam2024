extends Control

signal time_multiplier_changed(time_multiplier)
signal gear_changed(gear)

const time_multipliers = {1: 0.5, 2: 0.67, 3: 1.0, 4: 1.5, 5: 2.0}
const absolute_gear_actions = {"gear_1": 1, "gear_2": 2, "gear_3": 3, "gear_4": 4, "gear_5": 5}
const min_gear = 1
const max_gear = 5

var time_gear = 3
var time_multiplier = 1.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	change_gear()
	
	
func change_gear():
	var prev_time_gear = time_gear
	if Input.is_action_just_pressed("gear_up"):
		time_gear = min(time_gear + 1, max_gear)
		
	if Input.is_action_just_pressed("gear_down"):
		time_gear = max(time_gear - 1, min_gear)
		
	for gear_action in absolute_gear_actions:
		if Input.is_action_just_pressed(gear_action):
			time_gear = absolute_gear_actions[gear_action]
			
	time_multiplier = time_multipliers[time_gear]
	
	if prev_time_gear != time_gear:
		time_multiplier_changed.emit(time_multipliers[time_gear])
		gear_changed.emit(time_gear)
