extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var turno = 1
var speed = 300
var has = false
var Player = null
var iniciado = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if turno ==1:
		global_position = get_global_mouse_position()
		if Input.is_action_just_pressed("IzlClick"):
			turno +=1
	elif turno ==2:
		$Final.global_position = get_global_mouse_position()
		$Line2D.points[1] = get_local_mouse_position()
		if Input.is_action_just_pressed("IzlClick"):
			turno +=1
			set_process(false)
			iniciado = true
	else:
		var dir = $Final.position - $Inicio.position 
		dir = dir.normalized()
		$Ball.move_and_slide(dir*speed)


func _on_Inicio_body_entered(body):
	if iniciado:
		if body.Ball == true:
			body.Ball = false
			$Ball.visible = true
			set_process(true)
		


func _on_Final_body_entered(body):
	if iniciado:
	
		if body.name == "Ball":
			has = true
			if Player != null:
				Player.Ball =true
				body.visible = false
		elif body.Ball == false:
			if has == true:
				body.Ball =true
				$Ball.visible = false
			else:
				Player = body


func _on_Final_body_exited(body):
	if iniciado:
	
		if body.name == "Ball":
			has = false
			body.visible = false
		else:
			Player = null
