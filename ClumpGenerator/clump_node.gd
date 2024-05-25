class_name ClumpNode

var left: ClumpNode = null
var right: ClumpNode = null
var rect: Rect2 = Rect2(0, 0, 1, 1)
var clump: Clump
var depth: int = 0
var limit: int = 10

func _init(_rect: Rect2, _depth: int, _limit: int):
	rect = _rect
	depth = _depth
	limit = _limit
	clump = Clump.new()

func AddPoint(_dataPoint: DataPoint):
	if clump != null:
		if clump.points.size() < limit:
			clump.points.append(_dataPoint)
			return
		else:
			# Split this node in four!
			# Then afterward we add it to the correct split.
			var x = rect.position.x
			var y = rect.position.y
			var w = rect.size.x
			var h = rect.size.y
			
			var hsplit = rect.size.x > rect.size.y
			if hsplit: # Horizontal splitting
				left = ClumpNode.new(Rect2(x, y, w/2, h), depth+1, limit)
				right = ClumpNode.new(Rect2(x+w/2, y, w/2, h), depth+1, limit)
			else: # Vertical splitting
				left = ClumpNode.new(Rect2(x, y, w, h/2), depth+1, limit)
				right = ClumpNode.new(Rect2(x, y+h/2, w, h/2), depth+1, limit)
			var pts = clump.points
			clump = null
			for dp: DataPoint in pts:
				AddPoint(dp)
			push_error()
	
	# Compute which split this point should go to.
	var mid: Vector2 = rect.get_center()
	var p: Vector2 = _dataPoint.point
	if rect.size.x > rect.size.y: # In case of horizontal splits.
		if p.x <= mid.x: left.AddPoint(_dataPoint)
		else: right.AddPoint(_dataPoint)
	else: # In case of vertical splits.
		if p.y <= mid.y: left.AddPoint(_dataPoint)
		else: right.AddPoint(_dataPoint)
		

func GetLeafs() -> Array[ClumpNode]:
	if (clump != null):
		return [ self ]
	else:
		var arr: Array[ClumpNode] = left.GetLeafs() + right.GetLeafs()
		return arr
