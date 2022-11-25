extends Node

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
