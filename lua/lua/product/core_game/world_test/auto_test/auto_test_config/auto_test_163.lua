AutoTest_163={
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
				pos = 502,
				},
			},
		[3] = {
			action = "SetTeamPowerFull",
			args = {},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e1",
				pos = 305,
				},
			},
		[5] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e2",
				pos = 406,
				},
			},
		[6] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e3",
				pos = 604,
				},
			},
		[7] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e1",
				trigger = 88,
				},
			},
		[8] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e2",
				trigger = 88,
				},
			},
		[9] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e3",
				trigger = 88,
				},
			},
		[10] = {
			action = "FakeCastSkill",
			args = {
				name = "p1",
				pickUpPos = {
					[1] = 502.0,
					},
				},
			},
		[11] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "对全体敌人造成伤害",
		},
	},
name = "多恩主动技",
petList = {
	[1] = {
		affinity = 1,
		awakening = 0,
		equiplv = 1,
		grade = 0,
		id = 1501041,
		level = 10,
		name = "p1",
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