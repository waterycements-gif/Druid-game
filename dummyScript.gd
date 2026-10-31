extends Entity

@onready var hitbox = $"AttackSprite"/Hitbox
@onready var attacks = $"Attacks"
@onready var attackSprite:AnimatedSprite2D = $"AttackSprite"
@onready var HitboxShape = $"AttackSprite/Hitbox/CollisionShape2D"
@onready var orginisedArr = attacks.get_children()
@onready var maxDist = maxinumDistance
var leastTimeToWaitTimer:Timer

func _ready() -> void:
	super()
	attackSprite.visible = false
	entitySprite.visible = true
	
	var turnLoopOn = orginisedArr.size() > 0
	while turnLoopOn:
		if attackSprite.visible == false and not dead and not Stunned:
			var allMovesOnCd = 0
			set_collision_mask_value(1,true)
			leastTimeToWaitTimer = orginisedArr[0].cooldownTimer
			for i:Move in orginisedArr:
				if i.cd == false:
					i.cd = true
					maxinumDistance = i.botDistanceRequired
					distanceForHitbox = i.hitboxDistanceRequired
					if i.removeCollision:
						set_collision(false)
					else:
						set_collision_mask_value(1,false)
					await entityInRange
					await attack(i,attackSprite)
					if i.removeCollision:
						set_collision(true)
					break
				else:
					if leastTimeToWaitTimer.time_left > i.cooldownTimer.time_left and i.cooldownTimer.time_left != i.cooldownTimer.wait_time:
						leastTimeToWaitTimer = i.cooldownTimer
					allMovesOnCd += 1
			maxinumDistance = maxDist
			if allMovesOnCd >= orginisedArr.size():
				await leastTimeToWaitTimer.timeout
		elif Stunned:
			await becameUnstunned
		elif dead:
			break
