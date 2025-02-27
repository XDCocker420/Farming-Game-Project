extends Node2D
class_name NavigationManager

# Exportiere ein NavigationPolygon, das du im Editor anlegen und zuweisen kannst.
@export var navigation_polygon: NavigationPolygon

# Interne Referenzen zum Navigation-Map und Region.
var navigation_map: RID
var navigation_region: RID

func _ready() -> void:
	# Erstelle eine Navigation Map
	navigation_map = NavigationServer2D.map_create()
	
	# Erstelle eine Navigationsregion
	navigation_region = NavigationServer2D.region_create()
	
	# Weise der Region dein NavigationPolygon zu.
	# Das NavigationPolygon liefert mit get_rid() den internen RID.
	NavigationServer2D.region_set_navigation_polygon(navigation_region, navigation_polygon)
	
	# Füge die Region zur Navigation Map hinzu.
	# Dabei wird die aktuelle globale Transformation verwendet – wichtig, wenn dein Polygon nicht lokal (0,0) liegt.
	NavigationServer2D.map_
	NavigationServer2D.map_add_region(navigation_map, navigation_region, global_transform)
	
	# Optional: Debug-Ausgabe
	print("Navigation Map und Region erstellt.")

# Diese Funktion berechnet einen Pfad von 'start' zu 'end' basierend auf der Navigation Map.
func get_path(start: Vector2, end: Vector2) -> NodePath:
	# false: "optimize" = false, d.h. der rohe Pfad wird zurückgegeben; true könnte den Pfad glätten
	var path = NavigationServer2D.map_get_path(navigation_map, start, end, false)
	return path
