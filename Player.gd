extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var index = 0
var Follow = false
var speed = 120*5
export var team = false
export var ball = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if team == true:
		$Icon.texture = preload("res://Assets/SpritesheetBlue.png")
	$Icon/Label.text = name
	$CanvasLayer/UI/Nombre.text = name
	$AnimationPlayer.play("Idle")
	set_process(false)
	$CanvasLayer/UI/Speed.value = speed


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("Iz"):
		$Line2D.add_point(Vector2(0,0))
		index += 1
		Follow = false
		$Timer.start()
	elif Input.is_action_just_released("Iz"):
		$Timer.stop()
		if Follow:
			$Line2D.clear_points()#limpiamos los puntos y añadimos el punto inicial en la nueva posicion
			$Line2D.add_point($Icon.position)
			Follow = false
			set_process(false)
			yield(get_tree(),"idle_frame")
			$Punta.visible = false
			return #esto es para que no corra el codigo de if !Follow, porque si lo corre hace que la flecha sea visible
	elif Input.is_action_pressed("Iz") and Follow:
		$Icon.global_position = get_global_mouse_position()
	if !Follow:
		$Line2D.points[index] = get_local_mouse_position()
		$Punta.visible = true
		$Point.position =$Line2D.points[index-1]
		$Punta.look_at($Point.global_position)
		$Punta.rotation_degrees -=180
		$Punta.global_position = get_global_mouse_position()
		
	if Input.is_action_just_pressed("Der"):
		set_process(false)

func Iniciar():
	var points = $Line2D.points
	if ball:
		$AnimationPlayer.play("Ball")
	else:
		$AnimationPlayer.play("Run")
	for i in range(points.size()):
		var point = points[i]
		var dir = point.x - $Icon.position.x
		if dir <0:
			$Icon.flip_h = true
		else:
			$Icon.flip_h = false
		var distance = $Icon.position.distance_to(point)
		var time = distance/(speed*Global.MulSpeed)
		$Tween.interpolate_property($Icon, "position", $Icon.position, point, time,Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		$Tween.start()
		yield($Tween,"tween_completed")
	$Punta.visible = false
	$Line2D.clear_points()
	$Line2D.add_point($Icon.position)
	if ball:
		$AnimationPlayer.play("IdleBall")
	else:
		$AnimationPlayer.play("Idle")
	index =0

func _physics_process(delta):
	$Icon/Ball.visible = ball

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			yield(get_tree(),"idle_frame")
			$Line2D.default_color = Global.LineColor #asígnamos el color a la liena
			match Global.tipo:
				0:
					$Punta.texture = Global.Bloqueo
				1:
					$Punta.texture = Global.Correr
				2:
					$Punta.texture = Global.Pase
			set_process(true)
		else: #en caso de que el click no fue el boton izquierdo implica que es el derecho
			
			get_tree().set_group("UI","visible",false)
			yield(get_tree(),"idle_frame")
			get_parent().get_parent().changeColor()
			$CanvasLayer/UI/GlobalSpeed.value = Global.MulSpeed
			$CanvasLayer/UI.visible = true
			


func _on_Timer_timeout():
	$Punta.visible = false
	
	Follow = true#activamos follow
	$Line2D.clear_points() #Borramos la linea que se haya generado
	$Line2D.add_point(Vector2(0,0)) #creamos un punto inicial para evitar errores
	index = 0 #reiniciamos el index porqiue al dar click izquierdo se le suma un 1 al index


func _on_Exit_pressed():
	get_tree().set_group("UI","visible",false)
	$CanvasLayer/UI.visible = false




func _on_OptionButton_item_selected(index):
	var text = ($CanvasLayer/UI/OptionButton.get_item_text(index))
	var lowtext = text.to_lower()
	var abre = ""
	#obtenemos la abreviatura al comparar 
	for i in range(text.length()):
		if !text[i] == lowtext[i]:
			abre = abre+ text[i]
	$Icon/Pos.text = abre


func _on_Speed_value_changed(value):
	speed = value


func _on_GlobalSpeed_value_changed(value):
	Global.MulSpeed = value


func _on_Balon_toggled(button_pressed):
	ball = button_pressed
