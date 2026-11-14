extends Node2D

const VELOCIDAD = 380.0
const VELOCIDAD_OBS_CHICA = 240.0
const VELOCIDAD_OBS_GRANDE = 0.0
const FUERZA_SALTO = -840.0
const GRAVEDAD = 1650.0

# Medidas sagradas (Perro siempre en Y = 405, Gato en Y = 435)
const GATO_POS_INICIAL = Vector2(140, 435)
const PERRO_POS_INICIAL = Vector2(1010, 405)
const JAULA_POS_TECHO = Vector2(980, 430)

const GATO_ESCALA = Vector2(5.5, 5.5)
const PERRO_ESCALA = Vector2(6.0, 6.0)
const CRIA_ESCALA = Vector2(4.0, 4.0)
const JAULA_ESCALA = Vector2(4.5, 4.5)

# Medidas sagradas de rocas y cajas
const OBS_IZQ_X = 288.0
const OBS_CENTRO_X = 576.0
const OBS_DER_X = 864.0
const OBS_CHICA_Y = 385.0
const OBS_GRANDE_Y = 345.0
const OBS_CHICA_ESCALA = Vector2(6.0, 6.0)
const OBS_GRANDE_ESCALA = Vector2(6.5, 6.5)
const BASE_CAJA_Y = 452.0

# Medidas fijas de botones y carteles flotantes
const BOTON_INICIO_POS = Vector2(405, 275)
const BOTON_INICIO_ESCALA = Vector2(4.0, 4.0)

const BOTON_INST_POS = Vector2(355, 395)
const BOTON_INST_ESCALA = Vector2(4.0, 4.0)

const BOTON_SALIDA_CARTEL_POS = Vector2(955, 130)
const BOTON_SALIDA_CARTEL_ESCALA = Vector2(5.5, 5.5)
const CARTEL_ESCALA = Vector2(6.0, 6.0)

# Ley: posicion y tamano exacto de gatos final sobre el tejado
const GATOS_FINAL_POS = Vector2(1000, 700)
const GATOS_FINAL_ESCALA = Vector2(5.1, 5.6)

# Ubicacion y tamano del sol (solo Nivel 3)
const SOL_POS = Vector2(576, 120)
const SOL_ESCALA = Vector2(4.0, 4.0)

const PIES_GATO = 65.0
const PIES_PERRO = 95.0
const ANCHO_CUERPO = 32.0

const LIMITE_IZQ = 85.0
const LIMITE_DER = 1065.0

var pantalla_inicio = preload("res://sprites/inicio (1).png")
var pantalla_instrucciones = preload("res://sprites/Instrucciones.png")
var pantalla_perdiste = preload("res://sprites/perdiste.png")
var pantalla_felicidades = preload("res://sprites/felicidades.png")
var fondo_1 = preload("res://sprites/ambiente 1.png")
var fondo_2 = preload("res://sprites/ambiente 2.png")
var fondo_3 = preload("res://sprites/ambiente 3 (1).png")
var tex_caja_base = preload("res://sprites/caja 1.png")

var en_cinematica = true
var nivel_actual = 1
var vida_gato = 70
var vida_perro = 70
var gato_vivo = true
var perro_vivo = true
var cria_liberada = false

var vel_y_gato = 0.0
var vel_y_perro = 0.0
var en_suelo_gato = true
var en_suelo_perro = true

var lista_obstaculos = []
var dirs_obstaculos = [1.0, 1.0, 1.0]
var vels_obstaculos = [VELOCIDAD_OBS_CHICA, VELOCIDAD_OBS_GRANDE, VELOCIDAD_OBS_CHICA]

@onready var fondo = $Sprite2D
@onready var perro = $perro
@onready var gato = $gato
@onready var area_perro = $perro/Area2D
@onready var area_gato = $gato/Area2D
@onready var contador_gato = $Label
@onready var contador_perro = $Label2
@onready var cria = $cria
@onready var jaula = $"cria en carcel"
@onready var area_jaula = $"cria en carcel/Area2D"

