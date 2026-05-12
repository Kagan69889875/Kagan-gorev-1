extends Control

func _ready():
	pass

func show_results():
	if has_node("ScoreLabel"):
		$ScoreLabel.text = "Toplanan Puan: %d / 80" % Global.score
	if has_node("DistanceLabel"):
		$DistanceLabel.text = "Koşulan Mesafe: %d m" % int(Global.distance)
	if has_node("MenuBtn"):
		$MenuBtn.pressed.connect(func():
			get_tree().change_scene_to_file("res://Assets/Scenes/Areas/character_select.tscn")
		)
