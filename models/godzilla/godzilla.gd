extends KinematicBody

var player = preload("res://scenes/caterpillar/main_segment.gd")
var coin = preload("res://models/coin/coin.gd")
var shroom = preload("res://models/shroom/shroom.gd")
var tree = preload("res://models/forest/tree.gd")

export var move_speed = 100
export var move_max_speed = 200
export var move_accel = 4.5
export var move_deaccel = 16
export var rotate_speed = 5.0
export var rotate_snap_speed = 50.0

var main_segment = null

var angle_y = 0
var _angle_y = 0

var accumulated_delta = 0.0

func _ready():
    self.main_segment = self.get_parent().get_node("player")

func _process(delta):
    if not self.main_segment.controller_enabled:
        return

    var delta_snap = delta * self.rotate_snap_speed
    if delta_snap > 1.0:
        delta_snap = 1.0

    if angle_y != _angle_y:
        _angle_y += (angle_y - _angle_y) * delta_snap

        self.set_rotation_degrees(Vector3(0, _angle_y, 0))

func _physics_process(delta):
    if not self.main_segment.controller_enabled:
        return

    if self.move_speed < self.move_max_speed:
        self.move_speed += delta

    var axis_value = Vector2()
    var axis_value_normalized
    var dir = Vector3()
    var vel = Vector3()

    var player_position = self.main_segment.get_translation()
    var position = self.get_translation()

    if position.y < -20:
        position.y = 50
        self.set_translation(position)

    axis_value.x = player_position.x - position.x
    axis_value.y = player_position.z - position.z

    var angle = rad2deg(-axis_value.angle()) - 90
    self.angle_y = angle

    vel.y = -50

    if axis_value.length() < 0.1:
        return

    axis_value_normalized = axis_value.normalized()

    dir.x = axis_value_normalized.x
    dir.z = axis_value_normalized.y

    var hvel = vel
    hvel.y = 0

    var target = dir
    target *= self.move_speed
    var accel
    if dir.dot(hvel) > 0:
        accel = self.move_accel
    else:
        accel = self.move_deaccel

    hvel = hvel.linear_interpolate(target, accel * delta)
    vel.x = hvel.x
    vel.z = hvel.z
    vel = self.move_and_slide(vel, Vector3(0, 1, 0), true, 4)

    var count = self.get_slide_count()
    var colliding_body
    for i in range(count):
        colliding_body = self.get_slide_collision(i)

        if colliding_body.collider is self.player:
            colliding_body.collider.kaiju_fight(self)
        if colliding_body.collider is self.shroom or colliding_body.collider is self.coin:
            colliding_body.collider.get_parent().queue_free()
        if colliding_body.collider is self.tree:
            colliding_body.collider.fall()
