class_name Entity extends CharacterBody2D

var ableToAttack = true
var enemy
var attackDirection = 1
var direction:float
##Put the AudioStreamPlayer2D or 'hittingSounds' here, duh
@export var hittingSounds:AudioStreamPlayer2D
##Put the hurtbox here, duh
@export var hurtbox:Hurtbox
##Put the sprite here, duh
@export var entitySprite:AnimatedSprite2D
##Put a timer here, duh
@export var stunTimer:Timer
##Put the health CLASS here
@export var health: Health
##The character that this entity chases, leave blank for player
@export var target: CharacterBody2D
##how high he jumps
@export var jumpHight = 4.0
##how fast they run
@export var speed = 2.0
##causes it to stop moving
@export var stationary:bool = false
##what do you think this does
@export var canAttack:bool = true
##The maxinum distance away from the player, only works if there is a target
@export var maxinumDistance = 0.0

@export var jumpSounds:AudioStreamPlayer2D
@onready var previousCollayer = collision_layer
@onready var previoyscolmask = collision_mask
@onready var hurtboxmask = hurtbox.collision_mask
@onready var hurtbolayer = hurtbox.collision_layer
@onready var originallyStationed = stationary
var Stunned:bool = false
var onFloor = true
var attackedBehind = false
var dead = false
var stunHits = 0
var attackCanceled = false
var doNotInteruptAnim = false
var chargeDirection = 0
var distanceForHitbox = 0
var stationaryWhileAttacking = false
var physics = true
var onground = false
var projectileFinalTargetPosition

signal entityTouchedFloor()
signal turnAround()
signal entityInRange()
signal becameUnstunned()

func _ready() -> void:
	jumpHight *= -100
	speed *= 100
	if target and stationary:
		attackDirection = (target.transform.origin.x - transform.origin.x)
		attackDirection /= abs(attackDirection)
	health.entityDied.connect(entityDeath)
	hurtbox.recievedDmg.connect(func(_dmg, pos, knockback,upwardsKnockback,offset,damageKnockedDown,amountStunned):
		if (entitySprite.animation != "knockedDown" or damageKnockedDown) and not dead:
			var knockbackDirectionWithoutOffset = (pos - entitySprite.global_position)
			var knockbackDirection = knockbackDirectionWithoutOffset - (offset*-knockbackDirectionWithoutOffset/abs(knockbackDirectionWithoutOffset))
			knockbackDirection/=abs(knockbackDirection)
			stunHits+=amountStunned
			entityAirStun()
			if knockbackDirection.x != 0:
				if is_on_floor():
					velocity = -Vector2(knockbackDirection.x*knockback*150,upwardsKnockback*100)
				else:
					velocity = -knockbackDirection*(knockback*100)
			elif is_on_floor():
				velocity = -Vector2(knockback*150,upwardsKnockback*100)
	)
		

func playEntityAnimation(animName,backwards = false,uninterupttable = false):
	if not (dead or doNotInteruptAnim):
		doNotInteruptAnim = uninterupttable
		if entitySprite.animation != animName:
			entitySprite.stop()
		if entitySprite.sprite_frames.has_animation(animName):
			if backwards:
				entitySprite.play_backwards(animName)
			else:
				entitySprite.play(animName)
			if uninterupttable:
				await entitySprite.animation_finished
				doNotInteruptAnim = false
		else:
			push_warning("Animation '" + animName + "' does not exist within entity '" + name + "'")
			entitySprite.play("error")


func entityDeath():
	health.entityDied.disconnect(entityDeath)
	playEntityAnimation("death")
	dead = true
	Stunned = false
	stunTimer.emit_signal("timeout")
	stationary = true
	set_collision(false)
	if health.healthGui.get_parent() == $".":
		health.healthGui.queue_free()
	health.queue_free()
	stunTimer.queue_free()
	await get_tree().create_timer(5).timeout
	var tween = get_tree().create_tween()
	tween.tween_property(entitySprite,"modulate:a",0,.5)
	await tween.finished
	queue_free()

