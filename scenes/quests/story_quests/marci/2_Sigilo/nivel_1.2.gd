extends Node2D
@onready var animation_player: AnimationPlayer = $CanvasLayer/AnimationPlayer

func _ready():
	animation_player.play("fade_out")
