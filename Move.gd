class_name Move extends Node

@export_group("Basic parameters")
##How long the move is on cooldown for
@export var cdLen = 1.0
##How much damage it does
@export var damage = 1
##The horizontal knockback the victum takes
@export var knockback = 0
##The vertical knockback the victum takes
@export var upwardsKnockback = 0
##The offset of where the knockback is positioned
@export var knockbackOffset = Vector2()
##The frame(s) the 'attack sprite' needs to hit for it to activate
@export var attackFrame:PackedInt32Array
##How many loops it takes
@export var loops = 1
##Increases the scale of the attack
@export var scale = 1.0
##Where the hitbox is
@export var attackRange = Vector2()
##How large the hitbox is
@export var attackSize = Vector2(1,1)
##Where the 'attack sprites' position is relative to attack range
@export var spritePosition = Vector2()
##The animation name, find animations in the entity sprite or the 'SpiritSpriteFrames'.
@export var animName:String
##Cancels the attack after being attacked
@export var cancelAfterDamaged = false
##Hides the 'entity sprite' before attacking
@export var hideEntity = false
##Becomes stationary while attacking
@export var stationaryWhileAttacking = false
##Becomes able to hit knocked down enemies
@export var ableToHitKnockedDown = false
##Determines if the 'attack sprite' is over the 'entity sprite'
@export var overSprite = false

@export var startingSound:AudioStream

@export var HitSound:AudioStream

@export var basePitch:float

@export var amountOfStun = 1
@export_group("Bot parameters")
##How close the bot gets to the player
@export var botDistanceRequired = 0
##The maxinum distance required to trigger the attack
@export var hitboxDistanceRequired = 0
##Temporarily removes the entity's collision
@export var removeCollision = false
@export_group("Projectile parameters")
##How fast the projectile moves (For a move to be a projectile, 'projectileSpeed' needs to be greater than 0)
@export var projectileSpeed = 0.0
##Where the target is
@export var targetPosition:Vector2
##The point the projectile is spawned on
@export var projectilePosition:Vector2
##The projectile's animation name, to find those animations look into this entity's attackSprite
@export var projectileAnimationName:String
##The arc of the projectile, can either be 'straight', or 'halfed'. Input needs to be lowercase
@export var projectileArc = "straight"
##If the projectile sticks into the ground
@export var stick = false
##If the projectile continues after hitting a object
@export var continueAfterHit = false
var keys = {}
var cd = false
var cooldownTimer = Timer.new() 
signal onCooldown()
func _ready():
	add_child(cooldownTimer)

func _init(inputscale = 1.0, inputCd = -1.0, inputDamage = 0, inputKnockback =-1,
	inputUpwardsKnockback = -1, inputAttackRange = Vector2(),
	inputspiritPosition = Vector2(), inputAttackSize = Vector2(1,1),
	inputAnimName = "",inputAttackFrame = [],
	inputstartingSound = null, inputhitsound = null, inputbasepitch = 0,
	inputloops = -1,
	inputKeys = {},inputableToHitKnockedDown = false, inputoverSprite = false, inputstationary = false, inputknockbackOffset = Vector2(), inputProjectileSpeed = 0, inputtargetPosition = Vector2(),
	inputprojectileAnimationName= null, inputprojectileArc = "straight", inputstick = false, inputcontinueAfterHit = false, inputprojectilePosition = Vector2()
	) -> void:
#----------------------------------------------------#
	if inputCd > -1:
		cdLen = inputCd
	if inputDamage != 0:
		damage = inputDamage
	if inputKnockback != 0:
		knockback = inputKnockback
	if inputUpwardsKnockback != 0:
		upwardsKnockback = inputUpwardsKnockback
	if inputAttackRange:
		attackRange = inputAttackRange
	if inputAttackSize != Vector2(1,1):
		attackSize = inputAttackSize
	if inputAttackFrame.size() > 0:
		attackFrame = inputAttackFrame
	if inputloops > -1:
		loops = inputloops
	if inputAnimName != "":
		animName = inputAnimName
	if inputKeys.get(0):
		keys = inputKeys
	if inputProjectileSpeed != 0:
		projectileSpeed = inputProjectileSpeed
	if inputtargetPosition:
		targetPosition = inputtargetPosition
	if inputspiritPosition:
		spritePosition = inputspiritPosition
	if inputscale != 1:
		scale = inputscale
	if inputprojectileAnimationName:
		projectileAnimationName = inputprojectileAnimationName
	if inputknockbackOffset:
		knockbackOffset = inputknockbackOffset
	if inputprojectileArc != "straight":
		projectileArc = inputprojectileArc
	if inputstick:
		stick = true
	if inputcontinueAfterHit:
		continueAfterHit = true
	if inputableToHitKnockedDown:
		ableToHitKnockedDown = true
	if inputoverSprite:
		overSprite = true
	if inputstationary:
		stationaryWhileAttacking = true
	if inputprojectilePosition:
		projectilePosition = inputprojectilePosition
	if inputstartingSound:
		startingSound = inputstartingSound
	if inputhitsound:
		HitSound = inputhitsound
	if inputbasepitch > 0:
		basePitch = inputbasepitch

func cooldownOn():
	cd = true
	onCooldown.emit()

func useMove():
	cooldownTimer.start(cdLen)
	await cooldownTimer.timeout
	cd = false
	
func lift_cooldown():
	cooldownTimer.emit_signal("timeout")
