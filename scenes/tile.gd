extends Node2D

signal on_rotated(type)
signal on_clicked(type)

var tile0 = preload("res://assets/tile-0.png")
var tile1 = preload("res://assets/unreached/tile-1.png")
var tile2 = preload("res://assets/unreached/tile-2.png")
var tile3 = preload("res://assets/unreached/tile-3.png")
var tile4 = preload("res://assets/unreached/tile-4.png")
var tile5 = preload("res://assets/unreached/tile-5.png")
var tile6 = preload("res://assets/unreached/tile-6.png")
var tile7 = preload("res://assets/unreached/tile-7.png")
var tile8 = preload("res://assets/unreached/tile-8.png")
var tile9 = preload("res://assets/unreached/tile-9.png")
var tile10 = preload("res://assets/unreached/tile-10.png")
var tile11 = preload("res://assets/unreached/tile-11.png")
var tile12 = preload("res://assets/unreached/tile-12.png")
var tile13 = preload("res://assets/unreached/tile-13.png")
var tile14 = preload("res://assets/unreached/tile-14.png")
var tile15 = preload("res://assets/unreached/tile-15.png")

var reached1 = preload("res://assets/reached/tile-1.png")
var reached2 = preload("res://assets/reached/tile-2.png")
var reached3 = preload("res://assets/reached/tile-3.png")
var reached4 = preload("res://assets/reached/tile-4.png")
var reached5 = preload("res://assets/reached/tile-5.png")
var reached6 = preload("res://assets/reached/tile-6.png")
var reached7 = preload("res://assets/reached/tile-7.png")
var reached8 = preload("res://assets/reached/tile-8.png")
var reached9 = preload("res://assets/reached/tile-9.png")
var reached10 = preload("res://assets/reached/tile-10.png")
var reached11 = preload("res://assets/reached/tile-11.png")
var reached12 = preload("res://assets/reached/tile-12.png")
var reached13 = preload("res://assets/reached/tile-13.png")
var reached14 = preload("res://assets/reached/tile-14.png")
var reached15 = preload("res://assets/reached/tile-15.png")

var leaf_bottom = [	preload("res://assets/leaf/bottom-0.png"),
					preload("res://assets/leaf/bottom-1.png"),
					preload("res://assets/leaf/bottom-2.png")]
var leaf_top =    [ preload("res://assets/leaf/top-0.png"),
					preload("res://assets/leaf/top-1.png"),
					preload("res://assets/leaf/top-2.png")]
var leaf_left =   [ preload("res://assets/leaf/left-0.png"),
					preload("res://assets/leaf/left-1.png"),
					preload("res://assets/leaf/left-2.png")]
var leaf_right =  [ preload("res://assets/leaf/right-0.png"), 
					preload("res://assets/leaf/right-1.png"),
					preload("res://assets/leaf/right-2.png")]


var type: int = 0
var reached: bool = false
var can_rotate: bool = false

# tiles array:
# first element - texture unreached
# second element - texture reached
var tileVariants = [] 

var game_over = false

var rand = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rand.randomize()
	tileVariants.append([tile0, tile0])
	tileVariants.append([tile1, reached1])
	tileVariants.append([tile2, reached2])
	tileVariants.append([tile3, reached3])
	tileVariants.append([tile4, reached4])
	tileVariants.append([tile5, reached5])
	tileVariants.append([tile6, reached6])
	tileVariants.append([tile7, reached7])
	tileVariants.append([tile8, reached8])
	tileVariants.append([tile9, reached9])
	tileVariants.append([tile10, reached10])
	tileVariants.append([tile11, reached11])
	tileVariants.append([tile12, reached12])
	tileVariants.append([tile13, reached13])
	tileVariants.append([tile14, reached14])
	tileVariants.append([tile15, reached15])


func set_type(t: int):
	if t == type: 
		return
	type = t
	change_texture()


func set_can_rotate(b: bool):
	self.can_rotate = b
	

func set_reached(_reached: bool):
	self.reached = _reached
	change_texture()


func change_texture():
	if reached:
		$Background/Sprite.texture = tileVariants[type][1]
	else:
		$Background/Sprite.texture = tileVariants[type][0]


func get_width():
	return $Background.texture.get_width()


func get_height():
	return $Background.texture.get_height()


func tile_rotate():
	if ! can_rotate:
		return
	var new_type = Globals.rotation_types[type][Globals.rotate_direction]
	if new_type == type:
		return
	set_type(new_type)
	emit_signal("on_rotated", type)
	

func on_won():
	game_over = true
	can_rotate = false
	var leaf_type = rand.randi() % 3
	match type:
		5, 7:
			$Background/Leaf.texture = leaf_left[leaf_type]
			$Background/Leaf.position.y += get_height() / 2 - rand.randi() % get_height()
			$Background/Leaf.show()
		10, 11:
			$Background/Leaf.texture = leaf_bottom[leaf_type]
			$Background/Leaf.position.x += get_width() / 2 - rand.randi() % get_width()
			$Background/Leaf.show()
		14:
			$Background/Leaf.texture = leaf_top[leaf_type]
			$Background/Leaf.position.x += get_width() / 2 - rand.randi() % get_width()
			$Background/Leaf.show()
		13:
			$Background/Leaf.texture = leaf_right[leaf_type]
			$Background/Leaf.position.y += get_height() / 2 - rand.randi() % get_height()
			$Background/Leaf.show()
	$FlowerAnimationStartTimer.wait_time = rand.randf_range(1, 3)
	$FlowerAnimationStartTimer.start()


func start_flower_animation():
	match type:
		1:
			$Background/FlowerAnimation.show()
			$Background/FlowerAnimation.play("flower1")
		2:
			$Background/FlowerAnimation.show()
			$Background/FlowerAnimation.play("flower2")
		4:
			$Background/FlowerAnimation.show()
			$Background/FlowerAnimation.play("flower4")
		8:
			$Background/FlowerAnimation.show()
			$Background/FlowerAnimation.play("flower8")


func _on_Tile_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if game_over:
				emit_signal("on_clicked")
			else:
				tile_rotate()


func _on_FlowerAnimationStartTimer_timeout() -> void:
	start_flower_animation()
