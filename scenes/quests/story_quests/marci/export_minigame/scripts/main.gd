extends Node2D

@onready var player := $Player
@onready var score_label = $CanvasLayer/LabelScore
@onready var hp_label = $CanvasLayer/LabelHP
@onready var spawner := $EnemySpawner
@onready var collectible_item = $CollectibleItem
@onready var spawn_points = $SpawnPoints.get_children()

var score := 0
var kills := 0

var is_final_item_spawned := false

func _ready():
	add_to_group("main")
	spawner.timeout.connect(spawn_enemy)
	spawner.start()
	update_hud()
	if collectible_item:
		collectible_item.revealed = false

func spawn_enemy():
	if is_final_item_spawned:
		return
	var enemy = load("res://scenes/quests/story_quests/marci/3_combat/components/enemy.tscn").instantiate()
	var random_spawn_point = spawn_points.pick_random()
	enemy.global_position = random_spawn_point.global_position
	
	add_child(enemy)
	enemy.add_to_group("enemies")

func enemy_killed():
	if is_final_item_spawned:
		return
	score += 1
	kills += 1
	update_hud()

	if score >= 70  and not is_final_item_spawned:
		is_final_item_spawned = true
		spawner.stop()
		clear_enemies()
		if collectible_item:
			collectible_item.reveal()
	if kills % 8 == 0:
		spawn_powerup("rate")
	if kills % 15 == 0 and randf() < 0.7:
		spawn_powerup("bomb")

func spawn_powerup(t):
	if is_final_item_spawned:
		return
	var p = load("res://scenes/quests/story_quests/marci/3_combat/components/powerup.tscn").instantiate()
	if spawn_points.is_empty():
		return
	var random_spawn_point = spawn_points.pick_random()
	p.global_position = random_spawn_point.global_position
	p.type = t
	add_child(p)

func clear_enemies():
	for e in get_tree().get_nodes_in_group("enemies"):
		e.queue_free()

func update_hud():
	if score_label:
		score_label.text = "Puntuación: %s" % score
	if hp_label and is_instance_valid(player):
		hp_label.text = "HP: %s" % player.hp
	elif hp_label:
		hp_label.text = "HP: 0"


func game_over():
	spawner.stop()
	await get_tree().create_timer(1.5).timeout
	get_tree().reload_current_scene()
