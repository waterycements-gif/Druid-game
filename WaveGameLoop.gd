extends Node

@onready var player = $"Player"
@onready var waveLabel = $"Player/WaveLabel"
@onready var enemiesRemainLabel = $"Player/EnemiesRemain"
@onready var punchSound = load("res://Sounds/universfield-punch-04-383965.mp3")
@onready var MagicHitSound = load("res://Sounds/universfield-punch-impact-hit-567196 (mp3cut.net).mp3")
@onready var WindMagicSound = load("res://Sounds/yodguard-wind-magic-5-378630.mp3")
@onready var bangSound = load("res://Sounds/freesound_community-bang-43964.mp3")
@onready var rockSound = load("res://Sounds/lordsonny-small-rock-break-194553 (mp3cut.net).mp3")
@onready var goblinThief = preload("res://Scenes/Goblin Thief.tscn")
@onready var goblinArcher = preload("res://Scenes/Goblin Archer.tscn")
@onready var WolfCavalry = preload("res://Scenes/Wolf Cavalry.tscn")
@onready var BearBoss = preload("res://Scenes/Bear.tscn")
@onready var DeerBoss = preload("res://Scenes/Deer.tscn")
@onready var mantisBoss = preload("res://Scenes/Mantis.tscn")
@onready var NaturespiritCard = load("res://ScreenGUI/NatureCard.png")
@onready var deerCard = load("res://ScreenGUI/DeerCard.png")
@onready var bearCard = load("res://ScreenGUI/BearCard.png")
@onready var mantisCard = load("res://ScreenGUI/MantisCard.png")
@onready var spiritSpriteFrames:SpriteFrames = load("res://SpiritSpriteFrames.tres")

@onready var deerSpiritTable = [load("res://Icons/Spirits/DeerIcon.png"),"Deer",[Move.new(1.3,6,8,1,3,Vector2(30,0),Vector2(40,0),Vector2(60,50),"Ram",[2],null,punchSound,0,1,[KEY_K,KEY_L]),Move.new(1.3,10,5,1,4,Vector2(0,25),Vector2(0,0),Vector2(100,50),"Prance",[1],null,bangSound,1,1,[KEY_J,KEY_I],true,false,false,Vector2(),1,Vector2(500,0),"Prance","straight",false,true),Move.new(1.3,7.5,2,2,1,Vector2(),Vector2(),Vector2(41,13),"Radiance",[6,7,8],WindMagicSound,MagicHitSound,1,1,[KEY_I,KEY_I],true,false,true,Vector2(),5,Vector2(500,0),"RadianceArrow","straight",false,false,Vector2(35,0))]]
@onready var bearSpiritTable = [load("res://Icons/Spirits/BearIcon.png"),"Bear",[Move.new(1.3,13,10,3,2,Vector2(34,1),Vector2(0,-12),Vector2(48,58.5),"Swipe",[3],null,punchSound,0,1,[KEY_I,KEY_K]),Move.new(1.3,20,25,4,4,Vector2(200,45),Vector2(0,-12),Vector2(350,10),"Quake",[6],rockSound,null,1,1,[KEY_I,KEY_L],true)]]

@onready var BossHealth = $"Player/BossHealth"
@onready var BossHealthDecay = $"Player/BossHealth/BossDecay"
@onready var BossNameLabel = $"Player/BossHealth/BossName"
@onready var IconPointer = $"Player/IconPointer"
@onready var IconPointersIcon = $"Player/IconPointer/Icon"
@onready var levelUpSelection = $"Player/LevelUpSelection"
const maxEnemyCount = 5
const EnemyImageSize = "40x40"
var waveNum = 0
var endlessWaveNum = 0
var enemiesRemaining = null
var currentEnemyCount = 0
var AllEnemiesKilled = false
var waveValues = [[[null]],[["T",1]],[["T",7],["A",1]],[["T",8],["A",3]],[["D",1],["B",1]],[["T",12],["A",6]],[["T",14],["A",7],["C",1]],[["T",15],["A",7],["C",3]],[["T",17],["A",9],["C",5]],[["T",19],["A",10],["C",6]],[["M",1]]]
const StartGame = true

signal gameReady
signal allDead
signal AnyEnemyDied
signal selectedAnOption

