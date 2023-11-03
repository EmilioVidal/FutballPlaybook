extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var Dibujando = false
var Lineas = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

var LastPos = Vector2(0,0)
func _on_Area2D_input_event(viewport, event, shape_idx):
	
	if Dibujando:
		if Input.is_action_just_pressed("IzlClick"):
			var a = Line2D.new()
			add_child(a)
			a.global_position = $Area2D.get_global_mouse_position()
			LastPos = Vector2(0,0)
			a.add_point(LastPos)
			Lineas.append(a)
			a.begin_cap_mode = Line2D.LINE_CAP_ROUND
			a.end_cap_mode = Line2D.LINE_CAP_ROUND
			a.width = 5
			a.default_color = Color(0,0,0)
		elif Input.is_action_pressed("IzlClick"):
			var size = Lineas.size()-1
			var a = Lineas[size]
			var mouse = a.get_local_mouse_position()
			if mouse.distance_to(a.points[a.points.size()-1]) > 5:
				a.add_point(a.get_local_mouse_position())


func _on_Dibujar_pressed():
	if Dibujando:
		Dibujando = false
		$Dibujar.text = "Dibujar"
	else:
		Dibujando = true
		$Dibujar.text = "Detenerse"


func _on_Deshacer_pressed():
	if Lineas.size() >0:
		var a = Lineas[Lineas.size()-1]
		Lineas.erase(a)
		a.queue_free()


func _on_Limpiar_pressed():
	for i in range(Lineas.size()):
		var a = Lineas[i]
		a.queue_free()
	Lineas.clear()