@onready var roca_chica_1 = $"roca chica"
@onready var roca_chica_2 = $"roca chica2"
@onready var roca_grande = $"roca grande"
@onready var caja_chica_1 = $"caja chica"
@onready var caja_chica_2 = $"caja chica 2"
@onready var caja_grande = $"caja grande"

@onready var boton_jugar = $boton
@onready var area_boton_jugar = $boton/Area2D
@onready var boton_instrucciones = $instruccions
@onready var area_boton_instrucciones = $instruccions/Area2D
@onready var boton_salida = $salida
@onready var area_boton_salida = $salida/Area2D
@onready var sol = $sol
@onready var gatos_final = $gatos

# Nodos de audio
@onready var sfx_golpes = $goples
@onready var sfx_perro_desaparece = $"perro desaparece"
@onready var sfx_perro_final = $"perro desaparece final"
@onready var sfx_gato_desaparece = $"gato desaparece"
@onready var sfx_salto = $salto
@onready var sfx_recuperar_gato = $"recuperar gato"

@onready var mus_menu = $"menu principal"
@onready var mus_garden = $garden
@onready var mus_house = $house
@onready var mus_roof = $roof

var base_caja_1: Sprite2D
var base_caja_2: Sprite2D
var base_caja_grande: Sprite2D
var cartel_flotante: Sprite2D
var boton_accion: Button

func _ready():
	gato.scale = GATO_ESCALA
	perro.scale = PERRO_ESCALA
	cria.scale = CRIA_ESCALA
	jaula.scale = JAULA_ESCALA
	gato.stop()
	gato.frame = 0
	perro.stop()
	perro.frame = 0
	
	sol.position = SOL_POS
	sol.scale = SOL_ESCALA
	sol.z_as_relative = false
	sol.z_index = 5
	sol.visible = false
	sol.play("default")
	
	gatos_final.visible = false
	configurar_audios()
	crear_cajas_soporte()
	configurar_obstaculos_iniciales()
	configurar_estilo_contador(contador_gato, Vector2(40, 25))
	configurar_estilo_contador(contador_perro, Vector2(820, 25))
	contador_gato.visible = false
	contador_perro.visible = false
	mostrar_pantalla_inicio()

func configurar_audios():
	# Fuerza loop infinito en las canciones de fondo
	for m in [mus_menu, mus_garden, mus_house, mus_roof]:
		if m and m.stream is AudioStreamMP3:
			m.stream.loop = true
			
	# Asegura que los efectos cortos suenen una sola vez
	for e in [sfx_golpes, sfx_perro_desaparece, sfx_perro_final, sfx_gato_desaparece, sfx_salto, sfx_recuperar_gato]:
		if e and e.stream is AudioStreamMP3:
			e.stream.loop = false

func detener_musica_combate():
	mus_garden.stop()
	mus_house.stop()
	mus_roof.stop()
func limpiar_cartel_flotante():
	if cartel_flotante:
		cartel_flotante.queue_free()
		cartel_flotante = null

func mostrar_cartel_con_salida(textura_cartel: Texture2D):
	limpiar_cartel_flotante()
	cartel_flotante = Sprite2D.new()
	cartel_flotante.texture = textura_cartel
	cartel_flotante.position = Vector2(576, 324)
	cartel_flotante.scale = CARTEL_ESCALA
	cartel_flotante.z_as_relative = false
	cartel_flotante.z_index = 25
	add_child(cartel_flotante)
	
	boton_salida.visible = true
	boton_salida.modulate = Color.WHITE
	boton_salida.position = BOTON_SALIDA_CARTEL_POS
	boton_salida.scale = BOTON_SALIDA_CARTEL_ESCALA
	boton_salida.z_as_relative = false
	boton_salida.z_index = 30

