AutoTest_211212_170408={
cases = {
	[1] = {
		[1] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		[2] = {
			action = "SetTeamPosition",
			args = {
				name = "team",
				pos = 502,
				},
			},
		[3] = {
			action = "SetTeamPowerFull",
			args = {
				name = "team",
				name_select_index = 0,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e1",
				pos = 204,
				},
			},
		[5] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e2",
				pos = 709,
				},
			},
		[6] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e1",
				trigger = 88,
				},
			},
		[7] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e2",
				trigger = 88,
				},
			},
		[8] = {
			action = "FakeCastSkill",
			args = {
				name = "p1",
				pickUpPos = {
					[1] = 502.0,
					},
				},
			},
		[9] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "拜里厄主动技",
		},
	},
name = "拜里厄主动技",
petList = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 0,
		id = 1601111,
		level = 1,
		name = "p1",
		},
	},
remotePet = {},
setup = {
	[1] = {
		args = {
			levelID = 1,
			matchType = 1,
			},
		setup = "LevelBasic",
		},
	},
}