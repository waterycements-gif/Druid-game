extends Entity

@onready var songFrame:Sprite2D = $"Guis/SongFrame"
@onready var timer:Timer = songFrame.get_child(3)
@onready var spiritSelection = $"Guis/Menu/Visiblity/MenuButtons/SCSK/KeysVisible/SpiritSelection"
@onready var itemList:ItemList = spiritSelection.get_child(1)
@onready var deathScreen = $"Guis/You died"
@onready var openSpiritMenu = spiritSelection.get_child(0)
@onready var gridContainer = spiritSelection.get_child(2)
@onready var spiritMoves = $"SpiritMoves"
@onready var spiritSprites = $SpiritSprites
@onready var spiritSpritesChildren = spiritSprites.get_children()
@onready var dashTimer = $"DashTimer"
@onready var kickTimer = $"KickTimer"
@onready var dashBars = [$"Guis/DashGui"]
@onready var guis = $"Guis"
@onready var CoolDownList = $"Guis/CoolDownList"
@onready var basicAttackHitbox = $"PlayerSprite/Hitbox/CollisionShape2D"
@onready var camera = $"PlayerSprite/Camera2D"
@onready var experienceBar = $"Guis/Experience"
@onready var multipliedExpLabel = $"Guis/Experience/MultipliedExp"
@onready var menu = $"Guis/Menu"
@onready var MenusVisbility = $"Guis/Menu/Visiblity"
@onready var menuButtons = $"Guis/Menu/Visiblity/MenuButtons"
@onready var cloneableMoveInstructions = $"Guis/Menu/Visiblity/MenuButtons/SCSK/KeysVisible/ScrollBox/VBoxContainer/Cloneable"
@onready var SpiritKeysVisiblity = $"Guis/Menu/Visiblity/MenuButtons/SCSK/KeysVisible"
@onready var SpiritKeyVBox = $"Guis/Menu/Visiblity/MenuButtons/SCSK/KeysVisible/ScrollBox/VBoxContainer"

@onready var JKey = load("res://ScreenGUI/Jkey.png")
@onready var IKey = load("res://ScreenGUI/Ikey.png")
@onready var KKey = load("res://ScreenGUI/Kkey.png")
@onready var LKey = load("res://ScreenGUI/Lkey.png")
@onready var DashJuice = load("res://ScreenGUI/DashJuice.png")
@onready var BeforeAfterDashFrame = load("res://ScreenGUI/BeforeAfterDashFrame.png")
@onready var punchSound = load("res://Sounds/universfield-punch-04-383965.mp3")
@onready var MagicHitSound = load("res://Sounds/universfield-punch-impact-hit-567196 (mp3cut.net).mp3")
@onready var WindMagicSound = load("res://Sounds/yodguard-wind-magic-5-378630.mp3")
@onready var bangSound = load("res://Sounds/freesound_community-bang-43964.mp3")
@onready var rockSound = load("res://Sounds/lordsonny-small-rock-break-194553 (mp3cut.net).mp3")
@onready var sliceSounds = load("res://Sounds/dragon-studio-sword-slice-2-393845 (mp3cut.net)(1).mp3")
@onready var testSpiritTable = [load("res://Icons/Spirits/DeerIcon.png"),"Deer",[Move.new(1.3,6,8,1,3,Vector2(30,0),Vector2(40,0),Vector2(60,50),"Ram",[2],null,punchSound,0,1,[KEY_K,KEY_L]),Move.new(1.3,10,5,1,4,Vector2(0,25),Vector2(0,0),Vector2(100,50),"Prance",[1],null,bangSound,1,1,[KEY_J,KEY_I],true,false,false,Vector2(),1,Vector2(500,0),"Prance","straight",false,true),Move.new(1.3,7.5,2,2,1,Vector2(),Vector2(),Vector2(41,13),"Radiance",[6,7,8],WindMagicSound,MagicHitSound,1,1,[KEY_I,KEY_I],true,false,true,Vector2(),5,Vector2(500,0),"RadianceArrow","straight",false,false,Vector2(35,0))]]
const inputOrder := [74,75,76,73]
const kickFrameOrder := [["kick1",7],["kick2",4],["kick3",3]]
var input1
var input2
var input3
var index = 0
var dashspeed = 800
var maxDashes = 1
var dashUsesLeft = maxDashes
var spiritMenuOpened = false
var selectedSpirits = {}
var cooldownIndex = []
var kickint = 0
var kickCd = false
var punchStreak = 0
var streakTimeout = 0
var unrewardedLevelUps = 0

var lockedMoves = []

signal pickedSpirit()
signal dashed()