func mostrar_pantalla_inicio():
	en_cinematica = true
	actualizar_obstaculos_por_escenario(0)
	limpiar_cartel_flotante()
	if boton_accion:
		boton_accion.queue_free()
		
	detener_musica_combate()
	sfx_recuperar_gato.stop()
	if not mus_menu.playing:
		mus_menu.play()
		
	fondo.texture = pantalla_inicio
	fondo.z_as_relative = false
	fondo.z_index = 0
	
	gato.visible = false
	perro.visible = false
	cria.visible = false
	jaula.visible = false
	sol.visible = false
	gatos_final.visible = false
	boton_salida.visible = false
	contador_gato.visible = false
	contador_perro.visible = false
	
	boton_jugar.visible = true
	boton_jugar.modulate = Color.WHITE
	boton_jugar.position = BOTON_INICIO_POS
	boton_jugar.scale = BOTON_INICIO_ESCALA
	boton_jugar.z_as_relative = false
	boton_jugar.z_index = 30
	boton_jugar.stop()
	boton_jugar.frame = 0
	
	boton_instrucciones.visible = true
	boton_instrucciones.modulate = Color.WHITE
	boton_instrucciones.position = BOTON_INST_POS
	boton_instrucciones.scale = BOTON_INST_ESCALA
	boton_instrucciones.z_as_relative = false
	boton_instrucciones.z_index = 30
	
	if not area_boton_jugar.input_event.is_connected(_al_clicar_boton_jugar):
		area_boton_jugar.input_event.connect(_al_clicar_boton_jugar)
	if not area_boton_instrucciones.input_event.is_connected(_al_clicar_instrucciones):
		area_boton_instrucciones.input_event.connect(_al_clicar_instrucciones)
	if not area_boton_salida.input_event.is_connected(_al_clicar_salida):
		area_boton_salida.input_event.connect(_al_clicar_salida)

func _al_clicar_boton_jugar(_viewport: Node, event: InputEvent, _shape_idx: int):
	if not boton_jugar.visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		boton_jugar.frame = 1
		await get_tree().create_timer(0.2).timeout
		mus_menu.stop()
		boton_jugar.visible = false
		boton_instrucciones.visible = false
		boton_salida.visible = false
		ejecutar_intro()

func _al_clicar_instrucciones(_viewport: Node, event: InputEvent, _shape_idx: int):
	if not boton_instrucciones.visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# No detiene mus_menu para que siga sonando mientras lees instrucciones
		boton_jugar.visible = false
		boton_instrucciones.visible = false
		fondo.texture = pantalla_inicio
		mostrar_cartel_con_salida(pantalla_instrucciones)

func _al_clicar_salida(_viewport: Node, event: InputEvent, _shape_idx: int):
	if not boton_salida.visible:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		mostrar_pantalla_inicio()

func crear_cajas_soporte():
	base_caja_grande = Sprite2D.new()
	base_caja_grande.texture = tex_caja_base
	base_caja_grande.scale = OBS_GRANDE_ESCALA
	add_child(base_caja_grande)

	base_caja_1 = Sprite2D.new()
	base_caja_1.texture = tex_caja_base
	base_caja_1.scale = OBS_CHICA_ESCALA
	add_child(base_caja_1)
	
	base_caja_2 = Sprite2D.new()
	base_caja_2.texture = tex_caja_base
	base_caja_2.scale = OBS_CHICA_ESCALA
	add_child(base_caja_2)
	
	for nodo in [caja_grande, base_caja_grande, caja_chica_1, base_caja_1, caja_chica_2, base_caja_2, gato, perro]:
		nodo.z_as_relative = false
	
	base_caja_grande.z_index = 10
	caja_grande.z_index = 11
	base_caja_1.z_index = 12
	caja_chica_1.z_index = 13
	base_caja_2.z_index = 14
	caja_chica_2.z_index = 15
	gato.z_index = 20
	perro.z_index = 20

