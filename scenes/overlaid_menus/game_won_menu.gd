extends GameWonMenu

var level_state: LevelState

func _ready():
	if level_state.rooms_available == 0:
		%RoomsScoreContainer.hide()
	%RoomsScoreLabel.text = "%d / %d" % [level_state.rooms_drafted, level_state.rooms_available]
	%ArtifactsScoreLabel.text = "%d / %d" % [level_state.artifacts_stolen, level_state.artifacts_available]
	%CultureScoreLabel.text = "%d / %d" % [level_state.culture_scored, level_state.culture_available]
