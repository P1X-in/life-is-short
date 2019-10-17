extends "res://vendors/p1x/gamepad_3d_controller/controller.gd"

var coin = preload("res://models/coin/coin.gd")
var shroom = preload("res://models/shroom/shroom.gd")
var tree = preload("res://models/forest/tree.gd")
var arcade = preload("res://models/arcade.gd")
var amiga = preload("res://models/amiga/amiga.gd")
var bomb = preload("res://models/bombs/bomb.gd")

export var initial_size = 1.0

var accumulated_delta = 0.0
var size = 1.0
var lives = 4.0
const SIZE_LIMIT = 4.0
const TIME_LIMIT = 120
const SIZE_GAIN = .5
const GAME_TIME = 180

var coins_count = 0
var score = 0
var power = 0
var tornado_enabled = false

const POWER_MAX = 100
const POWER_REQ_TORNADO = 50
const POWER_SHROOM = 20
const POWER_COIN = 2

const SCORE_COIN = 10
const SCORE_SHROOM = 50
const SCORE_FALL = 100
const SCORE_ARCADE = 500
const SCORE_DETONATE_BOMB = 1000

const DAMAGE_ENEMY = 1.0
const DAMAGE_BOMB = 1.5
const DAMAGE_OVERDOSE = 0.5

const SPAWN_COINS_AMOUNT = 12

onready var clouds = get_parent().get_node("clouds")

func _ready():
	._ready()
	self.size = self.initial_size
	self.set_scale(Vector3(self.size, self.size, self.size))
	get_tree().call_group("gui", "power_reset", POWER_REQ_TORNADO)

onready var sounds = $"sounds/movement"

func _physics_process(delta):
	if not self.controller_enabled:
		return

	self.accumulated_delta += delta * 10
	if self.accumulated_delta > 2.0 * PI:
		self.accumulated_delta -= 2.0 * PI

	if self.is_moving:
		clouds.translation = Vector3(self.translation.x, clouds.translation.y, self.translation.z)
		get_tree().call_group("gui", "compass_set", -self.rotation.y)
		if not self.sounds.playing:
			self.sounds.play(randf()*4.0)
	else:
		self.sounds.stop()
	
	self.raycast.cast_to = Vector3(0, -1 * self.size, self.camera_max_distance * self.size)
	
	if power >= POWER_REQ_TORNADO and Input.is_joy_button_pressed(device_id, JOY_BUTTON_0):
		self.tornado_power_start()

func process_body_collision(collision):
	if collision.collider is self.coin:
		self.pick_up_coin(collision.collider)
	if collision.collider is self.shroom:
		self.eat_shroom(collision.collider)
	if collision.collider is self.tree:
		self.bump_tree(collision.collider)
	if collision.collider is self.arcade:
		self.run_arcade(collision.collider)
	if collision.collider is self.amiga:
		self.hit_amiga(collision.collider)
	if collision.collider is self.bomb:
		self.activate_bomb(collision.collider)

func get_speed(factor):
	var sine_variance = (sin(self.accumulated_delta) + 1.0) / 4.0 + 0.5
	return self.move_max_speed * factor * sine_variance

func pick_up_coin(coin):
	if coin.is_used(): return
	if tornado_enabled: 
		coin.destroy()
		return 
	coin.pick_up()
	coins_count += 1
	score_inc(SCORE_COIN)
	power_inc(POWER_COIN)
	get_tree().call_group("gui", "coins_set", coins_count) 
	Input.start_joy_vibration(0, 0.1, 0.1, 0.15)

func eat_shroom(shroom):
	if shroom.is_used(): return
	if tornado_enabled: 
		shroom.destroy()
		return 
	score_inc(SCORE_SHROOM)
	power_inc(POWER_SHROOM)
	shroom.eat()
	Input.start_joy_vibration(0, 0.2, 0.4, 0.35)

func run_arcade(arcade):
	arcade.run()
	score_inc(SCORE_ARCADE)

func bump_tree(tree):
	if tornado_enabled:
		tree.fall()
		score_inc(SCORE_FALL)
	else:
		tree.shake()
		Input.start_joy_vibration(0, 0.2, 0.2, 0.2)

func score_inc(what):
	score += what
	get_tree().call_group("gui", "score_set", score)

func power_inc(what):
	power += what
	if power > POWER_MAX: 
		power = POWER_MAX * 0.8
		self.hit(DAMAGE_OVERDOSE)
	get_tree().call_group("gui", "power_set", power, POWER_MAX)

func hit_amiga(a):
	enemy_strike(a)

func enemy_strike(enemy):
	self.hit(DAMAGE_ENEMY)
	enemy.die()

func hit(amount):
	lives -= amount
	get_tree().call_group("gui", "life_set", lives)
	if lives < 0.0:
		self.die("Life was short")

func kaiju_fight(kaiju):
	self.die("kaiju")

func tornado_power_used():
	tornado_enabled = false

func tornado_power_start():
	$anim.play("power_tornado")
	Input.start_joy_vibration(self.device_id, 0.0, 0.1, $anim.current_animation_length)
	tornado_enabled = true
	power_inc(-POWER_REQ_TORNADO)

func die(way):
	get_tree().call_group("game", "player_die", way)

func activate_bomb(bomb):
	if tornado_enabled:
		if not bomb.is_activated():
			bomb.explode()
			bomb.activate()
			self.score_inc(SCORE_DETONATE_BOMB)
	else:
		if not bomb.is_activated():
			bomb.explode_and_activate()
		else:
			self.hit(DAMAGE_BOMB)
			Input.start_joy_vibration(0, 0.4, 0.8, 0.5)
			bomb.deactivate()
	
