extends AudioStreamPlayer

var bpm = 180
var margin = 0.2

var secPerBeat
var songPosition
var lastReportedBeat = 0
var songPositionInBeats = 1
var tmpSongPositionInBeats
var tmpVolume

signal beat(position)

func _ready():
	secPerBeat = 60.0 / bpm
	tmpVolume = volume_db
	volume_db = 0

func _physics_process(delta):
	if playing:
		songPosition = (get_playback_position() + AudioServer.get_time_since_last_mix()) - AudioServer.get_output_latency()
		tmpSongPositionInBeats = int(floor(songPosition / secPerBeat))
		if tmpSongPositionInBeats < songPositionInBeats:
			lastReportedBeat = 0
		songPositionInBeats = tmpSongPositionInBeats
		if lastReportedBeat < songPositionInBeats:
			emit_signal("beat", songPositionInBeats)
			lastReportedBeat = songPositionInBeats

func getBeatCheckResult(measure):
	if playing:
		var songPositionInCurrentBeat = fmod(songPosition / secPerBeat, songPositionInBeats)
		if songPositionInCurrentBeat < margin || songPositionInCurrentBeat > 1.0 - margin:
			return 1
	return 0