func updateEnemyRemainingText(returnIcon = false):
	enemiesRemainLabel.text = "Enemies remaining:\n"
	var Icon = ""
	for e in enemiesRemaining:
		if e[0] == "T":
			Icon = "res://Icons/Enemies/GoblinThief.png"
		elif e[0] == "A":
			Icon = "res://Icons/Enemies/GoblinArcher.png"
		elif e[0] == "C":
			Icon = "res://Icons/Enemies/WolfCavalry.png"
		elif e[0] == "B":
			Icon = "res://Icons/Spirits/BearIcon.png"
		elif e[0] == "D":
			Icon = "res://Icons/Spirits/DeerIcon.png"
		else:
			Icon = "res://Icons/Spirits/UnknownIcon.png"
		enemiesRemainLabel.text += "[img="+EnemyImageSize+"]"+Icon+"[/img]"
		enemiesRemainLabel.text += "X" + str(e[1])
	if returnIcon:
		return Icon

func _ready() -> void:
	await gameReady
	while StartGame:
		var boss = null
		AllEnemiesKilled = false
		waveNum += 1
		endlessWaveNum += 1
		waveLabel.text = "Wave " + str(endlessWaveNum)
		var currentWaveValues:Array = waveValues[waveNum]
		if waveNum == 5 or waveNum == 10:
			currentWaveValues = [currentWaveValues[round(randf_range(0,currentWaveValues.size()-1))]]
			boss = currentWaveValues[0][0]
		var totalEnemyCount = 0
		for i in currentWaveValues:
			totalEnemyCount += i[1]
		enemiesRemaining = currentWaveValues.duplicate_deep()
		var PossibleBossIcon = updateEnemyRemainingText(true)
		for i in totalEnemyCount:
			var randomEnemyIndex = randi_range(0,currentWaveValues.size()-1)
			var loadedEnemy = currentWaveValues[randomEnemyIndex][0]
			if loadedEnemy == "T":
				loadedEnemy = goblinThief
			elif loadedEnemy == "A":
				loadedEnemy = goblinArcher
			elif loadedEnemy == "C":
				loadedEnemy = WolfCavalry
			elif loadedEnemy == "B":
				loadedEnemy = BearBoss
			elif loadedEnemy == "D":
				loadedEnemy = DeerBoss
			elif loadedEnemy == "M":
				loadedEnemy = mantisBoss
			currentWaveValues[randomEnemyIndex][1] -= 1
			if currentWaveValues[randomEnemyIndex][1] == 0:
				currentWaveValues.remove_at(randomEnemyIndex)
			var instance = loadedEnemy.instantiate()
			if boss:
				var health:Health = instance.find_child("Health")
				BossHealth.value = 0
				BossHealthDecay.value = 0
				health.healthGui = BossHealth
				health.decayGui = BossHealthDecay
				health.hideHealthAfterFull = false
				waveLabel.visible = false
				enemiesRemainLabel.visible = false
				BossNameLabel.text = instance.name
				BossHealth.visible = true
				var tween = get_tree().create_tween()
				tween.tween_property(BossHealthDecay,"value",100,3)
				tween.tween_property(BossHealth,"value",100,1).set_delay(3.5)
				await tween.finished
				IconPointer.visible = true
				IconPointersIcon.texture = load(PossibleBossIcon)
			instance.target = player
			instance.global_position = Vector2(randf_range(-10000,8000),-10)
			add_child(instance)
			await get_tree().physics_frame
			instance.health.entityDied.connect(func():
				AnyEnemyDied.emit()
				currentEnemyCount -= 1
				if currentEnemyCount <= 0:
					AllEnemiesKilled = true
					allDead.emit()
				enemiesRemaining[randomEnemyIndex][1] -= 1
				updateEnemyRemainingText()
				)
			currentEnemyCount += 1
			if maxEnemyCount <= currentEnemyCount:
				await AnyEnemyDied
			while boss and not AllEnemiesKilled:
				var BossDistance = (instance.global_position - player.global_position)
				if BossDistance.length() > 500:
					if IconPointer.visible == false:
						IconPointer.visible = true
					IconPointersIcon.flip_v = BossDistance.x < 0
					IconPointer.look_at(instance.global_position)
					var Opacity = 1.01**(BossDistance.length()/49.08102) - .5
					if Opacity > 1:
						IconPointer.modulate.a = 1
					else:
						IconPointer.modulate.a = Opacity
				else:
					IconPointer.visible = false
				await get_tree().physics_frame
			await get_tree().create_timer(randf_range(.5,1)).timeout
		if boss == null:
			await allDead
			enemiesRemainLabel.text = "You cleared the wave, Good Job"
		else:
			BossHealth.visible = false
			IconPointer.visible = false
			waveLabel.visible = true
			enemiesRemainLabel.visible = true
			var Bname = ""
			player.addButton()
			if boss == "B":
				player.setDefaultSpirit(bearSpiritTable[0],bearSpiritTable[1],bearSpiritTable[2],player.selectedSpirits.size())
				Bname = "Bear"
			elif boss == "D":
				player.setDefaultSpirit(deerSpiritTable[0],deerSpiritTable[1],deerSpiritTable[2],player.selectedSpirits.size())
				Bname = "Deer"
			else:
				Bname = "No name"
			if boss != "M":
				enemiesRemainLabel.text = "Congrats! You defeated the boss, '" + Bname + "' and they have been claimed as a spirit!"
			else:
				enemiesRemainLabel.text = "Congratuations, you killed the mantis boss and finished the game! You may exit from the menu in the top left corner"
		await get_tree().create_timer(4).timeout
		
		#I know this is super ugly but i do not have time to care
		if player.unrewardedLevelUps > 0:
			if player.lockedMoves.size() > 0:
				levelUpSelection.visible = true
				for a in range(player.unrewardedLevelUps):
					var randomSelectedMove1 = player.lockedMoves[randf_range(0,player.lockedMoves.size())]
					var move1Index
					var move2Index
					player.lockedMoves.erase(randomSelectedMove1)
					levelUpSelection.get_child(0).get_child(0).text = randomSelectedMove1[1]
					levelUpSelection.get_child(0).get_child(1).texture = spiritSpriteFrames.get_frame_texture(randomSelectedMove1[1],0)
					if randomSelectedMove1[2] == "Nature Spirit":
						move1Index = 0
						levelUpSelection.get_child(0).texture_normal = NaturespiritCard
					elif randomSelectedMove1[2] == "Bear" or randomSelectedMove1[2] == "Deer":
						move1Index = 1
						if randomSelectedMove1[2] == "Deer":
							levelUpSelection.get_child(0).texture_normal = deerCard
						else:
							levelUpSelection.get_child(0).texture_normal = bearCard
					elif randomSelectedMove1[2] == "Mantis":
						move1Index = 2
						levelUpSelection.get_child(0).texture_normal = mantisCard
					
					var randomSelectedMove2 = player.lockedMoves[randf_range(0,player.lockedMoves.size())]
					levelUpSelection.get_child(1).get_child(0).text = randomSelectedMove2[1]
					levelUpSelection.get_child(1).get_child(1).texture = spiritSpriteFrames.get_frame_texture(randomSelectedMove2[1],0)
					player.lockedMoves.erase(randomSelectedMove2)
					if randomSelectedMove2[2] == "Nature Spirit":
						move2Index = 0
						levelUpSelection.get_child(1).texture_normal = NaturespiritCard
					elif randomSelectedMove2[2] == "Bear" or randomSelectedMove2[2] == "Deer":
						move2Index = 1
						if randomSelectedMove2[2] == "Deer":
							levelUpSelection.get_child(1).texture_normal = deerCard
						else:
							levelUpSelection.get_child(1).texture_normal = bearCard
					elif randomSelectedMove2[2] == "Mantis":
						move2Index = 2
						levelUpSelection.get_child(1).texture_normal = mantisCard
					levelUpSelection.get_child(0).button_down.connect(func():
						player.addLockedMove(move1Index,randomSelectedMove1)
						selectedAnOption.emit()
						)
					levelUpSelection.get_child(1).button_down.connect(func():
						player.addLockedMove(move2Index,randomSelectedMove2)
						selectedAnOption.emit()
						)
					levelUpSelection.get_child(2).button_down.connect(func():
						player.adjust_health(player.health.maxHealth*.5)
						selectedAnOption.emit()
						)
					await selectedAnOption
					for i:TextureButton in levelUpSelection.get_children():
						i.button_down.disconnect(i.button_down.get_connections()[0].callable)
				levelUpSelection.visible = false
			player.unrewardedLevelUps = 0
		for i in range(5,0,-1):
			enemiesRemainLabel.text = "Wave "+str(waveNum+1)+" begins in " + str(i)
			await get_tree().create_timer(1).timeout
	waveLabel.visible = false
	enemiesRemainLabel.visible = false
