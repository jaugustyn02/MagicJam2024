extends AudioStreamPlayer

var tempo_music_loads = {}
var multiplier_to_index = {0.5: 1, 0.67: 2, 1.0:3, 1.5: 4, 2.0: 5}
var multiplier_tempo = {1: 0.8, 2 : 0.9, 3: 1.0, 4: 1.1, 5: 1.2}
var timestampt = 0.0
var previous_index = 3

func _ready():
	tempo_music_loads[1] = load("res://resources/soundtracks/psycho_0_8.ogg")
	tempo_music_loads[2] = load("res://resources/soundtracks/psycho_0_9.ogg")
	tempo_music_loads[3] = load("res://resources/soundtracks/psycho_1_0.ogg")
	tempo_music_loads[4] = load("res://resources/soundtracks/psycho_1_1.ogg")
	tempo_music_loads[5] = load("res://resources/soundtracks/psycho_1_2.ogg")
	stream = tempo_music_loads[3]
	play()
	
	
func on_time_multiplier_changed(multiplier):
	var index = multiplier_to_index[multiplier]
	timestampt = get_playback_position()
	timestampt *= multiplier_tempo[previous_index]
	timestampt /= multiplier_tempo[index]
	stream = tempo_music_loads[index]
	play()
	seek(timestampt)
	previous_index = index