func configurar_obstaculos_iniciales():
	roca_chica_1.scale = OBS_CHICA_ESCALA
	roca_chica_2.scale = OBS_CHICA_ESCALA
	roca_grande.scale = OBS_GRANDE_ESCALA
	caja_chica_1.scale = OBS_CHICA_ESCALA
	caja_chica_2.scale = OBS_CHICA_ESCALA
	caja_grande.scale = OBS_GRANDE_ESCALA
	
	roca_chica_1.play("default")
	roca_chica_2.play("default")
	roca_grande.play("default")
	reiniciar_posiciones_obstaculos()
	actualizar_obstaculos_por_escenario(0)

func reiniciar_posiciones_obstaculos():
	roca_chica_1.position = Vector2(OBS_IZQ_X, OBS_CHICA_Y)
	roca_chica_2.position = Vector2(OBS_DER_X, OBS_CHICA_Y)
	roca_grande.position = Vector2(OBS_CENTRO_X, OBS_GRANDE_Y)
	
	caja_chica_1.position = Vector2(OBS_IZQ_X, OBS_CHICA_Y)
	caja_chica_2.position = Vector2(OBS_DER_X, OBS_CHICA_Y)
	caja_grande.position = Vector2(OBS_CENTRO_X, OBS_GRANDE_Y)
	
	base_caja_1.position = Vector2(OBS_IZQ_X, BASE_CAJA_Y)
	base_caja_2.position = Vector2(OBS_DER_X, BASE_CAJA_Y)
	base_caja_grande.position = Vector2(OBS_CENTRO_X, BASE_CAJA_Y)
	dirs_obstaculos = [1.0, 1.0, 1.0]

func actualizar_obstaculos_por_escenario(num: int):
	var ver_rocas = (num == 1)
	var ver_cajas = (num == 2)
	roca_chica_1.visible = ver_rocas
	roca_chica_2.visible = ver_rocas
	roca_grande.visible = ver_rocas
	
	caja_chica_1.visible = ver_cajas
	caja_chica_2.visible = ver_cajas
	caja_grande.visible = ver_cajas
	base_caja_1.visible = ver_cajas
	base_caja_2.visible = ver_cajas
	base_caja_grande.visible = ver_cajas
	
	if ver_rocas:
		lista_obstaculos = [roca_chica_1, roca_grande, roca_chica_2]
	elif ver_cajas:
		lista_obstaculos = [caja_chica_1, caja_grande, caja_chica_2]
	else:
		lista_obstaculos = []

func ejecutar_intro():
	en_cinematica = true
	actualizar_obstaculos_por_escenario(0)
	sol.visible = false
	gatos_final.visible = false
	fondo.texture = fondo_1
	gato.visible = true
	gato.position = Vector2(280, 435)
	cria.visible = true
	cria.position = Vector2(395, 460)
	perro.visible = true
	perro.position = Vector2(1250, 405)
	jaula.visible = false
	
	await get_tree().create_timer(1.2).timeout
	var t1 = create_tween()
	t1.tween_property(perro, "position:x", 450.0, 1.0)
	await t1.finished
	
	var t2 = create_tween().set_parallel(true)
	t2.tween_property(perro, "position:x", 1300.0, 1.0)
	t2.tween_property(cria, "position:x", 1245.0, 1.0)
	await t2.finished
	
	fondo.texture = fondo_2
	gato.visible = false
	perro.position = Vector2(-100, 405)
	cria.position = Vector2(-155, 460)
	var t_paso = create_tween().set_parallel(true)
	t_paso.tween_property(perro, "position:x", 1300.0, 1.3)
	t_paso.tween_property(cria, "position:x", 1245.0, 1.3)
	await t_paso.finished
	
	fondo.texture = fondo_3
	cria.visible = false
	perro.position = Vector2(-150, 405)
	jaula.visible = true
	jaula.position = Vector2(-40, JAULA_POS_TECHO.y)
	var t3 = create_tween().set_parallel(true)
	t3.tween_property(perro, "position:x", PERRO_POS_INICIAL.x, 1.4)
	t3.tween_property(jaula, "position:x", JAULA_POS_TECHO.x, 1.4)
	await t3.finished
	mostrar_boton("CONTINUAR", _al_presionar_continuar)
