extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var dir = Vector2.ZERO
var Speed = 5
var GlobalPoints = []
var Ball = false
var selected = false
var lastPos = Vector2.ZERO
export var type = false
var StartPos = Vector2(0,0)
export var Acction = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	$UI/UI/Accion.selected = Acction
	if type:
		$Spritesheet.texture = preload("res://Assets/Spritesheet.png")
		$Spritesheet.flip_h = true
		$Spritesheet/Outline.flip_h = true
	set_physics_process(false)
	Speed = $UI/UI/Speed.value
	$UI/UI/VelocidadLabel.text = str("Velocidad ",Speed)
	set_process(false)

func _process(delta):
	#Dibujado de trayectoria
	$Line2D.points[GlobalPoints.size()] = get_local_mouse_position()
	$Point.position = ($Line2D.points[GlobalPoints.size()-1])
	$Punta.look_at($Point.global_position)
	$Punta.rotation_degrees -= 180
	$Punta.position =get_local_mouse_position()
	if Input.is_action_just_pressed("IzlClick"):
		GlobalPoints.append(get_global_mouse_position())
		$Line2D.add_point(get_local_mouse_position())
	elif Input.is_action_just_pressed("DerClick"):
		GlobalPoints.append(get_global_mouse_position())
		set_process(false)


func _physics_process(delta):
	if Ball:
		$Ball.visible = true
	else:
		$Ball.visible = false
	match $UI/UI/Accion.selected:
		0:
			pass
		1:
			dir.x = 1
			move_and_collide(dir*Speed)
		2:
			dir.x = -1
			move_and_collide(dir*Speed)
		3:
			if (GlobalPoints.size() != 0) and GlobalPoints[0].distance_to(global_position) <5:
				GlobalPoints.remove(0)
			if GlobalPoints.size() != 0:
				dir = GlobalPoints[0] - global_position
				dir = dir.normalized()
				move_and_collide(dir*Speed)
			else:
				get_parent().get_parent().ReduceCount()
				set_physics_process(false)
				
				
func Iniciar():
	StartPos = global_position
	get_parent().get_parent().ActiveCount +=1
	yield(get_tree(),"idle_frame")
	match $UI/UI/Accion.selected:
		0:pass
		1:get_parent().get_parent().ReduceCount()
		2:get_parent().get_parent().ReduceCount()
		3:pass
	$Line2D.clear_points()
	$Punta.visible = false
	set_physics_process(true)
func Reiniciar():
	global_position = StartPos
func Terminar():
	set_physics_process(false)

func _on_PosPlayer_item_selected(index):
	var text = ($UI/UI/PosPlayer.get_item_text(index))
	var lowtext = text.to_lower()
	var abre = ""
	#obtenemos la abreviatura al comparar 
	for i in range(text.length()):
		if !text[i] == lowtext[i]:
			abre = abre+ text[i]
	$Pos.text = abre


func _on_Accion_item_selected(index):
	if index == 3:
		$UI/UI/Dibujar.visible = true
	else:
		$UI/UI/Dibujar.visible = false


func _on_Speed_value_changed(value):
	Speed = value
	$UI/UI/VelocidadLabel.text = str("Velocidad ",Speed)


func _on_Dibujar_pressed():
	$Punta.visible = true
	$Line2D.clear_points()
	$Line2D.add_point(Vector2(0,0))
	$Line2D.add_point(Vector2(0,0))
	GlobalPoints.clear()
	GlobalPoints.append(global_position)
	set_process(true)
	
func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if Input.is_action_just_pressed("IzlClick"):
			get_tree().set_group("UI","visible",false)
			
			yield(get_tree(),"idle_frame")
			$UI/UI.visible = true
			$FollowMouse.start()
			get_parent().get_parent().MovingPlayer = true


func _on_Exit_pressed():
	Global.SelectedPlayer = null
	$UI/UI.visible = false

func _on_FollowMouse_timeout():
	lastPos = global_position
	while Input.is_action_pressed("IzlClick"):
		var pos = get_global_mouse_position()
		global_position = pos
		
		if selected:
			get_parent().get_parent().MoveSelected(global_position - lastPos,self)
		lastPos = global_position
		yield(get_tree(),"idle_frame")
	get_parent().get_parent().MovingPlayer = false
	get_parent().get_parent().Unselect()


func _on_Balon_toggled(button_pressed):
	$Ball.visible = button_pressed
	Ball = button_pressed


func _on_TipoDeLinea_item_selected(index):
	match index:
		1:
			$Line2D.default_color =  Color(1,0,0)
			$Punta.texture = Global.RedPoint
		2:
			$Line2D.default_color = Color(0,0,1)
			$Punta.texture = Global.BluePoint
		0:
			$Line2D.default_color = Color(0,1,0)
			$Punta.texture = Global.GreenPoint


func Guardar():
	var a = []
	a.append($UI/UI/Balon.pressed)
	a.append($UI/UI/Speed.value)
	a.append($UI/UI/Accion.selected)
	a.append($UI/UI/PosPlayer.selected)
	a.append(GlobalPoints)
	a.append($Line2D.points)
	a.append(global_position)
	
	get_parent().get_parent().Jugada[self.name] = a
func Cargar(a):
	$UI/UI/Balon.pressed = a[0][0]
	$UI/UI/Speed.value = a[0][1]
	$UI/UI/Accion.select(a[0][2])
	$UI/UI/PosPlayer.select(a[0][3])
	GlobalPoints = a[0][4]
	$Line2D.points = a[0][5]
	global_position = a[0][6]
