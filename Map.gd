extends Node2D


# Bit mask for tiles
# 
# 1 - tile has connection on top
# 2 - tile has connection on right
# 4 - tile has connection on bottom
# 8 - tile has connection on left side
#
# ┌─┬───┬─┐
# │ │ 1 │ │
# ├─┼───┼─┤
# │8│   │2│
# ├─┼───┼─┤
# │ │ 4 │ │
# └─┴───┴─┘
#
# mask can checked by logical and operator:
# (4 & tile_type) == 4
#
#
# TODO: shuffle game map before draw tilemap and start game
# TODO: UI to change field size / dificulty and start / stop game
# TODO: HUD to change rotation direction
# TODO: win screen, new game functionality and cancel game functionality with solutin showing
# 


var tile = preload("res://scenes/tile.tscn")

const tileMapSize = 11	# max tilemap size
var start_tile = 0 # draw map from this tile

var mapSize = 11			# square game field size, should be less or equal that tileMapSize
var infinity = true	# game field borders are connected to each other

var tileArray = [] # hold tileNodes objects for draw

var mapGame = [] 	# hold tile types for game
var mapOriginal = [] 	# hold initial state of game map

var mapReached = []	# temp array to check tiles for reacheableable

# all tiles should be connected to this start_cell
var start_cell_x = 0 
var start_cell_y = 0

# drawable map size
var width = 0
var height = 0

# to print map in console for debug
var utfmap = { 
	 0: ' ',  1: '╹',  2: '╺',  3: '┗', 
	 4: '╻',  5: '┃',  6: '┏',  7: '┣',
	 8: '╸',  9: '┛', 10: '━', 11: '┻',
	12: '┓', 13: '┫', 14: '┳', 15: '╋'
}

# tile types to start cell
var startVariants = [ 5, 7, 10, 11, 13, 14]

var rand = RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print('randomize')
	rand.randomize()
	if mapSize < tileMapSize:
		infinity = false
	print('init_map')
	init_map()
	fill_map()
	print_map()
	init_tile_map()
	mark_all_reached()


func init_map():
	print('init_map...')
	start_tile = ceil((tileMapSize - mapSize) / 2)
	for y in range(mapSize):
		mapOriginal.append([])
		mapOriginal[y]=[]
		mapGame.append([])
		mapGame[y]=[]
		mapReached.append([])
		mapReached[y]=[]
		for x in range(mapSize):
			mapOriginal[y].append([])
			mapOriginal[y][x]=0
			mapGame[y].append([])
			mapGame[y][x]=0
			mapReached[y].append([])
			mapReached[y][x]=false


func fill_map():
	print('fill_map...')
	start_cell_x = floor(mapSize / 2)
	start_cell_y = floor(mapSize / 2)
	mapGame[start_cell_y][start_cell_x] = startVariants[rand.randi_range(0, startVariants.size()-1)]

	build_map()
	checkReached()
	clear_unreached_tiles()
	save_map()
	shuffle_game_map()


func build_map():
	for step in range(mapSize):
		# process cells on top and bottom
		for x in range(start_cell_x - step, start_cell_x + step):
			if x >= 0 && x < mapSize:
				if start_cell_y - step >= 0:
					mapGame[start_cell_y - step][x] = get_type(x, start_cell_y - step)
				if start_cell_y + step < mapSize:
					mapGame[start_cell_y + step][x] = get_type(x, start_cell_y + step)
		# process cells on left and right side
		for y in range(start_cell_y - step, start_cell_y + step + 1):
			if y >= 0 && y < mapSize:
				if start_cell_x - step >= 0:
					mapGame[y][start_cell_x - step] = get_type(start_cell_x - step, y)
				if start_cell_x + step < mapSize:
					mapGame[y][start_cell_x + step] = get_type(start_cell_x + step, y)
	# set all empty checked fields to zero
	for y in range(mapSize):
		for x in range(mapSize):
			if mapGame[y][x] == -1:
				mapGame[y][x] = 0
	
	