func mostrar_boton(texto: String, funcion_clic: Callable):
	if boton_accion:
		boton_accion.queue_free()
	boton_accion = Button.new()
	boton_accion.text = texto
	boton_accion.position = Vector2(730, 30)
	boton_accion.size = Vector2(380, 65)
	boton_accion.add_theme_font_size_override("font_size", 28)
	add_child(boton_accion)
	boton_accion.pressed.connect(funcion_clic)

func _al_presionar_continuar():
	iniciar_combate(1, fondo_1)

func _al_presionar_nivel_2():
	await correr_siguiente_escenario()
	iniciar_combate(2, fondo_2)

func _al_presionar_nivel_3():
	await correr_siguiente_escenario()
	iniciar_combate(3, fondo_3)

func correr_siguiente_escenario():
	if boton_accion:
		boton_accion.queue_free()
	en_cinematica = true
	actualizar_obstaculos_por_escenario(0)
	contador_gato.visible = false
	contador_perro.visible = false
	gato.position.y = GATO_POS_INICIAL.y
	var t_correr = create_tween()
	t_correr.tween_property(gato, "position:x", 1300.0, 1.1)
	await t_correr.finished

func iniciar_combate(num_nivel: int, textura_fondo: Texture2D):
	if boton_accion:
		boton_accion.queue_free()
	nivel_actual = num_nivel
	cria_liberada = false
	fondo.texture = textura_fondo
	reiniciar_posiciones_obstaculos()
	actualizar_obstaculos_por_escenario(num_nivel)
	
	detener_musica_combate()
	if num_nivel == 1:
		mus_garden.play()
	elif num_nivel == 2:
		mus_house.play()
	elif num_nivel == 3:
		mus_roof.play()
	
	sol.visible = (num_nivel == 3)
	if num_nivel == 3:
		sol.play("default")
	
	jaula.visible = (num_nivel == 3)
	jaula.position = JAULA_POS_TECHO
	cria.visible = false
	gatos_final.visible = false
	
	gato.visible = true
	gato.modulate = Color.WHITE
	gato.frame = 0
	perro.visible = true
	perro.modulate = Color.WHITE
	perro.frame = 0
	perro.position = PERRO_POS_INICIAL
	
	if num_nivel == 1:
		gato.position = GATO_POS_INICIAL
	else:
		gato.position = Vector2(-100, GATO_POS_INICIAL.y)
		var t_entrar = create_tween()
		t_entrar.tween_property(gato, "position:x", GATO_POS_INICIAL.x, 1.0)
		await t_entrar.finished
	
	vida_gato = 70
	vida_perro = 70
	gato_vivo = true
	perro_vivo = true
	vel_y_gato = 0.0
	vel_y_perro = 0.0
	contador_gato.visible = true
	contador_perro.visible = true
	actualizar_contadores()
	en_cinematica = false

func configurar_estilo_contador(etiqueta: Label, pos: Vector2):
	etiqueta.position = pos
	etiqueta.add_theme_font_size_override("font_size", 36)
	etiqueta.add_theme_color_override("font_color", Color.WHITE)
	etiqueta.add_theme_color_override("font_outline_color", Color.BLACK)
	etiqueta.add_theme_constant_override("outline_size", 8)

func actualizar_contadores():
	contador_gato.text = "GATO: " + str(vida_gato)
	contador_perro.text = "PERRO: " + str(vida_perro)

func _input(event):
	if en_cinematica:
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_S and gato_vivo:
			golpear_gato()
		if event.keycode == KEY_DOWN and perro_vivo:
			golpear_perro()

