extends Control

onready var power_progress = $right/power/progress
onready var time_progress = $top/time/progress
onready var time_anim = $top/time/time_anim
onready var score = $top/score/score
onready var coins = $right/power/coins


const P_PROGRESS_SIZE_INIT = Vector2(80, 24)
const P_PROGRESS_SIZE_MAX = Vector2(80, 256)
const P_PROGRESS_SIZE_MIN = Vector2(80, 24)

const T_PROGRESS_SIZE_INIT = Vector2(386, 32)
const T_PROGRESS_SIZE_MAX = Vector2(386, 32)
const T_PROGRESS_SIZE_MIN = Vector2(24, 32)

var game_time = 0
var tornado_req = 0
var last_score = 0

func _ready():
	add_to_group("gui")
	$loading.show()

func power_set(p, pmax):
	var p_percent = p * 100 / pmax
	var pp_height = (P_PROGRESS_SIZE_MAX.y * p_percent) / 100 
	if pp_height > P_PROGRESS_SIZE_MAX.y: pp_height = P_PROGRESS_SIZE_MAX.y
	power_progress.rect_size = Vector2(T_PROGRESS_SIZE_MIN.x, pp_height)
	if p_percent >= tornado_req:
		$right/power/button.show()
	else:
		$right/power/button.hide()
	
	if p_percent >= 90:
		$right/power/anim_power.play("pulse")
	else:
		$right/power/anim_power.stop()
		
func power_reset(tornado):
	power_progress.rect_size = P_PROGRESS_SIZE_INIT
	tornado_req = tornado

func score_set(s):
	score.set_text(str(s))
	last_score = s

func coins_set(c):
	coins.set_text(str(c))

func life_set(l):
	var shelf = $top/lives/shelf
	if l >= 0 and l < shelf.get_child_count():
		shelf.get_node(str(l)).get_node("on").hide()
	
func start_game():
	$"top/time/time".start_timer(180)
	$"loading".hide()

func time_set(t):
	var t_percent = t * 100 / game_time
	if t_percent < 25:
		time_anim.play("ping")
	var tp_width = (T_PROGRESS_SIZE_MAX.x * t_percent) / 100 
	if tp_width < T_PROGRESS_SIZE_MIN.x: tp_width = T_PROGRESS_SIZE_MIN.x
	time_progress.rect_size = Vector2(tp_width, T_PROGRESS_SIZE_MIN.y)

func time_reset(gt):
	time_progress.rect_size = T_PROGRESS_SIZE_INIT
	game_time = gt

func show_game_over(msg):
	$game_over/score/stats/score.set_text(str(last_score))
	$game_over/score/_gameover.set_text(msg)
	$game_over.show()
	$game_over/menu/menu/play.grab_focus()
