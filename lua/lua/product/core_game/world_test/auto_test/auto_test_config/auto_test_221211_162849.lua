AutoTest_221211_162849 = {
cases = {
	[1] = {
		[1] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		[2] = {
			action = "SetEntityHPPercent",
			args = {
				name = "team",
				percent = 0.5,
				},
			},
		[3] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = false,
				id = 5100111,
				name = "e4",
				pos = 507,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e6",
				pos = 608,
				},
			},
		[5] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e7",
				pos = 609,
				},
			},
		[6] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e4",
				trigger = 88,
				},
			},
		[7] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e6",
				trigger = 88,
				},
			},
		[8] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e7",
				trigger = 88,
				},
			},
		[9] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 502.0,
					[2] = 402.0,
					[3] = 403.0,
					[4] = 304.0,
					[5] = 305.0,
					[6] = 306.0,
					[7] = 307.0,
					[8] = 407.0,
					[9] = 406.0,
					},
				pieceType = 1,
				},
			},
		[10] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		[11] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "<",
				name = "team",
				trigger = 88,
				},
			},
		[12] = {
			action = "FakeCastSkill",
			args = {
				name = "p1",
				pickUpPos = {
					[1] = 504.0,
					},
				},
			},
		[13] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "主动技强化:光灵血量越低，最终治疗越高，最多提高50%",
		},
	},
name = "贝尔塔觉醒3",
petList = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 3,
		id = 1501761,
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