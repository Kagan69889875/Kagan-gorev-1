extends Node

var selected_character: String = "Dino"
var score: int = 0
var distance: float = 0.0
var collected_parts: int = 0
const TOTAL_PARTS: int = 16

func reset():
	score = 0
	distance = 0.0
	collected_parts = 0