func _physics_process(delta: float) -> void:
	if stationary == false:
		if not target:
			direction = Input.get_axis("A", "D")
			if Input.is_key_pressed(KEY_SPACE) and is_on_floor() and Stunned == false:
				velocity.y = jumpHight
		else:
			direction = (target.transform.origin.x - transform.origin.x)
			direction = direction/abs(direction)
			if direction:
				if target.global_position.x + distanceForHitbox >= global_position.x and direction < 0 or target.global_position.x - distanceForHitbox <= global_position.x and direction > 0:
					entityInRange.emit()
				if chargeDirection != 0 and maxinumDistance > 0:
					chargeDirection = 0
				if maxinumDistance < 0:
					if chargeDirection == 0:
						chargeDirection = (direction * abs(maxinumDistance*100))/(speed/2)
					direction = chargeDirection
				elif target.global_position.x + maxinumDistance > global_position.x and direction < 0 or target.global_position.x - maxinumDistance < global_position.x and direction > 0:
					direction = -direction
				elif not(target.global_position.x + maxinumDistance < global_position.x-(speed/25) and direction < 0 or target.global_position.x - maxinumDistance > global_position.x+(speed/25) and direction > 0):
					direction = 0
				if target.transform.origin.y - transform.origin.y < -40  and is_on_floor() and Stunned == false and chargeDirection == 0:
					velocity.y = jumpHight
	
		if direction:
			if attackDirection != direction:
				playEntityAnimation("walk",true)
				var oneWay = get_tree().create_timer(1.5)
				oneWay.timeout.connect(func(): turnAround.emit(),CONNECT_ONE_SHOT)
				turnAround.connect(func():
					oneWay.emit_signal("timeout")
					if round(direction) != 0 and (attackDirection != direction or attackedBehind):
						attackedBehind = false
						attackDirection = direction
						entitySprite.flip_h = attackDirection < 0
					, CONNECT_ONE_SHOT)
			else:
				playEntityAnimation("walk")
			if target and (target.global_position.x + maxinumDistance+speed/15 > global_position.x and direction < 0 or target.global_position.x - maxinumDistance-speed/15 < global_position.x and direction > 0):
				velocity.x = direction * (speed/2)
			else:
				velocity.x = direction * speed
		else:
			playEntityAnimation("idle")
			velocity.x = move_toward(velocity.x, 0, speed)
			if attackDirection != direction:
				if entitySprite.flip_h:
					attackDirection = -1
				else:
					attackDirection = 1
				turnAround.emit()
	elif is_on_floor() and physics:
		#entitySprite.play("default")
		velocity.x = move_toward(velocity.x, 0, 3)
	if not is_on_floor() and physics:
		if Stunned == false:
			playEntityAnimation("falling")
		onFloor = false
		velocity += get_gravity() * delta
	elif onFloor == false:
		onFloor = true
		jumpSounds.play()
		entityTouchedFloor.emit()
	if not physics and velocity:
		velocity = Vector2()
	move_and_slide()

func entityAirStun():
	if not stunTimer:
		return
	stationary = true
	if entitySprite.animation != "knockedDown":
		playEntityAnimation("idle")
		await get_tree().create_timer(.2).timeout
		playEntityAnimation("stunned")
	if stunHits >= 6:
		stunTimer.start(2)
		if not onground:
			onground = true
			if onFloor == false:
				await entityTouchedFloor
			hurtbox.set_entityKnockedDown(true)
			playEntityAnimation("knockedDown")
	elif stunHits == 1:
		stunTimer.start(.5)
	elif stunTimer:
		stunTimer.start(.7*(stunHits/2.0))
	if Stunned:
		return
	Stunned = true
	await stunTimer.timeout
	onground = false
	Stunned = false
	if dead == false and stationaryWhileAttacking == false:
		stationary = originallyStationed
	stunTimer.stop()
	stunHits = 0
	if dead == false:
		if hurtbox.entityKnockedDown:
			hurtbox.set_entityKnockedDown(false)
		playEntityAnimation("idle")
	becameUnstunned.emit()