func increaseExperience():
	var multiplier = 1+(punchStreak/5.0)
	if multiplier > 5:
		multiplier = 5
	experienceBar.value += multiplier
	punchStreak += 1
	streakTimeout = 5
	multipliedExpLabel.text = "x"+str(multiplier)
	
	#If you want to see the hits you landed while in a streak then make the 'Hitcounter' visible and 'de-comment' the 70th line. 
	#Player > Guis > Experience > Hitcounter
	#$"Guis/Experience/Hitcounter(debug)".text = "Hits: "+str(punchStreak) 
	
	if experienceBar.value >= experienceBar.max_value:
		experienceBar.value = 0
		experienceBar.max_value *= 1.2
		unrewardedLevelUps+=1

func InheritKeys(moveName,keys:Array):
	for i in SpiritKeyVBox.get_children():
		if i.text == moveName:
			return
	var newClone
	if cloneableMoveInstructions.text != "Nothing\n":
		newClone = cloneableMoveInstructions.duplicate()
		SpiritKeyVBox.add_child(newClone)
		SpiritKeyVBox.move_child(newClone,SpiritKeyVBox.get_child_count()-2)
	else:
		newClone = cloneableMoveInstructions
	newClone.text = moveName + "\n"
	for i in range(2):
		var keyInt = keys[i]
		if keyInt == KEY_J:
			newClone.get_child(i+1).texture = JKey
		elif keyInt == KEY_K:
			newClone.get_child(i+1).texture = KKey
		elif keyInt == KEY_L:
			newClone.get_child(i+1).texture = LKey
		elif keyInt == KEY_I:
			newClone.get_child(i+1).texture = IKey

func swapSpirits(btn:Button):
	if itemList.visible == true:
		itemList.visible = false
		pickedSpirit.emit()
	else:
		var buttonIndex = btn.get_index()
		itemList.position = gridContainer.position + (Vector2(btn.size.x,(btn.size.y+gridContainer.get_theme_constant("v_separation"))*buttonIndex)*gridContainer.scale)
		itemList.visible = true
		itemList.item_selected.connect(func(_b):
			pickedSpirit.emit()
		, CONNECT_ONE_SHOT)
		await pickedSpirit
		if itemList.visible == false:
			return;
		var itemIndex = itemList.get_selected_items()[0]
		var item = {metaData = itemList.get_item_metadata(itemIndex), icon = itemList.get_item_icon(itemIndex), description = itemList.get_item_text(itemIndex)}
		var previousSpirit = selectedSpirits.get(buttonIndex)
		btn.icon = item.icon
		itemList.remove_item(itemIndex)
		selectedSpirits.set(buttonIndex,item)
		if previousSpirit:
			itemList.add_item(previousSpirit.description,previousSpirit.icon)
			itemList.set_item_metadata(itemList.item_count-1,previousSpirit.metaData)
		itemList.visible = false


func _ready() -> void:
	super()
	CoolDownList.mouse_filter = Control.MOUSE_FILTER_IGNORE
	remove_child(spiritSprites)
	get_parent().add_child.call_deferred(spiritSprites)
	menu.button_down.connect(func():
		for i in get_parent().get_children():
			if i is Entity and not i.originallyStationed:
				i.stationary = true
				i.physics = false
				i.canAttack = false
		MenusVisbility.visible = true
	)
	menuButtons.get_child(0).button_down.connect(func():
		for i in get_parent().get_children():
			if i is Entity and not i.originallyStationed:
				i.stationary = false
				i.physics = true
				i.canAttack = true
		MenusVisbility.visible = false
	)
	menuButtons.get_child(1).button_down.connect(func():
		SpiritKeysVisiblity.visible = not SpiritKeysVisiblity.visible
	)
	menuButtons.get_child(2).button_down.connect(func():
		get_tree().quit()
	)
	openSpiritMenu.button_down.connect(func():
		if spiritMenuOpened == false:
			spiritSelection.position.x += 90
		else:
			spiritSelection.position.x -= 90
		spiritMenuOpened = not spiritMenuOpened
		)
	kickTimer.timeout.connect(func():
		kickint = 0
		basicAttackHitbox.get_parent().set_knocback(0)
	)
	for i:Button in gridContainer.get_children():
		i.pressed.connect(func():
			swapSpirits(i)
			)
	setDefaultSpirit(load("res://Icons/Spirits/NatureSpiritIcon.png"),"Nature Spirit",[Move.new(1,5,6,2,0,Vector2(-7,-3),Vector2(40,0),Vector2(60,90),"Wind Slash",[3],WindMagicSound,sliceSounds,1,1,[KEY_J,KEY_L],true,false,false,Vector2(),3,Vector2(400,0),"Wind Slash Projectile"),Move.new(1,10,0,-3,0,Vector2(175,8),Vector2(175,8),Vector2(300,100),"Gust",[3],WindMagicSound,null,1,1,[KEY_I,KEY_J],false,false,false,Vector2(400,0)),Move.new(1,7,8,3,2,Vector2(),Vector2(),Vector2(200,100),"Wind Shockwave",[7,8],WindMagicSound,null,1,1,[KEY_L,KEY_J],true,true,true)],0)
	
	while true:
		while dashUsesLeft < maxDashes:
			dashTimer.start(2)
			await dashTimer.timeout
			dashUsesLeft += 1
			var recoveredDashGui = dashBars[dashUsesLeft-1]
			var tween = get_tree().create_tween()
			tween.tween_property(recoveredDashGui,"value",100,.1)
			await tween.finished
			recoveredDashGui.texture_progress = DashJuice
		await dashed

