	extends Spatial

export var next_scene_bigfile = "scenes/big/main"

func _input(event):
    if Input.is_key_pressed(KEY_ESCAPE):
        quit_game()
    if Input.is_action_pressed("button_a") or Input.is_action_pressed("button_b"):
        next_scene()

func quit_game():
    get_tree().quit()

func next_scene():
    get_tree().change_scene(next_scene_bigfile+".tscn")