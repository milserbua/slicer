extends Node

class_name AudioManager

var master_volume = 1.0
var effects_volume = 1.0
var music_volume = 0.8

func _ready():
	name = "AudioManager"
	add_to_group("audio_manager")
	set_process_mode(PROCESS_MODE_ALWAYS)

func play_sound(sound_name: String, pitch_variation = 0.1):
	var audio_player = AudioStreamPlayer3D.new()
	add_child(audio_player)
	
	match sound_name:
		"cut":
			audio_player.pitch_scale = randf_range(1.5 - pitch_variation, 1.5 + pitch_variation)
			audio_player.volume_db = -5
		"jump":
			audio_player.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
			audio_player.volume_db = -10
		"land":
			audio_player.pitch_scale = randf_range(0.8 - pitch_variation, 0.8 + pitch_variation)
			audio_player.volume_db = -8
		"gameover":
			audio_player.pitch_scale = 0.8
			audio_player.volume_db = 0
	
	await get_tree().create_timer(0.1).timeout
	audio_player.queue_free()

func set_master_volume(value: float):
	master_volume = clamp(value, 0.0, 1.0)
	if AudioServer.get_bus_count() > 0:
		AudioServer.set_bus_volume_db(0, linear_to_db(master_volume))

func set_effects_volume(value: float):
	effects_volume = clamp(value, 0.0, 1.0)

func set_music_volume(value: float):
	music_volume = clamp(value, 0.0, 1.0)
