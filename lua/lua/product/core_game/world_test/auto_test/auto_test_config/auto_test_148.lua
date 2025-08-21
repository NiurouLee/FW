AutoTest_148={
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
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e1",
				trigger = 30,
				},
			},
		[7] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				name = "e2",
				trigger = 30,
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
		name = "对周围3圈内的敌人造成伤害",
		},
	},
name = "薇薇安主动技",
petList = {
	[1] = {
		affinity = 1,
		awakening = 0,
		equiplv = 1,
		grade = 0,
		id = 1400441,
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