func addCooldownGui(cdname,cdTimer:Timer):
	var size = cooldownIndex.size()
	var tableOfVals
	if size < 7:
		var cooldownGui = CoolDownList.get_child(size)
		cooldownGui.value = 100
		cooldownGui.visible = true
		tableOfVals = [cdname,cdTimer,size,cooldownGui]
		cooldownIndex.append(tableOfVals)
		while cdTimer.time_left > 0.1:
			var currentCDGui = tableOfVals[3]
			currentCDGui.get_child(0).text = tableOfVals[0] + "\n" + str(round(cdTimer.time_left*10)/10)
			currentCDGui.value = round(100*cdTimer.time_left/cdTimer.wait_time)
			await get_tree().physics_frame
		cooldownIndex.erase(tableOfVals)
		tableOfVals[3].visible = false
	else:
		tableOfVals = [cdname,cdTimer,size]
	for i in range(size,cooldownIndex.size()):
		var list = cooldownIndex[i]
		if i < 7:
			var forCDGui = list[3]
			forCDGui.visible = false
			list[2] -= 1
			list[3] = CoolDownList.get_child(list[2])
			list[3].visible = true
		elif i == 7:
			var seventhGui = CoolDownList.get_child(6)
			var seventhTable = cooldownIndex[6]
			seventhTable.append(seventhGui)
			seventhGui.value = 100
			seventhGui.visible = true
			while cdTimer.time_left > 0.1:
				var currentCDGui = tableOfVals[3]
				currentCDGui.get_child(0).text = tableOfVals[0] + "\n" + str(round(cdTimer.time_left*10)/10)
				currentCDGui.value = round(100*cdTimer.time_left/cdTimer.wait_time)
				await get_tree().physics_frame
			cooldownIndex.erase(tableOfVals)
		elif i > 7:
			break

