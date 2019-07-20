extends KinematicBody

export var flight_speed = 15
export var flight_max_speed = 100
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

    if self.flight_speed < self.flight_max_speed:
        self.flight_speed += delta

    var axis_value = Vector2()
    var axis_value_normalized
    var dir = Vector3()
    var vel = Vector3()

    var player_position = self.main_segment.get_translation()
    var position = self.get_translation()
    axis_value.x = player_position.x - position.x
    axis_value.y = player_position.z - position.z

    var angle = rad2deg(-axis_value.angle()) - 90
    self.angle_y = angle

    if axis_value.length() < 5 * self.main_segment.size:
        vel.y = (player_position.y - position.y) * 5 - 50

    axis_value_normalized = axis_value.normalized()

    dir.x = axis_value_normalized.x
    dir.z = axis_value_normalized.y

    var hvel = vel
    hvel.y = 0

    var target = dir
    target *= self.flight_speed
    var accel
    if dir.dot(hvel) > 0:
        accel = self.move_accel
    else:
        accel = self.move_deaccel

    hvel = hvel.linear_interpolate(target, accel * delta)
    vel.x = hvel.x
    vel.z = hvel.z
    vel = self.move_and_slide(vel, Vector3(0, 1, 0), true, 4)

