AutoTest_220207_131857 = {
cases = {
	[1] = {
		[1] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		[2] = {
			action = "SetTeamPowerFull",
			args = {
				name = "team",
				name_select_index = 0,
				},
			},
		[3] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "enemy",
				trigger = 88,
				},
			},
		[4] = {
			action = "FakeCastSkill",
			args = {
				name = "p1",
				pickUpPos = {
					[1] = 505.0,
					},
				},
			},
		[5] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
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
		[8] = {
			action = "SetTeamPowerFull",
			args = {
				name = "enemy",
				name_select_index = 1,
				},
			},
		[9] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "team",
				trigger = 88,
				},
			},
		[10] = {
			action = "BlackFistCastSkill",
			args = {
				name = "r1",
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
		name = "康斯坦丁主动技无法选敌人",
		},
	},
name = "黑拳赛-康斯坦丁主动技",
petList = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 2,
		id = 1500561,
		level = 1,
		name = "p1",
		},
	},
remotePet = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 2,
		id = 1500561,
		level = 1,
		name = "r1",
		},
	},
setup = {
	[1] = {
		args = {
			levelID = 1,
			matchType = 12,
			},
		setup = "LevelBasic",
		},
	},
}