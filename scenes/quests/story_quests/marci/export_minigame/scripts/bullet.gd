extends Area2D

@export var speed := 540.0
var direction := Vector2.ZERO

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	$AnimatedSprite2D.play("default")	
	rotation = direction.angle()

func _process(delta):
	global_position += direction * speed * delta

	if global_position.length() > 10000:
		queue_free()


func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(1)
		queue_free()