func golpear_gato():
	gato.frame = 1
	if perro_vivo and area_gato.overlaps_area(area_perro):
		sfx_golpes.play()
		vida_perro -= 1
		actualizar_contadores()
		perro.modulate = Color.RED
		if vida_perro <= 0:
			perro_vivo = false
			perro.visible = false
			perro.modulate = Color.WHITE
			detener_musica_combate()
			if nivel_actual == 1:
				sfx_perro_desaparece.play()
				en_cinematica = true
				mostrar_boton("CONTINUE NEXT LEVEL", _al_presionar_nivel_2)
			elif nivel_actual == 2:
				sfx_perro_desaparece.play()
				en_cinematica = true
				mostrar_boton("CONTINUE NEXT LEVEL", _al_presionar_nivel_3)
			elif nivel_actual == 3:
				sfx_perro_final.play()
	await get_tree().create_timer(0.2).timeout
	gato.frame = 0
	if perro_vivo:
		perro.modulate = Color.WHITE

func golpear_perro():
	perro.frame = 1
	if gato_vivo and area_perro.overlaps_area(area_gato):
		sfx_golpes.play()
		vida_gato -= 1
		actualizar_contadores()
		gato.modulate = Color.RED
		if vida_gato <= 0:
			gato_vivo = false
			gato.visible = false
			gato.modulate = Color.WHITE
			detener_musica_combate()
			sfx_gato_desaparece.play()
			mostrar_derrota()
	await get_tree().create_timer(0.2).timeout
	perro.frame = 0
	if gato_vivo:
		gato.modulate = Color.WHITE

func mostrar_derrota():
	en_cinematica = true
	if boton_accion:
		boton_accion.queue_free()
	contador_gato.visible = false
	contador_perro.visible = false
	mostrar_cartel_con_salida(pantalla_perdiste)

func obtener_rectangulo_obs(obs: Node2D) -> Rect2:
	var col = obs.get_node("Area2D/CollisionShape2D") as CollisionShape2D
	var rect_shape = col.shape as RectangleShape2D
	var tamano_real = rect_shape.size * obs.scale
	var centro_real = obs.position + (col.position * obs.scale)
	return Rect2(centro_real - (tamano_real / 2.0), tamano_real)

func _physics_process(delta):
	if en_cinematica:
		return
		
	if nivel_actual == 1:
		if not roca_chica_1.is_playing(): roca_chica_1.play("default")
		if not roca_chica_2.is_playing(): roca_chica_2.play("default")
		if not roca_grande.is_playing(): roca_grande.play("default")
	elif nivel_actual == 3:
		if not sol.is_playing(): sol.play("default")
		
	var desplazamientos_obs = []
	for i in range(lista_obstaculos.size()):
		var obs = lista_obstaculos[i]
		var r = obtener_rectangulo_obs(obs)
		var mitad_ancho = r.size.x / 2.0
		var dx = dirs_obstaculos[i] * vels_obstaculos[i] * delta
		
		if obs.position.x + dx + mitad_ancho >= LIMITE_DER:
			dirs_obstaculos[i] = -1.0
			dx = 0.0
		elif obs.position.x + dx - mitad_ancho <= LIMITE_IZQ:
			dirs_obstaculos[i] = 1.0
			dx = 0.0
			
		obs.position.x += dx
		desplazamientos_obs.append(dx)
		
	if nivel_actual == 2:
		base_caja_1.position.x = caja_chica_1.position.x
		base_caja_2.position.x = caja_chica_2.position.x
		base_caja_grande.position.x = caja_grande.position.x

	if gato_vivo:
		var res_g = mover_personaje_solido(gato, vel_y_gato, en_suelo_gato, GATO_POS_INICIAL.y, PIES_GATO, KEY_A, KEY_D, KEY_W, delta, desplazamientos_obs)
		vel_y_gato = res_g.front()
		en_suelo_gato = res_g.back()
		if nivel_actual == 3 and not perro_vivo and not cria_liberada:
			if area_gato.overlaps_area(area_jaula):
				liberar_cria()

	if perro_vivo:
		var res_p = mover_personaje_solido(perro, vel_y_perro, en_suelo_perro, PERRO_POS_INICIAL.y, PIES_PERRO, KEY_LEFT, KEY_RIGHT, KEY_UP, delta, desplazamientos_obs)
		vel_y_perro = res_p.front()
		en_suelo_perro = res_p.back()

