extends AudioStreamPlayer

var bpm = 180
var margin = 0.25

var secPerBeat
var songPosition
var lastReportedBeat = 0
var songPositionInBeats = 1
var tmpSongPositionInBeats
var tmpVolume = volume_db

signal beat()

func _ready():
	secPerBeat = 60.0 / bpm

func _physics_process(delta):
	if playing:
		songPosition = (get_playback_position() + AudioServer.get_time_since_last_mix()) - AudioServer.get_output_latency()
		tmpSongPositionInBeats = int(floor(songPosition / secPerBeat))
		if tmpSongPositionInBeats < songPositionInBeats:
			lastReportedBeat = 0
			emit_signal("beat", 0)
		songPositionInBeats = tmpSongPositionInBeats
		if lastReportedBeat < songPositionInBeats:
			emit_signal("beat", songPositionInBeats)
			lastReportedBeat = songPositionInBeats

func getBeatCheckResult():
	if playing:
		var songPositionInCurrentBeat = fmod(songPosition / secPerBeat, songPositionInBeats)
		if songPositionInCurrentBeat < margin || songPositionInCurrentBeat > 1.0 - margin:
			return 1
	return 0

func playMute():
	volume_db = -80
	play()

func playUnmute():
	volume_db = tmpVolume
	seek(0.0)
	play()
