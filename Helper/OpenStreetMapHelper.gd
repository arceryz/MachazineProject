class_name OSMHelper

extends Node2D

var http_request = HTTPRequest.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(http_request)
	
	#var coord = await _OSM_address_to_coordinates("TU Delft X")
	# print(coord)
	
	var res = await _OSM_multiple_way_points_route(["TU Delft library", "TU Delft X", "Delft City Hall"], "car")
	print(res)

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
		#var coord = {"lon": float(result[0]["lon"]), "lat": float(result[0]["lat"])}
		#print(coord)
		#print(result)
		return Vector2(float(result[0]["lon"]), float(result[0]["lat"]))
		
	else:
		print(response)
		return null

func _OSM_multiple_way_points_route(addresses:Array, mode:String):
	var coords = []
	var allowed_modes = ["car", "foot", "bike"]
	
	if mode not in allowed_modes:
		push_error("mode should be car, foot, or bike")
	
	for address in addresses:
		var coord = await _OSM_address_to_coordinates(address)
		coords.append(coord)
	
	var coords_str = ""
	for coord in coords:
		coords_str += "{lon},{lat};".format({"lon": coord.x, "lat": coord.y})
		
	coords_str = coords_str.erase(len(coords_str)-1, 1)
	print(coords_str)
	
	var api_url = "https://routing.openstreetmap.de/routed-{mode}/trip/v1/driving/{coords}?source=first&destination=last".format({"mode": mode, "coords": coords_str})
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
		return(result)
		
	else:
		print(response)
		return null
