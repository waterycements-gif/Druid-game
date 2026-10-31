extends Area2D


func _process(_delta: float) -> void:
	body_entered.connect(func(body):
		body.global_position = Vector2(1,1)
	)
