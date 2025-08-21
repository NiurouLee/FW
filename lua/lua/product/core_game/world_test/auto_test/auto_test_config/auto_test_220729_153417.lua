AutoTest_220729_153417 = {
cases = {
	[1] = {
		[1] = {
			action = "SetTeamPosition",
			args = {
				name = "team",
				pos = 502,
				},
			},
		[2] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e1",
				pos = 305,
				},
			},
		[3] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e2",
				pos = 405,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e4",
				pos = 406,
				},
			},
		[5] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = false,
				id = 5100111,
				name = "e5",
				pos = 407,
				},
			},
		[6] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e6",
				pos = 607,
				},
			},
		[7] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e3",
				pos = 709,
				},
			},
		[8] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e1",
				trigger = 88,
				},
			},
		[9] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e2",
				trigger = 88,
				},
			},
		[10] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e4",
				trigger = 88,
				},
			},
		[11] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e5",
				trigger = 88,
				},
			},
		[12] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				name = "e6",
				trigger = 88,
				},
			},
		[13] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				name = "e3",
				trigger = 88,
				},
			},
		[14] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 5,
				layerType = 4001580,
				name = "e1",
				trigger = 88,
				},
			},
		[15] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 5,
				layerType = 4001580,
				name = "e2",
				trigger = 88,
				},
			},
		[16] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 5,
				layerType = 4001580,
				name = "e4",
				trigger = 88,
				},
			},
		[17] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 5,
				layerType = 4001580,
				name = "e5",
				trigger = 88,
				},
			},
		[18] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 0,
				layerType = 4001580,
				name = "e6",
				trigger = 88,
				},
			},
		[19] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 0,
				layerType = 4001580,
				name = "e3",
				trigger = 88,
				},
			},
		[20] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 502.0,
					[2] = 602.0,
					[3] = 702.0,
					[4] = 701.0,
					[5] = 601.0,
					[6] = 501.0,
					[7] = 401.0,
					[8] = 301.0,
					[9] = 302.0,
					[10] = 303.0,
					[11] = 304.0,
					},
				pieceType = 1,
				},
			},
		[21] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "joker连锁技1 对4圈内的4个敌造伤害且叠加5层印记",
		},
	},
name = "joker连锁技2",
petList = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 0,
		id = 1601581,
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