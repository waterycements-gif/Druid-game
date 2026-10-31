class_name Hurtbox extends Area2D

signal recievedDmg(a,b,c,d,e,f,g)

@export var health:Health
var entityKnockedDown = false

func _ready() -> void:
	connect("area_entered",_on_area_entered)

func set_entityKnockedDown(val):
	entityKnockedDown = val

func _on_area_entered(hitbox:Hitbox) -> void:
	if hitbox != null and hitbox is Hitbox and hitbox.get_parent() != get_parent() and health:
		health._changeHealth(-hitbox.dmg,hitbox.injuredSound)
		get_child(0).set_deferred("disabled",true)
		await get_tree().physics_frame
		get_child(0).set_deferred("disabled",false)
		var hasParent = hitbox.get_parent()
		if hasParent and ((entityKnockedDown and hitbox.damageKnockedDown) or entityKnockedDown == false):
			var hasTwoParents = hasParent.get_parent()
			var continuesAfterHit = (hasTwoParents.has_meta("continueAfterHit") and hasTwoParents.get_meta("continueAfterHit"))
			if hasTwoParents:
				var hasThreeParents = hasTwoParents.get_parent()
				if hasTwoParents is Entity and hasTwoParents.target == null:
					hasTwoParents.increaseExperience()
				if hasThreeParents and not continuesAfterHit and hasTwoParents is Path2D:
					hasThreeParents.removeProjectile(hasTwoParents)
		recievedDmg.emit(hitbox.dmg,hitbox.get_parent().global_position,hitbox.knockback,hitbox.upwardsKnockback,hitbox.knockbackOffset,hitbox.damageKnockedDown,hitbox.amountOfStun)
	elif not health:
		queue_free()
