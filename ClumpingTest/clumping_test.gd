extends Node2D

@onready var pointRect: ReferenceRect = %PointRect
@onready var randomizeButton: Button = %RandomizeButton 
@onready var countLabel: Label = %CountLabel 
@onready var countSlider: Slider = %CountSlider
@onready var groupLabel: Label = %GroupLabel 
@onready var groupSlider: Slider = %GroupSlider
@onready var quantityLabel: Label = %QuantityLabel 
@onready var averageLabel: Label = %AverageLabel


const pointRadius: float = 3.0

var leafs: Array[ClumpNode]
var quadTree: ClumpNode

func _ready():
	GeneratePoints()
	countSlider.value_changed.connect(_OnSliderChanged)
	groupSlider.value_changed.connect(_OnSliderChanged)
	randomizeButton.pressed.connect(_OnRandomizePressed)

func GeneratePoints():
	leafs.clear()

	quadTree = ClumpNode.new(Rect2(0, 0, 1, 1), 0, groupSlider.value)
	for i in range(countSlider.value):
		var dp: DataPoint = DataPoint.new()
		dp.point = Vector2(
			randf_range(0, 1),
			randf_range(0, 1)
		)
		dp.adres = ""
		quadTree.AddPoint(dp)
	leafs = quadTree.GetLeafs()
	queue_redraw()

func _draw():
	if quadTree == null:
		return
	var rootRect: Rect2 = quadTree.rect
	
	var totalPoints = 0
	for cl: ClumpNode in leafs:
		totalPoints += cl.clump.points.size()
		var rect = cl.rect
		var viewRect: Rect2
		
		var relX = (rect.position.x - rootRect.position.x) / rootRect.size.x
		var relY = (rect.position.y - rootRect.position.y) / rootRect.size.y
		viewRect.position.x = pointRect.position.x + pointRect.size.x * relX
		viewRect.position.y = pointRect.position.y + pointRect.size.y * relY
		viewRect.size.x = pointRect.size.x * rect.size.x / rootRect.size.x
		viewRect.size.y = pointRect.size.y * rect.size.y / rootRect.size.y
		
		draw_rect(viewRect, Color.WHITE.darkened(0.6), false, 2.0)
	
	for cl: ClumpNode in leafs:
		for p: DataPoint in cl.clump.points:
			var screenPos = Vector2(
				pointRect.position.x + pointRect.size.x * p.point.x,
				pointRect.position.y + pointRect.size.y * p.point.y
			)
			draw_circle(screenPos, pointRadius, pointRect.border_color)
	
	# Compute metrics.
	countLabel.text = "%d Points" % countSlider.value
	groupLabel.text = "Clump Size %d" % groupSlider.value
	quantityLabel.text = "%d Clumps" % leafs.size()
	averageLabel.text = "Average %.1f per Clump" % (float(totalPoints) / leafs.size())

func _OnSliderChanged(_changed: bool):
	GeneratePoints()

func _OnRandomizePressed():
	GeneratePoints()