func _process(delta: float) -> void:
	if streakTimeout > 0.01:
		streakTimeout -= .01 + delta
	elif punchStreak > 0:
		punchStreak = 0
		multipliedExpLabel.text = "x1"
	if Input.is_action_pressed("leftMouse") and not (kickCd or stationary or Stunned or dead):
		kickCd = true
		if attackDirection != direction/abs(direction):
			attackedBehind = true
			turnAround.emit()
		var absDir = abs(basicAttackHitbox.position)
		basicAttackHitbox.position = Vector2(absDir.x*attackDirection,absDir.y)
		if kickint >= 2:
			kickTimer.start(1.5)
			basicAttackHitbox.get_parent().set_knocback(3)
		else:
			kickTimer.start(2)
		var kickBox = func():
			if entitySprite.frame == kickFrameOrder[kickint][1]:
				basicAttackHitbox.disabled = false
				await entitySprite.frame_changed
				basicAttackHitbox.disabled = true
		entitySprite.frame_changed.connect(kickBox)
		await playEntityAnimation(kickFrameOrder[kickint][0],false,true)
		entitySprite.frame_changed.disconnect(kickBox)
		kickint += 1
		if kickint >= 3:
			await kickTimer.timeout
		kickCd = false

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and event.is_echo() == false:
		var keycode = event.get_keycode()
		if keycode == KEY_J or keycode == KEY_K or keycode == KEY_L or keycode == KEY_I:
			var letter = songFrame.get_child(index)
			letter.visible = true
			if keycode == KEY_I:
				letter.frame = 0
			else:
				letter.frame = keycode-73
			index+=1
			if index == 1:
				input1 = keycode
				songFrame.get_child(1).visible = false
				songFrame.get_child(2).visible = false
				timer.emit_signal("timeout")
				songFrame.visible = true
				timer.start(1)
				await timer.timeout
				if not input3:
					songFrame.visible = false
					index = 0
				else:
					timer.start(.5)
					await timer.timeout
					if not songFrame.get_child(1).visible == false:
						songFrame.visible = false
			elif index == 2:
				input2 = keycode
			elif index == 3:
				input3 = keycode
				index = 0
				timer.emit_signal("timeout")
				var Spiritmove:Move
				var spiritSprite:AnimatedSprite2D
				var spriteIndex = 0
				for i in spiritSpritesChildren:
					if input1 == inputOrder.get(spriteIndex) and selectedSpirits.get(spriteIndex) and i.visible == false:
						spiritSprite = i
						break
					spriteIndex += 1
				if spiritSprite:
					for i in selectedSpirits[spriteIndex].metaData:
						if i[0][0] == input2 and i[0][1] == input3:
							Spiritmove = spiritMoves.find_child(i[1],true,false)
							break
				if Spiritmove != null and not Spiritmove.cd:
					var tween = get_tree().create_tween()
					tween.tween_property(spiritSprite,"modulate:a", .9,.3)
					await attack(Spiritmove,spiritSprite)
					addCooldownGui(Spiritmove.name,Spiritmove.cooldownTimer)
					if Spiritmove.projectileSpeed == 0:
						tween = get_tree().create_tween()
						tween.tween_property(spiritSprite,"modulate:a", 0,.3).set_delay(0.5)
						await tween.finished
				if spiritSprite:
					spiritSprite.visible = false
				input3 = null
		elif keycode == KEY_Q and dashUsesLeft > 0 and Stunned == false and stationary == false:
			stationary = true
			Stunned = true
			#there is a lot of typos here but I don't wanna fix it :) ps. I forgot when I typed this but I think I got rid of them all
			var DashDirection = direction
			if DashDirection == 0:
				DashDirection = (attackDirection/-1)
			set_invulnerable(true)
			set_collision(false)
			var currentDashGui:TextureProgressBar = dashBars[dashUsesLeft-1]
			currentDashGui.texture_progress = BeforeAfterDashFrame
			var tween = get_tree().create_tween()
			tween.tween_property(currentDashGui,"value",0,.1)
			dashUsesLeft -= 1
			velocity.x = dashspeed * DashDirection
			if DashDirection != attackDirection:
				playEntityAnimation("dashbackwards")
			else:
				playEntityAnimation("dashforward")
			await get_tree().create_timer(.3).timeout
			set_invulnerable(false)
			set_collision(true)
			stationary = false
			Stunned = false
			dashed.emit()
			
func addLockedMove(spiritIndex,move):
	var spirit = selectedSpirits[spiritIndex]
	InheritKeys(move[1],move[0])
	spirit.metaData.append([move[0],move[1]])
	

func setDefaultSpirit(Icon,Description,SpiritMoves,ButtonIndex):
	var KeysAndName = []
	var skip1 = true
	for i in SpiritMoves:
		var moveArray = [i.keys, i.animName]
		i.name = i.animName
		spiritMoves.add_child(i)
		if skip1:
			skip1 = false
			KeysAndName.append(moveArray)
			InheritKeys(i.animName,i.keys)
			continue
		moveArray.append(Description)
		lockedMoves.append(moveArray)
	selectedSpirits.set(ButtonIndex,{metaData = KeysAndName, icon = Icon, description = Description})
	gridContainer.get_child(ButtonIndex).icon = Icon

func addNewSpirit(Icon,description,attacks:Array):
	var ItemIndex = itemList.item_count
	var attackNames = []
	var skip1 = true
	for i in attacks:
		var moveArray = [i.keys, i.animName]
		spiritMoves.add_child(i)
		i.name = i.animName
		if skip1:
			skip1 = false
			attackNames.append(moveArray)
			InheritKeys(i.animName,i.keys)
			continue
		moveArray.append(description)
		lockedMoves.append(moveArray)
	itemList.add_item(description,Icon)
	itemList.set_item_metadata(ItemIndex,attackNames)

func addNewDashBar():
	var newDashBar:TextureProgressBar = dashBars[1].duplicate()
	newDashBar.value = 0
	newDashBar.position.x += 105
	guis.add_child(newDashBar)
	dashBars.append(newDashBar)
	maxDashes += 1

func _on_health_entity_died() -> void:
	timer.start(1)
	await timer.timeout
	deathScreen.visible = true
	
func addButton():
	var newButton = Button.new()
	gridContainer.add_child(newButton)
	newButton.icon = load("res://Icons/Spirits/UnknownIcon.png")
	newButton.focus_mode = Control.FOCUS_NONE
	newButton.button_down.connect(func():
			swapSpirits(newButton)
			)
