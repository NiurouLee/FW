AutoTest_176={
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
				disableai = true,
				id = 5100111,
				name = "e1",
				pos = 104,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e2",
				pos = 203,
				},
			},
		[5] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e3",
				pos = 204,
				},
			},
		[6] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				invert = 0.0,
				name = "e1",
				trigger = 28,
				},
			},
		[7] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				invert = 0.0,
				name = "e2",
				trigger = 28,
				},
			},
		[8] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				invert = 0.0,
				name = "e3",
				trigger = 28,
				},
			},
		[9] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 502.0,
					[2] = 501.0,
					[3] = 401.0,
					[4] = 301.0,
					[5] = 302.0,
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
		name = "1阶段连锁：连线4格，对最近两个敌人造成伤害",
		},
	[2] = {
		[1] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		[2] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e4",
				pos = 207,
				},
			},
		[3] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e5",
				pos = 208,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e6",
				pos = 308,
				},
			},
		[5] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e7",
				pos = 309,
				},
			},
		[6] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				invert = 0.0,
				name = "e4",
				trigger = 28,
				},
			},
		[7] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				invert = 0.0,
				name = "e5",
				trigger = 28,
				},
			},
		[8] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				invert = 0.0,
				name = "e6",
				trigger = 28,
				},
			},
		[9] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				invert = 0.0,
				name = "e7",
				trigger = 28,
				},
			},
		[10] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 302.0,
					[2] = 303.0,
					[3] = 403.0,
					[4] = 404.0,
					[5] = 304.0,
					[6] = 305.0,
					[7] = 405.0,
					[8] = 306.0,
					[9] = 406.0,
					[10] = 407.0,
					},
				pieceType = 1,
				},
			},
		[11] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "2阶段连锁：连线9格，对最近3个敌人造成伤害",
		},
	[3] = {
		[1] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		[2] = {
			action = "SetPieceType",
			args = {
				pieceType = 1,
				},
			},
		[3] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e8",
				pos = 701,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e9",
				pos = 802,
				},
			},
		[5] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e10",
				pos = 804,
				},
			},
		[6] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e11",
				pos = 903,
				},
			},
		[7] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e12",
				pos = 904,
				},
			},
		[8] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				invert = 0.0,
				name = "e8",
				trigger = 28,
				},
			},
		[9] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				invert = 0.0,
				name = "e9",
				trigger = 28,
				},
			},
		[10] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				invert = 0.0,
				name = "e10",
				trigger = 28,
				},
			},
		[11] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				invert = 0.0,
				name = "e11",
				trigger = 28,
				},
			},
		[12] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				invert = 0.0,
				name = "e12",
				trigger = 28,
				},
			},
		[13] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 407.0,
					[2] = 507.0,
					[3] = 607.0,
					[4] = 606.0,
					[5] = 506.0,
					[6] = 505.0,
					[7] = 605.0,
					[8] = 604.0,
					[9] = 504.0,
					[10] = 404.0,
					[11] = 403.0,
					[12] = 503.0,
					[13] = 603.0,
					[14] = 703.0,
					},
				pieceType = 1,
				},
			},
		[14] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "3阶段连锁：连线13格，对最近4个敌人造成伤害",
		},
	},
name = "希卡蕾连锁技",
petList = {
	[1] = {
		affinity = 1,
		awakening = 0,
		equiplv = 1,
		grade = 0,
		id = 1501001,
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