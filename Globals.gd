extends Node

const SETTINGS_FILE_NAME = "user://game-data.json"

var level = 0 # 0-5, 5 - infinity 
var map_size_array = [3, 5, 7, 9, 11, 11]

# rotate_direction
# 0 - clockwise, 1 - counter clockwise
var rotate_direction = 1 

# tyle types for rotation
# first element - clockwise
# second element - counter clockwise
const rotation_types = [
		[0, 0],		# 0
		[2, 8],		# 1
		[4, 1],		# 2
		[6, 9],		# 3
		[8, 2],		# 4
		[10, 10],	# 5
		[12, 3],	# 6
		[14, 11],	# 7
		[1, 4],		# 8
		[3, 12],	# 9
		[5, 5],		# 10
		[7, 13],	# 11
		[9, 6],		# 12
		[11, 14],	# 13
		[13, 7],	# 14
		[15, 15]	# 15
]

# tile types for initial random shuffle
const shuffle_types = [
	[0],				# 0
	[2, 4, 8],		# 1
	[1, 4, 8],		# 2
	[6, 9, 12],		# 3
	[1, 2, 8],		# 4
	[10],			# 5
	[3, 9, 12],		# 6
	[11, 13, 14],	# 7
	[1, 2, 4],		# 8
	[3, 6, 12],		# 9
	[5],			# 10
	[7, 13, 14],	# 11
	[3, 6, 9],		# 12
	[7, 11, 14],	# 13
	[7, 11, 13],	# 14
	[15]
]


func save_settings():
	var file = File.new()
	file.open(SETTINGS_FILE_NAME, File.WRITE)
	file.store_string(to_json({
		"level": Globals.level
	}))
	file.close()


func load_settings():
	var file = File.new()
	if file.file_exists(SETTINGS_FILE_NAME):
		file.open(SETTINGS_FILE_NAME, File.READ)
		var data = parse_json(file.get_as_text())
		file.close()
		if typeof(data) == TYPE_DICTIONARY:
			prints(data.level, typeof(data.level), TYPE_REAL, (typeof(data.level) == TYPE_REAL))
			if typeof(data.level) == TYPE_REAL and data.level >= 0 and data.level <= 5:
				Globals.level = data.level
			else:
				printerr("Corrupted data! Bad saved level!")
		else:
			printerr("Corrupted data!")
	else:
		printerr("No saved data!")
