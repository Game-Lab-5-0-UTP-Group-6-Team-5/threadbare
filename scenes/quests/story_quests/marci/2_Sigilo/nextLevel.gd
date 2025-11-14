extends Area2D

@export var new_scene_path: String
@onready var animation_player: AnimationPlayer = $"../CanvasLayer/AnimationPlayer"

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and monitoring:
		monitoring = false
		change_scene()
	pass 
func change_scene():
	animation_player.play("fade_in")
	await animation_player.animation_finished
	get_tree().change_scene_to_file(new_scene_path)
