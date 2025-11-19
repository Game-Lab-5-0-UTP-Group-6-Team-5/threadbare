extends Node2D
class_name FireBoss

@export var fireball_scene: PackedScene
@export var player_path: NodePath


@onready var player = get_node_or_null(player_path)
@onready var shoot_timer: Timer = $ShootTimer

var max_health := 100
var health := max_health
var phase := 1

var base_shoot_speed := 350.0
var base_shoot_interval := 2.0
var base_fireballs := 1

func _ready():
	add_to_group("enemies")
	if not player:
		print("❌ No se encontró el player")
	else:
		print("✔️ Player detectado:", player)

	if not shoot_timer:
		print("❌ No existe ShootTimer")
	else:
		print("✔️ ShootTimer detectado")

	_update_phase()
	_configure_timer()

func _configure_timer():
	shoot_timer.wait_time = _interval_per_phase()
	shoot_timer.timeout.connect(_shoot)
	shoot_timer.start()
	print("⏱️ Timer configurado con wait_time =", shoot_timer.wait_time)

func _shoot():
	if not player:
		return

	var extra_random_count := 0
	match phase:
		1:
			extra_random_count = 1 	# Total: 1 dirigido + 1 aleatorio = 2
		2:
			extra_random_count = 3 	# Total: 1 dirigido + 3 aleatorios = 4
		3:
			extra_random_count = 6 	# Total: 1 dirigido + 6 aleatorios = 7
		4:
			extra_random_count = 10 	# Total: 1 dirigido + 10 aleatorios = 11

	var num_shots = 1 + extra_random_count
	
	var base_speed = _speed_per_phase()
	for i in range(num_shots):
		var fb = fireball_scene.instantiate()
		get_tree().current_scene.add_child(fb)
		fb.global_position = global_position
		
		var target_position: Vector2
		var shot_speed = base_speed
		
		if i == 0:

			var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
			target_position = player.global_position + offset
		else:

			var random_angle = randf() * TAU
			var dir = Vector2.RIGHT.rotated(random_angle)
			target_position = fb.global_position + dir * 2000
			

			shot_speed *= randf_range(0.6, 1.4) 

		fb.speed = shot_speed
		fb.shoot_toward(target_position)

	shoot_timer.wait_time = _interval_per_phase()
	shoot_timer.start()

func take_damage(amount):
	health -= amount
	if health <= 0:
		print("💀 Boss muerto")
		queue_free()
		return

	_update_phase()

func _update_phase():
	if health > 75:
		phase = 1
	elif health > 50:
		phase = 2
	elif health > 25:
		phase = 3
	else:
		phase = 4


func _speed_per_phase() -> float:
	return base_shoot_speed + (phase - 1) * 100.0

func _interval_per_phase() -> float:
	return base_shoot_interval - (phase - 1) * 0.4

func _fireballs_per_phase() -> int:
	return base_fireballs + (phase - 1)
