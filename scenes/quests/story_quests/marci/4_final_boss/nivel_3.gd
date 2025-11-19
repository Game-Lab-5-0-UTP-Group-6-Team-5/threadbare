extends Node2D


@onready var player := $Player
@onready var hp_label = $CanvasLayer/LabelHP 

func _ready():
	add_to_group("main")
	update_hud()



func update_hud():

	if hp_label and is_instance_valid(player):
		hp_label.text = "HP: %s" % player.hp
	elif hp_label:
		hp_label.text = "HP: 0"


func game_over():
	print("💀 Boss Derrotó al Jugador - Reiniciando...")

	await get_tree().create_timer(1.5).timeout
	
	get_tree().call_deferred("reload_current_scene")
