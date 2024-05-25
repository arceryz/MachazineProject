extends Node2D

@onready var pointRect: ReferenceRect = %PointRect
@onready var randomizeButton: Button = %RandomizeButton 
@onready var countLabel: Label = %CountLabel 
@onready var countSlider: Slider = %CountSlider

const pointRadius: float = 3.0

var points: Array[Vector2]

func _ready():
	generatePoints()
	countSlider.value_changed.connect(_onCountSliderChanged)
	randomizeButton.pressed.connect(_onRandomizePressed)

func generatePoints():
	countLabel.text = "%d Points" % countSlider.value
	points.clear()
	for i in range(countSlider.value):
		var point = Vector2(
			randf_range(0, 1),
			randf_range(0, 1)
		)
		points.append(point)
	queue_redraw()

func _draw():
	for p: Vector2 in points:
		var screenPos = Vector2(
			pointRect.position.x + pointRect.size.x * p.x,
			pointRect.position.y + pointRect.size.y * p.y
		)
		draw_circle(screenPos, pointRadius, pointRect.border_color)

func _onCountSliderChanged(_changed: bool):
	generatePoints()

func _onRandomizePressed():
	generatePoints()