func attack(move:Move,attackSprite:AnimatedSprite2D):
	if canAttack == false:
		move.cooldownOn()
		return
	attackCanceled = false
	var hitbox:Hitbox = attackSprite.get_child(0)
	var HitboxShape = hitbox.get_child(0)
	var cancelAfterDamaged = func(a,_b,_c,_d,_e,_f,_g):
		attackCanceled = true
		if move.name == "Parry":
			for i in move.attackFrame:
				if attackSprite.frame == i:
					adjust_health(a)
					if move.startingSound:
						hittingSounds.stream = move.startingSound
						hittingSounds.pitch_scale = move.basePitch + randf_range(-.2,.2)
						hittingSounds.play()
					HitboxShape.disabled = false
					await get_tree().physics_frame
					HitboxShape.disabled = true
	hurtbox.recievedDmg.connect(cancelAfterDamaged)
	if attackDirection != direction/abs(direction) and not target:
		attackedBehind = true
		turnAround.emit()
	if move.hideEntity:
		entitySprite.visible = false
	if move.overSprite:
		attackSprite.z_index = entitySprite.z_index+1
	else:
		attackSprite.z_index = entitySprite.z_index-1
	move.cooldownOn()
	if move.stationaryWhileAttacking:
		stationary = true
		stationaryWhileAttacking = true
		physics = false
	projectileFinalTargetPosition = move.targetPosition
	if not target:
		attackSprite.flip_h = attackDirection < 0
		projectileFinalTargetPosition *= attackDirection
		projectileFinalTargetPosition += global_position
	else:
		direction = (target.transform.origin.x - transform.origin.x)
		direction/=abs(direction)
		entitySprite.flip_h = direction < 0
		attackSprite.flip_h = entitySprite.flip_h
	attackSprite.scale = Vector2(move.scale,move.scale)
	attackSprite.visible = true
	attackSprite.animation = move.animName
	attackSprite.frame = 0
	attackSprite.global_position = entitySprite.global_position + Vector2(move.spritePosition.x*attackDirection,move.spritePosition.y)
	hitbox.set_dmg(move.damage)
	hitbox.set_knocback(move.knockback)
	hitbox.set_upwardsKnockback(move.upwardsKnockback)
	hitbox.set_offset(move.knockbackOffset)
	hitbox.set_damageKnockedDown(move.ableToHitKnockedDown)
	hitbox.set_injuredSound(move.HitSound)
	hitbox.set_amountOfStun(move.amountOfStun)
		
	if move.projectileSpeed <= 0:
		if target:
			HitboxShape.global_position = entitySprite.global_position + Vector2(move.attackRange.x*direction,move.attackRange.y)
		else:
			HitboxShape.global_position = entitySprite.global_position + Vector2(move.attackRange.x*attackDirection,move.attackRange.y)
		HitboxShape.shape.size = move.attackSize
	var attackOnFrame = func():
		if attackCanceled and move.cancelAfterDamaged:
			attackSprite.emit_signal("animation_finished")
			return
		if move.name != "Parry":
			for i in move.attackFrame:
				if attackSprite.frame == i:
					if move.startingSound:
						hittingSounds.stream = move.startingSound
						hittingSounds.pitch_scale = move.basePitch + randf_range(-.2,.2)
						hittingSounds.play()
					if move.projectileSpeed <= 0:
						HitboxShape.disabled = false
						await attackSprite.frame_changed
						HitboxShape.disabled = true
					else:
						if target and move.projectileArc == "halfed":
							projectileFinalTargetPosition = Vector2(target.global_position.x+(abs(target.global_position.y)*direction),50-move.attackSize.x/2)
						elif target:
							projectileFinalTargetPosition = (target.global_position+Vector2(target.global_position.x*0.5*-direction,0))/scale
						get_parent().find_child("Projectiles").add_New_Projectile(attackSprite.global_position+(move.projectilePosition*Vector2(attackDirection,1)),move.attackRange,move.attackSize,hurtbox,move.projectileAnimationName,attackSprite.flip_h,move.projectileSpeed,projectileFinalTargetPosition,move.projectileArc,move.stick,move.damage,move.knockback,move.continueAfterHit,scale*move.scale,move.HitSound)
	attackSprite.frame_changed.connect(attackOnFrame)
	for i in move.loops:
		attackSprite.play(move.animName)
		await attackSprite.animation_finished
	if move.animName == "Parry" and attackCanceled:
		attackSprite.play("ParryEnd")
		await attackSprite.animation_finished
	HitboxShape.disabled = true
	attackSprite.frame_changed.disconnect(attackOnFrame)
	hurtbox.recievedDmg.disconnect(cancelAfterDamaged)
	if target:
		attackSprite.visible = false
	if move.hideEntity:
		entitySprite.visible = true
	if move.stationaryWhileAttacking:
		physics = true
		stationaryWhileAttacking = false
		if not Stunned:
			stationary = false
	move.useMove()

func set_stationary(v):
	stationary = v

func set_can_attack(v):
	canAttack = v

func set_physics(v):
	physics = v
	
func set_collision(val):
	if val:
		collision_layer = previousCollayer
		collision_mask = previoyscolmask
	else:
		collision_mask = 1 << 31
		collision_layer = 0

func set_invulnerable(val):
	if val:
		hurtbox.collision_layer = 0
		hurtbox.collision_mask = 0
	else:
		hurtbox.collision_layer = hurtbolayer
		hurtbox.collision_mask = hurtboxmask

func adjust_health(val):
	health._changeHealth(val,null)
