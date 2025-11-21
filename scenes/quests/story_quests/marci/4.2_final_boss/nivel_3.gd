extends Node2D

@onready var player := $Player
@onready var hp_label = $CanvasLayer/LabelHP
@onready var collectible_item = $CollectibleItem
@onready var boss_health_bar = $CanvasLayer/BossHealthBar
@onready var boss = $FireBoss

var item_landing_position: Vector2

func _ready():
	add_to_group("main")
	update_hud()
	if boss and boss_health_bar:
		boss_health_bar.max_value = boss.max_health
		boss_health_bar.value = boss.health
	if collectible_item:
		item_landing_position = collectible_item.position
		collectible_item.position.y -= 350
		collectible_item.revealed = false

func update_hud():
	if hp_label and is_instance_valid(player):
		hp_label.text = "HP: %s" % player.hp
	elif hp_label:
		hp_label.text = "HP: 0"


func boss_defeated():
	await get_tree().create_timer(1.0).timeout
	drop_reward()

func drop_reward():
	if not collectible_item:
		return
		
	collectible_item.reveal()
	var tween = create_tween()
	
	tween.set_trans(Tween.TRANS_BOUNCE) 
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(collectible_item, "position", item_landing_position, 1.5)

func game_over():
	print("💀 Boss Derrotó al Jugador - Reiniciando...")

	await get_tree().create_timer(1.5).timeout
	
	get_tree().call_deferred("reload_current_scene")

func update_boss_health(current_health):
	if boss_health_bar:
		boss_health_bar.value = current_health
