extends ParallaxBackground

var speed = 100

func _process(delta):
	scroll_offset.x -= speed * delta  #делает максимально норм впс на всех устройствах (delta)  
