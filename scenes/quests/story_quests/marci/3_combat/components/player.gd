extends CharacterBody2D


const DEFAULT_SPRITE_FRAME: SpriteFrames = preload("uid://vwf8e1v8brdp")


enum Mode {
	COZY,
	FIGHTING,
	DEFEATED,
}

@export var mode: Mode = Mode.COZY
@export_range(10, 100000, 10) var walk_speed: float = 300.0
@export_range(10, 100000, 10) var run_speed: float = 500.0
@export_range(10, 100000, 10) var stopping_step: float = 1500.0
@export_range(10, 100000, 10) var moving_step: float = 4000.0

@export var sprite_frames: SpriteFrames = DEFAULT_SPRITE_FRAME:
	set = _set_sprite_frames



@export var shoot_delay := 0.5
var shoot_timer := 0.0
var hp := 5
var is_attacking := false
var is_dead := false
var input_vector: Vector2

@onready var main = get_tree().get_first_node_in_group("main")
@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var interaction_zone: Area2D = $PlayerInteraction/InteractZone
@onready var attack_timer: Timer = $AttackTimer

var overlapping_areas: Array = []


func _set_sprite_frames(new_sprite_frames: SpriteFrames) -> void:
	
	sprite_frames = new_sprite_frames
	if is_node_ready() and player_sprite:
		player_sprite.sprite_frames = new_sprite_frames

func _ready():
	add_to_group("player")
	interaction_zone.area_entered.connect(_on_interaction_zone_area_entered)
	interaction_zone.area_exited.connect(_on_interaction_zone_area_exited)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	shoot_timer = shoot_delay
	_set_sprite_frames(sprite_frames)



func _process(delta: float):

	if is_dead:
		return

	var axis: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_up"):
		axis.y -= 1
	if Input.is_action_pressed("move_down"):
		axis.y += 1
	if Input.is_action_pressed("move_left"):
		axis.x -= 1
	if Input.is_action_pressed("move_right"):
		axis.x += 1
	axis = axis.normalized()

	var speed_target: float = walk_speed
	if Input.is_action_pressed("running"):
		speed_target = run_speed

	input_vector = axis * speed_target

	var step := (
		stopping_step if velocity.length_squared() > input_vector.length_squared() else moving_step
	)
	velocity = velocity.move_toward(input_vector, step * delta)

	move_and_slide()
	
	_handle_combat_and_animation(delta)


func _handle_combat_and_animation(delta: float):
	shoot_timer -= delta
	
	if shoot_timer <= 0 and not is_attacking:
		shoot()
		shoot_timer = shoot_delay
		is_attacking = true
		attack_timer.start(shoot_delay * 0.8)
	

	if Input.is_action_just_pressed("interact") and not overlapping_areas.is_empty():
		var interact_area = overlapping_areas[0]
		interact_area.interaction_started.emit(self, false)

	if is_attacking:
		pass
	elif velocity.length() > 0:
		if Input.is_action_pressed("running"): 
			player_sprite.play("run")
		else:
			player_sprite.play("walk")
	else:
		player_sprite.play("idle")
		

	if velocity.x != 0:
		player_sprite.flip_h = (velocity.x < 0)


func shoot():
	var all_enemies = get_tree().get_nodes_in_group("enemies")
	if all_enemies.is_empty():
		return
	player_sprite.play("attack_01")

	var nearest = all_enemies[0]
	var min_dist = global_position.distance_to(nearest.global_position)
	
	for e in all_enemies:
		var d = global_position.distance_to(e.global_position)
		if d < min_dist:
			min_dist = d
			nearest = e

	var dir = (nearest.global_position - global_position).normalized()
	var b = preload("res://scenes/quests/story_quests/marci/3_combat/components/bullet.tscn").instantiate()
	b.global_position = global_position
	b.direction = dir
	main.add_child(b)
	

func take_damage(amount):
	hp -= amount
	main.update_hud()
	
	if hp <= 0:
		die()

func die():
	is_dead = true
	set_physics_process(false)
	velocity = Vector2.ZERO
	$CollisionShape2D.set_deferred("disabled", true)
	player_sprite.play("defeated")
	await player_sprite.animation_finished
	main.game_over()



func _on_interaction_zone_area_entered(area):
	if not overlapping_areas.has(area):
		overlapping_areas.append(area)

func _on_interaction_zone_area_exited(area):
	overlapping_areas.erase(area)
	
func _on_attack_timer_timeout():
	is_attacking = false
