extends StaticBody2D

@onready var game = get_parent()
@onready var player = game.get_child(0)
@onready var movingrect:TextureRect = game.get_child(2)

func _process(_delta: float) -> void:
	for i:CollisionShape2D in get_children():
		#OH YEA- VECTA
		var vec = (player.global_position - i.global_position)
		var direction = vec.x/abs(vec.x)
		var distance = vec.length()
		if distance <= 4000:
			var opacity = ((400-(abs(vec.x)+(150*-direction)))/400)
			if opacity > 0:
				movingrect.rotation = i.rotation
				movingrect.modulate.a = abs(opacity)
				if i.rotation_degrees == 180:
					movingrect.global_position = Vector2(i.global_position.x-((i.shape.size.y*i.scale.x)/2),player.global_position.y-((i.shape.size.x*i.scale.x)/2))
				else:
					movingrect.global_position = Vector2(i.global_position.x-((i.shape.size.x*i.scale.x)/2),player.global_position.y-((i.shape.size.y*i.scale.x)/2))
