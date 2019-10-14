extends KinematicBody

const DEADZONE = 0.12
const GRAVITY = 9.8
const MOVEMENT_AXIS_X = JOY_AXIS_0
const MOVEMENT_AXIS_Y = JOY_AXIS_1
const CAMERA_AXIS_X = JOY_AXIS_3
const CAMERA_AXIS_Y = JOY_AXIS_4

export var device_id = 0
export var move_accel = 4.5
export var move_max_speed = 150
export var move_deaccel = 16
export var rotate_speed = 12.0
export var rotate_snap_speed = 50.0
export var max_slope_angle = 40

export var camera_min_deg = -70
export var camera_max_deg = -20

export var camera_min_distance = 18
export var camera_max_distance = 32

export var camera_rotate_speed = 1.5
export var camera_return_speed = 50.0

export var controller_enabled = true

var is_moving = false

var camera_pivot
var camera

var angle_y = 0
var _angle_y = 0

var camera_angle_y = 0
var _camera_angle_y = 0

var camera_angle_x = 0
var _camera_angle_x = 0

var camera_distance = 0
var _camera_distance = 0

var raycast
var gravity_velocity = 0.0

func activate():
    self.controller_enabled = true

func deactivate():
    self.controller_enabled = false

func _ready():
    self.camera_pivot = $"camera_pivot"
    self.camera = $"camera_pivot/camera"
    self.raycast = $"camera_pivot/RayCast"

    var rotation = self.get_rotation_degrees()
    angle_y = rotation.y
    _angle_y = rotation.y

    rotation = self.camera_pivot.get_rotation_degrees()
    camera_angle_y = rotation.y
    _camera_angle_y = rotation.y
    camera_angle_x = rotation.x
    _camera_angle_x = rotation.x

    self.raycast.cast_to = Vector3(0, -1, self.camera_max_distance)
    self.raycast.add_exception(self)

    self._camera_distance = self.camera_max_distance
    self.camera_distance = self.camera_max_distance
    self.camera.set_translation(Vector3(0, 0, self.camera_max_distance))

func _process(delta):
    if not self.controller_enabled:
        return

    var delta_speed = delta * self.camera_return_speed
    var delta_snap = delta * self.rotate_snap_speed
    if delta_speed > 1.0:
        delta_speed = 1.0

    if delta_snap > 1.0:
        delta_snap = 1.0

    if angle_y != _angle_y:
        _angle_y += (angle_y - _angle_y) * delta_snap

        self.set_rotation_degrees(Vector3(0, _angle_y, 0))

    if camera_angle_y != _camera_angle_y:
        _camera_angle_y += (camera_angle_y - _camera_angle_y) * delta_speed

        if abs(camera_angle_y - _camera_angle_y) < 0.001:
            _camera_angle_y = camera_angle_y

    if camera_angle_x != _camera_angle_x:
        _camera_angle_x += (camera_angle_x - _camera_angle_x) * delta_speed

        if abs(camera_angle_x - _camera_angle_x) < 0.001:
            _camera_angle_x = camera_angle_x

    self.camera_pivot.set_rotation_degrees(Vector3(_camera_angle_x, _camera_angle_y, 0))

    if camera_distance != _camera_distance:
        _camera_distance += (camera_distance - _camera_distance) * delta_speed / 2.0
        if abs(camera_distance - _camera_distance) < 0.001:
            _camera_distance = camera_distance
    self.camera.set_translation(Vector3(0, 0, _camera_distance))

func process_camera_collision():
    var distance = self.camera_max_distance
    if self.raycast.is_colliding():
        var raycast_collision = self.raycast.get_collision_point() - self.get_translation()
        distance = min(distance, raycast_collision.length() - 1.0)
        distance = max(distance, self.camera_min_distance)

        self._camera_distance = distance
        self.camera.set_translation(Vector3(0, 0, distance))
    self.camera_distance = distance

func _physics_process(delta):
    if not self.controller_enabled:
        return

    self.process_camera_input(delta)
    self.process_movement_input(delta)
    self.process_camera_collision()
    self.process_body_collisions()

func process_movement_input(delta):
    var axis_value = Vector2()
    var axis_value_normalized
    var dir = Vector3()
    var vel = Vector3()

    self.gravity_velocity += delta * -self.GRAVITY
    if self.is_on_floor():
        self.gravity_velocity = -self.GRAVITY
    vel.y = self.gravity_velocity
    axis_value.x = -Input.get_joy_axis(self.device_id, MOVEMENT_AXIS_X)
    axis_value.y = Input.get_joy_axis(self.device_id, MOVEMENT_AXIS_Y)


    axis_value = axis_value.rotated(deg2rad(self.angle_y + self.camera_angle_y))

    self.is_moving = axis_value.length() > self.DEADZONE
    if self.is_moving:
        var angle = rad2deg(axis_value.angle()) + 90
        var angle_diff = angle - self.angle_y
        self.angle_y = angle
        self.camera_angle_y -= angle_diff

        axis_value_normalized = axis_value.normalized()

        dir.x = -axis_value_normalized.x
        dir.z = axis_value_normalized.y

        var hvel = vel
        hvel.y = 0

        var target = dir
        target *= self.get_speed(axis_value.length())
        var accel
        if dir.dot(hvel) > 0:
            accel = self.move_accel
        else:
            accel = self.move_deaccel

        hvel = hvel.linear_interpolate(target, accel * delta)
        vel.x = hvel.x
        vel.z = hvel.z
    vel = self.move_and_slide(vel, Vector3(0, 1, 0), true, 4, deg2rad(self.max_slope_angle))

func process_camera_input(delta):
    var axis_value = Vector2()

    axis_value.x = Input.get_joy_axis(self.device_id, CAMERA_AXIS_X)
    axis_value.y = Input.get_joy_axis(self.device_id, CAMERA_AXIS_Y)

    if abs(axis_value.x) > DEADZONE:
        camera_angle_y -= self.camera_rotate_speed * axis_value.x

    if abs(axis_value.y) > DEADZONE:
        camera_angle_x -= self.camera_rotate_speed * axis_value.y
        camera_angle_x = clamp(camera_angle_x, self.camera_min_deg, self.camera_max_deg)

func process_body_collisions():
    var count = self.get_slide_count()
    var colliding_body

    for i in range(count):
        colliding_body = self.get_slide_collision(i)
        self.process_body_collision(colliding_body)

func process_body_collision(collision):
    return

func get_speed(factor):
    return self.move_max_speed * factor
