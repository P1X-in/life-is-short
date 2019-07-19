extends Spatial

export var next_scene_bigfile = "main"

func _input(event):
    if Input.is_key_pressed(KEY_ESCAPE):
        quit_game()
    if Input.is_action_pressed("ui_accept"):
        self.next_scene()

func quit_game():
    get_tree().quit()

func next_scene():
    get_tree().change_scene("scenes/big/"+next_scene_bigfile+".tscn")
