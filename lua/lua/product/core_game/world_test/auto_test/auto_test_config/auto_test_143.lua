AutoTest_143={
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
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e1",
				pos = 705,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e2",
				pos = 706,
				},
			},
		[5] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e3",
				pos = 707,
				},
			},
		[6] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e4",
				pos = 708,
				},
			},
		[7] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 0,
				layerType = 40046,
				name = "e1",
				trigger = 88,
				},
			},
		[8] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 3,
				layerType = 40046,
				name = "e2",
				trigger = 88,
				},
			},
		[9] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 3,
				layerType = 40046,
				name = "e3",
				trigger = 88,
				},
			},
		[10] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 3,
				layerType = 40046,
				name = "e4",
				trigger = 88,
				},
			},
		[11] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 502.0,
					[2] = 501.0,
					[3] = 401.0,
					[4] = 402.0,
					[5] = 302.0,
					[6] = 303.0,
					[7] = 203.0,
					[8] = 204.0,
					[9] = 205.0,
					[10] = 306.0,
					[11] = 406.0,
					[12] = 506.0,
					[13] = 507.0,
					[14] = 508.0,
					},
				pieceType = 1,
				},
			},
		[12] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "3阶段连锁：连线12格，对周围3圈内的3个敌人造成伤害，并附加3层奚笑印记，印记最多叠加8层。",
		},
	},
name = "基汀连锁技3",
petList = {
	[1] = {
		affinity = 1,
		awakening = 0,
		equiplv = 1,
		grade = 0,
		id = 1300461,
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