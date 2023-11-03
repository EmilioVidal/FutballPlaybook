extends Node

var icon_jugada 
var nom_jugada


var state = 0
var ActiveCount = 0;
var PlayersSelected = []
var MovingPlayer = false

var Dir_SS

var Dir = ""
var Jugadas = {}
var Jugada = {}
#0 editando
#1 corriendo
#2 pausado
var TexturesButton = [
	preload("res://Assets/Botones/Botón de pausa.png"),
	preload("res://Assets/Botones/Botón de play.png"),
	preload("res://Assets/Botones/Botón ver jugada.png"),
	]


# Called when the node enters the scene tree for the first time.
func _ready():
	var current_dir = OS.get_executable_path()
	current_dir = current_dir.get_base_dir()
	print("Directorio actual: ", current_dir)
	Dir = current_dir+"/Saves"
############
	Dir_SS = current_dir+"/FotoJugadasSt"
	var dirScrean = Directory.new()
	if !dirScrean.dir_exists(Dir_SS):
		dirScrean.make_dir_recursive(Dir_SS)
	print("Directorio de las fotos: ",Dir_SS)
########
	yield(get_tree(),"idle_frame")
	print("Liad")
	load_()
	print("Loaded")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if ! $Dibujo.Dibujando:
		if Input.is_action_just_pressed("IzlClick"):
			if !MovingPlayer:
				Unselect()
			UptadePoint(Vector2.ZERO,0)
			UptadePoint(Vector2.ZERO,1)
			UptadePoint(Vector2.ZERO,2)
			UptadePoint(Vector2.ZERO,3)
			UptadePoint($CanchaSteelers.get_global_mouse_position(),0)
		elif Input.is_action_pressed("IzlClick") and !MovingPlayer:
			var mouse = $CanchaSteelers.get_global_mouse_position()
			var Start = $Area2D/Polygon2D.polygon[0]
			UptadePoint(mouse,2)
			UptadePoint(Vector2(mouse.x,Start.y),3)
			UptadePoint(Vector2(Start.x,mouse.y),1)
	
		
func UptadePoint(Pos,i):
	$Area2D/CollisionPolygon2D.polygon[i] = Pos
	$Area2D/Polygon2D.polygon[i] = Pos

func _on_VerJugada_pressed():
	match state:
		0:
			get_tree().call_group("Jugador","Iniciar")
			state = 1
			$VerJugada.texture_normal = TexturesButton[0]
		1:
			get_tree().paused = true
			state = 2
			$VerJugada.texture_normal = TexturesButton[1]
		2:
			get_tree().paused = false
			state = 1
			$VerJugada.texture_normal = TexturesButton[0]

func ReduceCount():
	ActiveCount -= 1
	if ActiveCount <= 0:
		state = 0
		ActiveCount= 0
		get_tree().call_group("Jugador","Terminar")
		$VerJugada.texture_normal = TexturesButton[2]


func Unselect():
	for i in range(PlayersSelected.size()):
		PlayersSelected[i].get_node("Spritesheet").get_node("Outline").visible = false
	PlayersSelected.clear()

func _on_Area2D_body_entered(body):
	if !PlayersSelected.has(body):
		PlayersSelected.append(body)
		body.selected = true
		body.get_node("Spritesheet").get_node("Outline").visible = true

func MoveSelected(pos,caller):
	for i in range(PlayersSelected.size()):
		if PlayersSelected[i] != caller:
			PlayersSelected[i].global_position += pos
	


func _on_Balon_pressed():
	var a = preload("res://Instances/Ball.tscn").instance()
	$YSort.add_child(a)


func _on_Reiniciar_pressed():
	get_tree().call_group("Jugador","Reiniciar")


func _on_Guardar_pressed():
	##para limpiar lo que este en la barra 
	$TextEdit.clear()
	
	$TextEdit.visible = true


func _on_VerJugadas_pressed():
	$Jugadas.visible = !$Jugadas.visible
	

func Guardar(nombre):
	get_tree().call_group("Jugador","Guardar")
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	yield(get_tree(),"idle_frame")
	
	Jugadas[nombre] = Jugada
	
	nom_jugada = nombre

	yield(get_tree(),"idle_frame")
	Jugada = {}
	save_()
	
	
	take_screenshot()
########
	save_and_import_image(Dir_SS+"/"+nom_jugada+".png")
#########
	
		
func save_and_import_image(image_path: String):
	var image_texture: ImageTexture = ImageTexture.new()
	var image = Image.new()
	image.load(image_path)
	image_texture.create_from_image(image)
	var png_path = image_path.split(".")[0] + ".png"
	
	# Guardar la imagen como un archivo PNG utilizando la clase Image
	image.save_png(png_path)

	# Forzar la importación del recurso
	ResourceSaver.save(png_path, image_texture)
	var imported_resource = ResourceLoader.load(png_path)  # Obtener el recurso cargado

	# Ahora puedes usar el recurso recién importado directamente, ya que ya está almacenado en 'image_texture'
	var imported_texture = image_texture
	$Jugadas.add_item(nom_jugada, imported_texture)
	
	
func _on_TextEdit_text_entered(new_text):
	$TextEdit.visible = false
	Guardar(new_text)


func _on_Jugadas_item_selected(index):
	var n = Jugadas.keys()[index]
	var keys = Jugadas[n].keys()
	for i in range(Jugadas[n].size()):
		$YSort.get_node(keys[i]).Cargar([Jugadas[n][keys[i]]])

	$Jugadas.visible = !$Jugadas.visible



func save_():
	print("Guardando")
	var data = Jugadas
	var file = File.new()
	var error = file.open(Dir, File.WRITE_READ)
	if error == OK:
		print("Guardado")
		file.store_var(data)
		file.close()
	else:
		# Si el archivo no existe, intentamos crearlo
		print("Creando Archivo")
		file = File.new()
		error = file.open(Dir, File.WRITE)
		if error == OK:
			print("Guardando")
			file.store_var(data)
			file.close()
		else:
			print("Error al guardar los datos.")

func load_():
	var file = File.new()
	if file.file_exists(Dir):
		print("File exist")
		var error = file.open(Dir, File.READ)
		if error == OK:
			var player_data = file.get_var()
			Jugadas = player_data
			
			file.close()
		else:
			print("Error")
#######
	var n = Jugadas.keys()
	for i in range(Jugadas.size()):
		var image_path = Dir_SS + "/" + n[i] + ".png"
		var icon_jugada = ImageTexture.new()
		
		if File.new().file_exists(image_path):
			var image = Image.new()
			var error = image.load(image_path)
			if error == OK:
				icon_jugada.create_from_image(image)
				$Jugadas.add_item(n[i], icon_jugada)
			else:
				print("Error loading image:", image_path)
		else:
			print("image not found:", image_path)
###########


func _on_Go_back_button_pressed():
	$Jugadas.visible = !$Jugadas.visible


func take_screenshot():
	var vpt: Viewport = get_viewport()
	var text: Texture = vpt.get_texture()
	var img: Image = text.get_data()
	
	var region_rect = Rect2(Vector2(44, 123), Vector2(936, 457))
	var region_img: Image = img.get_rect(region_rect).duplicate()
	
	region_img.flip_y()

	var file_path = Dir_SS + "/" + nom_jugada + ".png"
	region_img.save_png(file_path)
	print(file_path)