func get_type(x, y):
	if mapGame[y][x] != 0:
		return mapGame[y][x]
	var type = 0
	var variants = []

	# top
	if y > 0:
		if mapGame[y-1][x] > 0 and (4 & mapGame[y-1][x]) == 4:
			type += 1
		elif mapGame[y-1][x] == 0:
			variants.append(1)
	elif infinity:
		if mapGame[mapSize-1][x] > 0 and (4 & mapGame[mapSize-1][x]) == 4:
			type += 1
		elif mapGame[mapSize-1][x] == 0:
			variants.append(1)

	# bottom
	if y < mapSize-1:
		if mapGame[y+1][x] > 0 and (1 & mapGame[y+1][x]) == 1:
			type += 4
		elif mapGame[y+1][x] == 0:
			variants.append(4)
	elif infinity:
		if mapGame[0][x] > 0 and (1 & mapGame[0][x]) == 1:
			type += 4
		elif mapGame[0][x] == 0:
			variants.append(4)
				
	# left
	if x > 0:
		if mapGame[y][x-1] > 0 and (2 & mapGame[y][x-1]) == 2:
			type += 8
		elif mapGame[y][x-1] == 0:
			variants.append(8)
	elif infinity:
		if mapGame[y][mapSize-1] > 0 and (2 & mapGame[y][mapSize-1]) == 2:
			type += 8
		elif (mapGame[y][mapSize-1] == 0):
			variants.append(8)
	
	# right
	if x < mapSize-1:
		if mapGame[y][x+1] > 0 and (8 & mapGame[y][x+1]) == 8:
			type += 2
		elif mapGame[y][x+1] == 0:
			variants.append(2)
	elif infinity:
		if mapGame[y][0] > 0 and (8 & mapGame[y][0]) == 8:
			type += 2
		elif mapGame[y][0] == 0:
			variants.append(2)

	variants.append(0)
	if variants.size() == 1:
		type += variants[0]
	elif variants.size() > 0:
		var variantsCount = rand.randi_range(1, variants.size())
		if variantsCount == variants.size():
			for v in variants:
				if type + v < 15:
					type += v
		else:
			# peek random variants aus array
			while variantsCount > 0:
				if variants.size() == 1:
					var v = variants.pop_front()
					if type + v < 15:
						type += v
				else:
					var itemIndex = rand.randi_range(0, variants.size()-1)
					var v = variants.pop_at(itemIndex)
					if type + v < 15:
						type += v
				variantsCount -= 1
	if type == 0:
		type = -1 # mark empty field as already checked
	return type


func checkReached():
	cleanReachedArray()
	checkTileReached(start_cell_x, start_cell_y)


func cleanReachedArray():
	for y in range(mapSize):
		for x in range(mapSize):
			mapReached[y][x]=false


func checkTileReached(x: int, y: int):
	if mapReached[y][x] == true:
		return
	mapReached[y][x] = true

	# has top connection
	if (1 & mapGame[y][x]) == 1:
		if y > 0:
			if (4 & mapGame[y-1][x]) == 4:
				checkTileReached(x, y-1)
		elif infinity:
			if (4 & mapGame[mapSize-1][x]) == 4:
				checkTileReached(x, mapSize-1)

	# has bottom connection
	if (4 & mapGame[y][x]) == 4:
		if y < mapSize-1:
			if (1 & mapGame[y+1][x]) == 1:
				checkTileReached(x, y+1)
		elif infinity:
			if (1 & mapGame[0][x]) == 1:
				checkTileReached(x, 0)
	
	# has left connection
	if (8 & mapGame[y][x]) == 8:
		if x > 0:
			if (2 & mapGame[y][x-1]) == 2:
				checkTileReached(x-1, y)
		elif infinity:
			if (2 & mapGame[y][mapSize-1]) == 2:
				checkTileReached(mapSize-1, y)

	# has right connection
	if (2 & mapGame[y][x]) == 2:
		if x < mapSize-1:
			if (8 & mapGame[y][x+1]) == 8:
				checkTileReached(x+1, y)
		elif infinity:
			if (8 & mapGame[y][0]) == 8:
				checkTileReached(0, y)


func clear_unreached_tiles():
	# clear unreached tiles from game map
	for y in range(mapSize):
		for x in range(mapSize):
			if not mapReached[y][x]:
				print('clear', x, y, mapGame[y][x])
				mapGame[y][x] = 0


