AutoTest_220225_154447 = {
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
				pos = 204,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e2",
				pos = 304,
				},
			},
		[5] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				name = "e1",
				trigger = 88,
				},
			},
		[6] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e2",
				trigger = 88,
				},
			},
		[7] = {
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
		[8] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "1阶段连锁：连线4格，对菱形12格造成伤害",
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
				name = "e3",
				pos = 105,
				},
			},
		[3] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e4",
				pos = 206,
				},
			},
		[4] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				name = "e3",
				trigger = 88,
				},
			},
		[5] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e4",
				trigger = 88,
				},
			},
		[6] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 302.0,
					[2] = 303.0,
					[3] = 403.0,
					[4] = 404.0,
					[5] = 405.0,
					[6] = 406.0,
					[7] = 506.0,
					[8] = 507.0,
					[9] = 407.0,
					[10] = 408.0,
					},
				pieceType = 1,
				},
			},
		[7] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "2阶段连锁：连线9格，对米字16格造成伤害",
		},
	[3] = {
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
				name = "e5",
				pos = 208,
				},
			},
		[3] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e6",
				pos = 905,
				},
			},
		[4] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				name = "e5",
				trigger = 88,
				},
			},
		[5] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e6",
				trigger = 88,
				},
			},
		[6] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 408.0,
					[2] = 508.0,
					[3] = 608.0,
					[4] = 708.0,
					[5] = 707.0,
					[6] = 607.0,
					[7] = 706.0,
					[8] = 606.0,
					[9] = 605.0,
					[10] = 705.0,
					[11] = 805.0,
					[12] = 804.0,
					[13] = 703.0,
					},
				pieceType = 1,
				},
			},
		[7] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "3阶段连锁：连线12格，对周围两圈造成伤害",
		},
	},
name = "芙罗琳连锁技",
petList = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 0,
		id = 1601401,
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