extends "res://vendors/p1x/gamepad_3d_controller/controller.gd"

var coin = preload("res://models/coin/coin.gd")
var shroom = preload("res://models/shroom/shroom.gd")
var tree = preload("res://models/forest/tree.gd")

export var initial_size = 1.0

var accumulated_delta = 0.0
var size = 1.0
var lives = 4
const SIZE_LIMIT = 4.0
const TIME_LIMIT = 120
const SIZE_GAIN = .5
const GAME_TIME = 180

var coins_count = 0
var score = 0

const SCORE_COIN = 10
const SCORE_SHROOM = 50
const SCORE_FALL = 100

func _ready():
    ._ready()
    self.size = self.initial_size
    self.set_scale(Vector3(self.size, self.size, self.size))

onready var sounds = $"sounds/movement"

func _physics_process(delta):
    if not self.controller_enabled:
        return

    self.accumulated_delta += delta * 10
    if self.accumulated_delta > 2.0 * PI:
        self.accumulated_delta -= 2.0 * PI

    if self.is_moving:
        if not self.sounds.playing:
            self.sounds.play(randf()*4.0)
    else:
        self.sounds.stop()

    self.raycast.cast_to = Vector3(0, -1 * self.size, self.camera_max_distance * self.size)

func process_body_collision(collision):
    if collision.collider is self.coin:
        self.pick_up_coin(collision.collider)
    if collision.collider is self.shroom:
        self.eat_shroom(collision.collider)
    if collision.collider is self.tree:
        self.bump_tree(collision.collider)

func get_speed(factor):
    var sine_variance = (sin(self.accumulated_delta) + 1.0) / 4.0 + 0.5
    return self.move_max_speed * factor * sine_variance

func pick_up_coin(coin):
    coin.get_parent().get_node("anim").play("pick_up")
    $sounds/coin.play()
    coins_count += 1
    score_inc(SCORE_COIN)
    get_tree().call_group("gui", "coins_set", coins_count)
    coin.queue_free()
    Input.start_joy_vibration(0, 0.1, 0.2, 0.1)

func eat_shroom(shroom):
    score_inc(SCORE_SHROOM)
    get_tree().call_group("gui", "power_inc")
    shroom.eat()
    Input.start_joy_vibration(0, 0.2, 0.4, 0.2)

func bump_tree(tree):
    # if power then tree.fall()
    # score_inc(SCORE_FALL)
    tree.shake()
    Input.start_joy_vibration(0, 0.2, 0.7, 0.2)

func score_inc(what):
    score += what
    get_tree().call_group("gui", "score_set", score)

func enemy_strike(enemy):
    hit()
    enemy.die()

func hit():
    lives -= 1
    if lives < 0:
        self.die()

func kaiju_fight(kaiju):
    self.die()

func die():
    get_tree().call_group("game", "player_die")