func mover_personaje_solido(pj: Node2D, vel_y: float, en_suelo: bool, suelo_base: float, altura_pies: float, tecla_izq: Key, tecla_der: Key, tecla_salto: Key, delta: float, movs_obs: Array) -> Array:
	var dir = 0.0
	if Input.is_key_pressed(tecla_izq): dir -= 1.0
	if Input.is_key_pressed(tecla_der): dir += 1.0
	
	var nueva_x = clamp(pj.position.x + dir * VELOCIDAD * delta, LIMITE_IZQ, LIMITE_DER)
	var pies_y = pj.position.y + altura_pies
	
	for i in range(lista_obstaculos.size()):
		var r = obtener_rectangulo_obs(lista_obstaculos[i])
		if pies_y > r.position.y + 8.0:
			if nueva_x + ANCHO_CUERPO > r.position.x and pj.position.x <= r.position.x:
				nueva_x = r.position.x - ANCHO_CUERPO
			elif nueva_x - ANCHO_CUERPO < r.end.x and pj.position.x >= r.end.x:
				nueva_x = r.end.x + ANCHO_CUERPO
				
	pj.position.x = clamp(nueva_x, LIMITE_IZQ, LIMITE_DER)
	
	if Input.is_key_pressed(tecla_salto) and en_suelo:
		vel_y = FUERZA_SALTO
		en_suelo = false
		sfx_salto.play()
		
	var pies_y_ant = pj.position.y + altura_pies
	vel_y += GRAVEDAD * delta
	pj.position.y += vel_y * delta
	var pies_y_act = pj.position.y + altura_pies
	
	var piso_destino = suelo_base
	var obs_pisado = -1
	
	if vel_y >= 0.0:
		for i in range(lista_obstaculos.size()):
			var r = obtener_rectangulo_obs(lista_obstaculos[i])
			if pj.position.x + ANCHO_CUERPO * 0.6 > r.position.x and pj.position.x - ANCHO_CUERPO * 0.6 < r.end.x:
				if pies_y_ant <= r.position.y + 12.0 and pies_y_act >= r.position.y:
					if r.position.y - altura_pies < piso_destino:
						piso_destino = r.position.y - altura_pies
						obs_pisado = i
						
	if vel_y >= 0.0 and pj.position.y >= piso_destino:
		pj.position.y = piso_destino
		vel_y = 0.0
		en_suelo = true
		if obs_pisado != -1:
			pj.position.x = clamp(pj.position.x + movs_obs[obs_pisado], LIMITE_IZQ, LIMITE_DER)
	else:
		en_suelo = false
		
	return [vel_y, en_suelo]

func liberar_cria():
	cria_liberada = true
	jaula.visible = false
	cria.visible = true
	cria.modulate = Color.WHITE
	cria.z_index = 10
	cria.scale = CRIA_ESCALA
	cria.position = Vector2(JAULA_POS_TECHO.x, 460)
	
	await get_tree().create_timer(1.0).timeout
	en_cinematica = true
	gato.visible = false
	cria.visible = false
	sol.visible = false
	contador_gato.visible = false
	contador_perro.visible = false
	
	fondo.texture = fondo_3
	mostrar_cartel_con_salida(pantalla_felicidades)
	
	gatos_final.visible = true
	gatos_final.position = GATOS_FINAL_POS
	gatos_final.scale = GATOS_FINAL_ESCALA
	gatos_final.z_as_relative = false
	gatos_final.z_index = 26
	
	sfx_recuperar_gato.play()
