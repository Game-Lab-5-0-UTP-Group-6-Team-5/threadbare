extends Node2D
@onready var video_player: VideoStreamPlayer = $"../VideoStreamPlayer"


@export_file("*.tscn") var next_scene: String
@export var animation_player: AnimationPlayer

@export var spawn_point_path: String


func _ready() -> void:
	if video_player and animation_player:

		video_player.modulate.a = 1.0 
		video_player.play()
		await video_player.finished
		animation_player.play("fade_out")
		await animation_player.animation_finished
	
	if next_scene:
		SceneSwitcher.change_to_file(next_scene, spawn_point_path)
