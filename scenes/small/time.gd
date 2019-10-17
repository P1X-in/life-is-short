extends Label

var time_start = 0
var time_end = 0
var time_now = 0
var timer_enabled = false

func _ready():
	pass

func start_timer(game_time):
	time_end = OS.get_unix_time() + game_time
	timer_enabled = true
	get_tree().call_group("gui", "time_reset", game_time)
	set_process(true)

func _process(delta):
	if timer_enabled:
		time_now = OS.get_unix_time()
		var elapsed = time_end - time_now
		if elapsed <= 0:
			get_tree().call_group("game", "time_elapsed", "Time left")
			timer_enabled = false
		get_tree().call_group("gui", "time_set", elapsed)
		var minutes = elapsed / 60
		var seconds = elapsed % 60
		var str_elapsed = "%02d:%02d" % [minutes, seconds]
		set_text(str_elapsed)
	else:
		set_text("00:00")
