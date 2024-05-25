class_name OSMHelper

extends Node2D

var http_request = HTTPRequest.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(http_request)
	
	var coord = await _OSM_address_to_coordinates("TU Delft X")
	print(coord)

func _OSM_address_to_coordinates(address:String):
	var api_url = "https://nominatim.openstreetmap.org/search.php?q=%s&polygon_geojson=1&format=jsonv2" % (address.uri_encode())
	var error = http_request.request(api_url)
	if error != OK:
		push_error("An error occurred in the HTTP request.")
	
	var response = await http_request.request_completed
	
	var response_code = response[1]
	var headers = response[2]
	var body = response[3]

	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var result = json.get_data()

	if response_code == 200:
		# var coord = {"lon": float(result[0]["lon"]), "lat": float(result[0]["lat"])}
		# print(coord)
		return Vector2(float(result[0]["lon"]), float(result[0]["lat"]))
		
	else:
		return null
