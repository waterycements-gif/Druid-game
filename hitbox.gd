class_name Hitbox extends Area2D

@export var dmg = 1
@export var knockback = 2
@export var upwardsKnockback = 0
@export var knockbackOffset = Vector2()
@export var injuredSound:AudioStream
var damageKnockedDown:bool = false
var amountOfStun = 1

func set_injuredSound(v):
	injuredSound = v

func set_damageKnockedDown(v):
	damageKnockedDown = v

func set_amountOfStun(v):
	amountOfStun = v

func set_dmg(v):
	dmg = v

func set_knocback(v):
	knockback = v

func set_upwardsKnockback(v):
	upwardsKnockback = v

func set_offset(v):
	knockbackOffset = v

func get_dmg():
	return dmg

func get_knockback():
	return knockback

func get_upwardsKnockback():
	return upwardsKnockback
