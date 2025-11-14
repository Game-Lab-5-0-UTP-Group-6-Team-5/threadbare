extends CanvasLayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
var target_scene_path = ""

func change_scene(path):
	target_scene_path = path
	animation_player.play("fade_in")
	
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fade_in":
		get_tree().change_scene_to_file(target_scene_path)
		animation_player.play("fade_out")