func save_map():
	# save initial map
	for y in range(mapSize):
		for x in range(mapSize):
			mapOriginal[y][x] = mapGame[y][x]


func shuffle_game_map():
	# TODO: shuffle tiles to start game
	pass


func print_map():
	print('print map')
	for y in range(mapSize):
		var line = str(y) + ": "
		for x in range(mapSize):
			line += utfmap[mapGame[y][x]]
		print(line)
		

func init_tile_map():
	print('init tilemap...')
	
	var t0 = tile.instance()

	var tile_width = t0.get_width()
	var tile_height = t0.get_height()
	var tile_scale = t0.scale

	width = tileMapSize * tile_width * tile_scale.x
	height = tileMapSize * tile_height * tile_scale.y
	
	var window_size = get_viewport().size
	
	tile_scale.x = min(window_size.y / height, window_size.x / width)
	tile_scale.y = tile_scale.x
	
	width = tileMapSize * tile_width * tile_scale.x
	height = tileMapSize * tile_height * tile_scale.y
	
	position.x = (window_size.x - self.width) / 2 + (tile_width*tile_scale.x) / 2
	position.y = (window_size.y - self.height) / 2 + (tile_height*tile_scale.y) / 2
	
	var draw_y = 0.0
		
	for y in range(tileMapSize):
		var draw_x = 0.0
		tileArray.append([])
		tileArray[y]=[]
		for x in range(tileMapSize):
			var t = tile.instance()
			t.position = Vector2(draw_x, draw_y)
			t.scale = tile_scale
			t.connect("on_rotated", self, "_on_tile_rotated", [x-start_tile, y-start_tile])
			tileArray[y].append([])
			tileArray[y][x]=t
			draw_x += tile_width * tile_scale.x
			add_child(t)
		draw_y += tile_height * tile_scale.y

	for y in range(mapSize):
		for x in range(mapSize):
			tileArray[start_tile+y][start_tile+x].set_type(mapGame[y][x])


func _on_tile_rotated(type: int, x, y):
	prints('_on_tile_rotated', mapGame[y][x], type, x, y)
	# TODO test all tiles of reached
	mapGame[y][x] = type
	checkReached()
	mark_all_reached()
	
	if is_all_tiles_reached() && is_all_connected():
		won()


func mark_all_reached():
	for y in range(mapSize):
		for x in range(mapSize):
			tileArray[start_tile+y][start_tile+x].set_reached(mapReached[y][x])


func is_all_tiles_reached():
	for y in range(mapSize):
		for x in range(mapSize):
			if not mapReached[y][x] and mapGame[y][x] != 0:
				prints('unreached', x, y, mapGame[y][x])
				return false
	return true


func is_all_connected():
	for y in range(mapSize):
		for x in range(mapSize):
			# on top
			if (1 & mapGame[y][x]) == 1:
				if y > 0:
					if (4 & mapGame[y-1][x]) != 4:
						prints('unconnected', x, y, mapGame[y][x])
						return false
				elif infinity:
					if (4 & mapGame[mapSize-1][x]) != 4:
						prints('unconnected', x, y, mapGame[y][x])
						return false
			# on bottom
			if (4 & mapGame[y][x]) == 4:
				if y < mapSize-1:
					if (1 & mapGame[y+1][x]) != 1:
						prints('unconnected', x, y, mapGame[y][x])
						return false
				elif infinity:
					if (1 & mapGame[0][x]) != 1:
						prints('unconnected', x, y, mapGame[y][x])
						return false
			# on left
			if (8 & mapGame[y][x]) == 8:
				if x > 0:
					if (2 & mapGame[y][x-1]) != 2:
						prints('unconnected', x, y, mapGame[y][x])
						return false
				elif infinity:
					if (2 & mapGame[y][mapSize-1]) != 2:
						prints('unconnected', x, y, mapGame[y][x])
						return false
			# on right
			if (2 & mapGame[y][x]) == 2:
				if x < mapSize-1:
					if (8 & mapGame[y][x+1]) != 8:
						prints('unconnected', x, y, mapGame[y][x])
						return false
				elif infinity:
					if (8 & mapGame[y][0]) != 8:
						prints('unconnected', x, y, mapGame[y][x])
						return false
	return true


func won():
	prints('You won!')
	pass
