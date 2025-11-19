extends Area2D

@export var speed := 540.0
var direction := Vector2.ZERO

func _ready():
	body_entered.connect(_on_target_entered)
	area_entered.connect(_on_target_entered)
	
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("default")	
	rotation = direction.angle()

func _process(delta):
	global_position += direction * speed * delta

	if global_position.length() > 10000:
		queue_free()

func _on_target_entered(target):
	if target.is_in_group("enemies"):
		if target.has_method("take_damage"):
			target.take_damage(1)
		queue_free()
