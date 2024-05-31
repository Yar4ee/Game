extends CharacterBody2D

#class_name Enemy

enum{
	IDLE,
	ATTACK,
	CHEASE,
	DAMAGE,
	DEATH,
	RECOVER
}
var state = IDLE:
	set(value): # set ратает по такому условию - каждый раз когда state меняеться, будет применяться то что написано ниже
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			CHEASE:
				chease_state()
			DAMAGE:
				damage_state()
			DEATH:
				death_state()
			RECOVER:
				recover_state()

@onready var animPlayer = $AnimationPlayer
@onready var sprite = $AnimatedSprite2D
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player = Vector2.ZERO
var direction = Vector2.ZERO
var damage = 50
var speed = 150
var chease1 = false
var alive = true


func _ready():
	$Detector/CollisionShape2D.disabled = false
	$AttackDirection/AtaackRange/CollisionShape2D.disabled = false
	Signals.connect("player_position_update", Callable(self,"_on_player_position_update"))



func _physics_process(delta):
	if not is_on_floor(): # если в воздухе
		velocity.y += gravity * delta 
	
	#if state == CHEASE:
		#chease_state()
	move_and_slide()


func _on_player_position_update(player_pos):
	#Функция для приема сигнала из глобального кода signals
	player = player_pos # Спомощью этого мы имеем возможность удалить гриб из сцены но он будет знать где находиться игрок


func _on_ataack_range_body_entered(_body):
	state = ATTACK

func idle_state():
	velocity.x = 0
	animPlayer.play("Idle")
	await get_tree().create_timer(1).timeout # создаем таймер для повторной отаки монстра если я стою в хит боксе его удара (1 сек)

	
func attack_state():
	velocity.x = 0
	animPlayer.play("Attack")
	await  animPlayer.animation_finished
	state = RECOVER
	
func chease_state():
	direction = (player - self.position).normalized()
	velocity.x = direction.x * speed
	animPlayer.play("Run")
	if direction.x < 0 :
		sprite.flip_h = true
		$AttackDirection.rotation_degrees = 180
	else:
		sprite.flip_h = false
		$AttackDirection.rotation_degrees = 0 # Нужно чтобы хитбокс удара поворачивался вместе с врагом
	if chease1 == false:
		state = IDLE

func _on_hit_box_area_entered(area):
	Signals.emit_signal("enemy_attack", damage) # по сигналу что игрок вошел в хит бокс гриб передает персонажу урон



func damage_state():
	velocity.x = 0
	animPlayer.play("Damage")
	await animPlayer.animation_finished
	state = IDLE
	
func death_state():
	$Detector/CollisionShape2D.disabled = true
	velocity.x = 0
	Signals.emit_signal("enemy_died", position)
	animPlayer.play("Death")
	await animPlayer.animation_finished
	queue_free()
	
func recover_state():
	velocity.x = 0
	animPlayer.play("Recover")
	await animPlayer.animation_finished
	state = IDLE




func _on_mob_health_no_health():
	state = DEATH
	

func _on_mob_health_damage_received():
	state = IDLE
	state = DAMAGE


func _on_area_2d_body_entered(body):
	if body.name == 'gamer' and alive == true:
		chease1 = true
		state = CHEASE




func _on_area_2d_body_exited(body):
	chease1 = false
	state = IDLE

