extends Node2D

var projectileTable = []
@onready var cloneableChild = $"Cloneable"

func _ready() -> void:
	while true:
		for i:Array in projectileTable:
			var node = i[0]
			var followPath:PathFollow2D = node.get_child(0)
			var sprite:AnimatedSprite2D = followPath.get_child(0).get_child(0)
			if not i[2] and followPath.progress_ratio >= 0.8 and sprite.modulate.a >= 1 and not i[4]:
				followPath.get_child(0).get_child(1).disabled = true
				removeProjectile(i,false)
			elif followPath.progress_ratio >= 1 and i[2]:
				removeProjectile(i,true)
				continue
			else:
				followPath.progress += i[1]
		await get_tree().process_frame

func add_New_Projectile(pos,rayPos,size,col_layer:Hurtbox,texture,isflipped:int,spd,targetPos,arc,stick,damage,knockback,continueAfterHit,projectileScale,hitSound):
	var node:Path2D = cloneableChild.duplicate()
	node.curve = Curve2D.new()
	var area2d:Hitbox = node.get_child(0).get_child(0)
	var collisionPart:CollisionShape2D = area2d.get_child(1)
	var sprite:AnimatedSprite2D = area2d.get_child(0)
	var isFlippedToInt:int = (isflipped*2)-1
	isFlippedToInt/=abs(isFlippedToInt)
	sprite.animation = texture
	area2d.scale = projectileScale
	rayPos.x *= isFlippedToInt
	node.set_meta("continueAfterHit",continueAfterHit)
	for i in range(1,9):
		area2d.set_collision_layer_value(i,not col_layer.get_collision_mask_value(i))
	area2d.set_dmg(damage)
	area2d.set_knocback(knockback)
	area2d.set_injuredSound(hitSound)
	collisionPart.shape.size = size
	collisionPart.scale = projectileScale
	collisionPart.position = rayPos
	node.position = pos
	node.name = "Active" + str(projectileTable.size())
	targetPos = node.to_local(targetPos)
	if targetPos.x < 0:
		sprite.flip_v = true
	var curve = null
	if arc == "straight":
		curve = Vector2()
	elif arc == "halfed":
		curve = Vector2(targetPos.x/2, -abs(targetPos.x))
	node.curve.add_point(Vector2(),Vector2(),curve)
	node.curve.add_point(targetPos)
	var arrayCeption = [node,spd,stick,continueAfterHit,false]
	projectileTable.append(arrayCeption)
	node.visible = true
	area2d.monitorable = true
	add_child(node)
	if sprite.sprite_frames.get_frame_count(texture) > 1:
		while true:
			sprite.play()
			await sprite.animation_finished

func removeProjectile(projectile,stick:bool = false):
	if not projectile is Array:
		for i:Array in projectileTable:
			if i.has(projectile):
				projectile = i
		if not projectile is Array:
			return
	if not projectile[0] or projectileTable.find(projectile) == -1 or projectile[4]:
		return
	projectile[4] = true
	var node:Path2D = projectile[0]
	var followPath:PathFollow2D = node.get_child(0)
	var sprite = followPath.get_child(0).get_child(0)
	if stick:
		projectileTable.remove_at(projectileTable.find(projectile))
		followPath.get_child(0).get_child(1).queue_free()
		await get_tree().create_timer(1).timeout
		var tween = get_tree().create_tween()
		tween.tween_property(sprite,"modulate:a", 0,1)
		await tween.finished
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(sprite,"modulate:a", 0,.3)
		tween.play()
		await tween.finished
		projectileTable.remove_at(projectileTable.find(projectile))
	node.queue_free()
