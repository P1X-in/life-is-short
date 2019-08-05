	extends Spatial

export var next_scene_bigfile = "scenes/big/main"

func _input(event):
    if Input.is_key_pressed(KEY_ESCAPE):
        quit_game()

func quit_game():
    get_tree().quit()

func next_scene():
    get_tree().change_scene(next_scene_bigfile+".tscn")

func _on_start_pressed():
    $anim_main.play("main_to_difficulty")

func _on_quit_pressed():
    quit_game()

func _on_back_pressed():
    $anim_main.play("difficulty_to_main")

func _on_easy_pressed():
    next_scene()
