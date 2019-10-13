extends Control

onready var power_progress = $right/power/progress
onready var time_progress = $top/time/progress
onready var time_anim = $top/time/time_anim
onready var score = $top/score/score
onready var coins = $right/power/coins

var game_time = 0
const P_PROGRESS_SIZE_INIT = Vector2(80, 24)
const P_PROGRESS_SIZE_MAX = Vector2(80, 256)
const P_PROGRESS_SIZE_INC = Vector2(0, 12)
const T_PROGRESS_SIZE_INIT = Vector2(386, 32)
const T_PROGRESS_SIZE_MAX = Vector2(386, 32)
const T_PROGRESS_SIZE_MIN = Vector2(24, 32)

func _ready():
	add_to_group("gui")
	$loading.show()

func power_inc():
	if power_progress.rect_size < P_PROGRESS_SIZE_MAX:
		power_progress.rect_size += P_PROGRESS_SIZE_INC

func power_reset():
	power_progress.rect_size = P_PROGRESS_SIZE_INIT
	
func score_set(s):
	score.set_text(str(s))

func coins_set(c):
	coins.set_text(str(c))

func start_game():
	$"top/time/time".start_timer(180)
	$"loading".hide()

func time_set(t):
	var t_percent = t * 100 / game_time
	if t_percent < 10:
		time_anim.play("ping")
	var tp_width = (T_PROGRESS_SIZE_MAX.x * t_percent) / 100 
	if tp_width < T_PROGRESS_SIZE_MIN.x: tp_width = T_PROGRESS_SIZE_MIN.x
	time_progress.rect_size = Vector2(tp_width, T_PROGRESS_SIZE_MIN.y)

func time_reset(gt):
	time_progress.rect_size = T_PROGRESS_SIZE_INIT
	game_time = gt
	
func show_game_over():
	$game_over.show()
