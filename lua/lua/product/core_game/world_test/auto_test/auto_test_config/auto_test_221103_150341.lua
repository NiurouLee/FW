AutoTest_221103_150341 = {
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
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = false,
				id = 5108313,
				name = "e1",
				pos = 305,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e2",
				pos = 306,
				},
			},
		[5] = {
			action = "CheckUILayerShieldCount",
			args = {
				expect = 3,
				name = "e2",
				trigger = 88,
				},
			},
		[6] = {
			action = "FakeInputDoubleClick",
			args = {},
			},
		[7] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "每回合被附身的怪物获得3层护盾。",
		},
	},
name = "40043簇拥之墙",
petList = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 0,
		id = 1400071,
		level = 1,
		name = "p1",
		},
	},
remotePet = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 0,
		id = 1400071,
		level = 1,
		name = "r1",
		},
	},
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