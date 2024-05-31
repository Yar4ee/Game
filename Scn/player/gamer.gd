extends CharacterBody2D
# использю метод state_machine  использую множество состояний и написанные для них функции для того чтобы не придумывать способы обхода конфликтов if else
enum { # Структурирую код для быстроты его выполнения и для удобства
	MOVE, # Для каждолго из этих состоянеий буду писать функции чтобы далее их просто вызывать
	SLIDE,
	ATTACK1,
	ATTACK2,
	ATTACK3,
	DAMAGE,
	JUMP,
	DASH,
	DEATH
}

const SPEED = 150.0 # Скорость ходьбы
const JUMP_VELOCITY = -400.0 # сила прыжка ( с минусом потому что в годот то что вверх то минус)

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") # Стандартная гравитация вшитая в годот 

@onready var anim = $AnimatedSprite2D  #Знак $ вместо функции get_node
@onready var animPlayer = $AnimationPlayer # Те же анимации, но работает правильно и не костыли
@onready var stats = $Stats

var gold = 0
var state = MOVE # Переменная показывающая текущее состояние игрока кроме IDLE так как это состояние по умолчанию
var run_speed = 1.5
var combo = false
var attack_cooldown = false #делаю для того чтобы нельзя было спамить атакой
# Три переменных для механики деша 
var dashDirection = Vector2(1,0)
var canDash = false
var dashing = false
var player_pos
var player_alive = true
var damage_basic = 10
var damage_multiplier = 1
var damage_current 

func _ready():
	Signals.connect("enemy_attack", Callable(self, "_on_damage_received")) #Callable(self, "_on_damage_received") - означает что вызывает функцию на себя с получание урона
	
	
func _physics_process(delta):
	match state: #Работатет как swith case  только для состояний игрока
		MOVE:
			move_state()
		ATTACK1:
			attack1_state()
		ATTACK2:
			attack2_state()
		ATTACK3:
			attack3_state()
		JUMP:
			jump_state()
		DASH:
			dash_state()
		DAMAGE:
			damage_state()
		DEATH:
			death_state()
	
	
	# Add the gravity.
	if not is_on_floor(): # если в воздухе
		velocity.y += gravity * delta # то на персонажа дествует гравитация
	if velocity.y > 0:
		animPlayer.play("Fall")	
		
	damage_current = damage_basic * damage_multiplier
		
	move_and_slide()
	
	player_pos = self.position
	Signals.emit_signal("player_position_update", player_pos) #Сигнал который находиться в глобальном скрипте для того чтобы видеть поожение игрока
#Рабоатет так что мы пишем сигнал и данные которые хотип отправить.

func move_state():
	var direction = Input.get_axis("left", "right") # Прописываем изменение положения -1 при нажатии влево и +1 при нажатии вправо или 0 (этому равно diraction)
	if direction:
		velocity.x = direction * SPEED * run_speed # если вправо то 1 убноженное на скорость то есть 300 (действует сила движения со скоростью 300)
		
		if velocity.y == 0:
			if run_speed == 1:
				animPlayer.play("Run")
			else: 
				animPlayer.play("Run")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			animPlayer.play("Idle")
	#Блок для реализации деша
	if is_on_floor() :
		canDash = true
	if Input.is_action_pressed("left"):
		dashDirection = Vector2(-1,0)
	if Input.is_action_pressed("right"):
		dashDirection = Vector2(1,0)
	if Input.is_action_just_pressed("Dash"):
		state = DASH
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		state = JUMP
	if direction == -1:
		$AnimatedSprite2D.flip_h = true
		$AttackDirection.rotation_degrees = 180
	elif direction == 1:	
		$AnimatedSprite2D.flip_h = false
		$AttackDirection.rotation_degrees = 0
	if Input.is_action_just_pressed("attack") and attack_cooldown == false:
		state = ATTACK1


func dash_state():
	velocity = dashDirection.normalized() * 500
	animPlayer.play("Dash")
	canDash = false
	dashing = true
	await get_tree().create_timer(0.2).timeout
	dashing = false
	state = MOVE
	

func jump_state():
	velocity.y = JUMP_VELOCITY
	animPlayer.play("Jump")
	state = MOVE



func attack1_state():
	damage_multiplier = 1
	if Input.is_action_just_pressed("attack") :
		state = ATTACK2
	velocity.x = 0
	animPlayer.play("Attack1")
	await animPlayer.animation_finished
	state = MOVE

func attack2_state() :
	damage_multiplier = 2
	if Input.is_action_just_pressed("attack") :
		state = ATTACK3
	animPlayer.play("Attack2")
	await animPlayer.animation_finished
	state = MOVE
	
	
func attack3_state() :
	animPlayer.play("Attack3")
	await animPlayer.animation_finished
	attack_freeze() # После третьего удара нельзя дальше спамить ударом, нужно подождать
	state = MOVE

func attack_freeze():
	attack_cooldown = true
	await get_tree().create_timer(0.3).timeout #Создает таймер который отсчитывает 0.3 секунды, дает сигнал и самоуничтожается
	attack_cooldown = false
	
	
func damage_state():
	var direction = Input.get_axis("left", "right")
	if direction == 1:
		anim.play("Damage")
		await anim.animation_finished
		state = MOVE
	else: 
		state = MOVE
	
func _on_damage_received (enemy_damage):
	if state == DASH:
		enemy_damage = 0
	else: 
		state = DAMAGE
	stats.health -= enemy_damage
	if stats.health <= 0 :
		stats.health = 0 
		player_alive = false
		if player_alive == false:
			state = DEATH
	
	


func death_state():
	player_alive = false
	velocity.x = 0
	anim.play("Death1")
	#await anim.animation_finished # Почему-то ошибка
	queue_free()
	get_tree().change_scene_to_file("res://Scn/Menu/menu.tscn")
	#death_animation_finished()
	
	
	
	
#func death_animation_finished():
	#if player_alive == false:
		

	
	
	
	


func _on_hit_box_area_entered(area):
	Signals.emit_signal("player_attack", damage_current)
