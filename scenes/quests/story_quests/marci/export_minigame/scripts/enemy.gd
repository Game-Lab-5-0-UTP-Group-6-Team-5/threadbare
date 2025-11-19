extends CharacterBody2D

@export var speed := 250.0
@export var hp := 2

@onready var player = get_tree().get_first_node_in_group("player")
@onready var anim = $AnimatedSprite2D 


@onready var collision_shape = $CollisionShape2D
@onready var damage_area_collision = $DamageArea/CollisionShape2D

func _ready():
	add_to_group("enemies")
	$DamageArea.body_entered.connect(_on_body_entered)
	anim.play("attack")

func _physics_process(_delta):
	if not player:
		return
	var dir = (player.position - position).normalized()
	velocity = dir * speed
	if dir.x != 0:
		anim.flip_h = dir.x < 0
	
	move_and_slide()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(1)
		queue_free()

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		die()

func die():
	get_tree().get_first_node_in_group("main").enemy_killed()
	set_physics_process(false)
	velocity = Vector2.ZERO
	collision_shape.set_deferred("disabled", true)
	damage_area_collision.set_deferred("disabled", true)
	
	anim.play("defeat")
	await anim.animation_finished
	queue_free()
