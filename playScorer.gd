extends Node
var animations = []

func animate_score(wordsToScore, scoreLabel, tilesPlayed):
	var score = calculate_score(wordsToScore, tilesPlayed)
	print(animations)
	for event in animations:
		for tile in event[0]:
			tile.pulse_and_rotate(0.5)
		scoreLabel.text = "Score: " + str(event[1])
		await wait(0.5)
	return score
	

func calculate_score(wordsToScore, tilesPlayed):
	var totalScore = 0
	animations = []
	for word in wordsToScore:
		totalScore += score_word(word, totalScore)
	animations.append([[], totalScore])
	totalScore = bingoCheck(tilesPlayed, totalScore)
	return totalScore

func score_word(word, totalScore):
	var score = 0
	var multiplier = 1
	for tile in word:
		var boardTile = tile.get_current_board_tile()
		score += tile.get_value() * boardTile.get_letter_multiplier()
		multiplier *= tile.get_multiplier() * boardTile.get_word_multiplier()
		animations.append([[tile], score + totalScore])
	
	if multiplier > 1:
		animations.append([word, score * multiplier + totalScore])
	
	return score * multiplier
	
func bingoCheck(tilesPlayed, score):
	var bingoLength = 7
	var bingoScore = 50
	if len(tilesPlayed) >= bingoLength:
		score += bingoScore
		animations.append([tilesPlayed, score])
	return score
		

func wait(seconds):
	await get_tree().create_timer(seconds).timeout
