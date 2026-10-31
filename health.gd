class_name Health extends Node

@export var maxHealth:int = 25
@onready var health = maxHealth
@export var healthGui:TextureProgressBar
@export var decayGui:TextureProgressBar
@export var displayHealth:bool = true
@export var hideHealthAfterFull = true
@export var DamagedSounds:AudioStreamPlayer2D
var healthDead = false

signal entityDied()
signal healthChanged(val: int)



func _ready() -> void:
	if displayHealth == false or hideHealthAfterFull:
		healthGui.visible = false

func _changeHealth(val,sounds):
	health+=val
	if val < 0 and sounds:
		DamagedSounds.stream = sounds
		DamagedSounds.pitch_scale = randf_range(.8,1.2)
		DamagedSounds.play()
	if health <= 0 and not healthDead:
		healthDead = true
		healthGui.visible = false
		entityDied.emit()
		if get_parent().name != "Player":
			queue_free()
	elif (health >= maxHealth):
		health = maxHealth
		if hideHealthAfterFull and healthGui.visible == true:
			healthGui.visible = false
	elif hideHealthAfterFull and healthGui.visible == false:
		healthGui.visible = true
	healthChanged.emit(val)
	if decayGui:
		if val>0:
			decayGui.value = 100*health/maxHealth
			await get_tree().create_timer(1).timeout
			var tween = get_tree().create_tween()
			tween.tween_property(healthGui,"value",100*health/maxHealth,.1)
		elif val<0:
			healthGui.value = 100*health/maxHealth
			await get_tree().create_timer(1).timeout
			var tween = get_tree().create_tween()
			tween.tween_property(decayGui,"value",100*health/maxHealth,.1)
	else:
		healthGui.value = 100*health/maxHealth

func _setMaxHealth(val):
	if val <= 0:
		maxHealth = 1
	else:
		maxHealth = val
	if health > maxHealth:
		health = maxHealth

func _getHealth() -> int:
	return health
	
func _getMaxHealth() -> int:
	return maxHealth

func _set_displayHealth(v):
	if v:
		healthGui.visible = true
	else:
		healthGui.visible = false
	displayHealth = v
