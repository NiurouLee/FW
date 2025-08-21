AutoTest_211213_192950={
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
				pos = 103,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e2",
				pos = 303,
				},
			},
		[5] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e3",
				pos = 208,
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
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				name = "e3",
				trigger = 88,
				},
			},
		[9] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 502.0,
					[2] = 402.0,
					[3] = 302.0,
					[4] = 203.0,
					[5] = 204.0,
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
		name = "1阶段连锁：连线4格，对最近2个单位造成伤害 ",
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
				pos = 603,
				},
			},
		[3] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e5",
				pos = 504,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e6",
				pos = 107,
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
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e5",
				trigger = 88,
				},
			},
		[7] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				name = "e6",
				trigger = 88,
				},
			},
		[8] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 204.0,
					[2] = 205.0,
					[3] = 305.0,
					[4] = 405.0,
					[5] = 505.0,
					[6] = 604.0,
					[7] = 704.0,
					[8] = 705.0,
					[9] = 605.0,
					},
				pieceType = 1,
				},
			},
		[9] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "2阶段连锁：连线8格，对最近2个单位造成伤害",
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
				name = "e7",
				pos = 309,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e8",
				pos = 408,
				},
			},
		[5] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e9",
				pos = 609,
				},
			},
		[6] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e7",
				trigger = 88,
				},
			},
		[7] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e8",
				trigger = 88,
				},
			},
		[8] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				name = "e9",
				trigger = 88,
				},
			},
		[9] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 605.0,
					[2] = 705.0,
					[3] = 805.0,
					[4] = 905.0,
					[5] = 906.0,
					[6] = 806.0,
					[7] = 706.0,
					[8] = 606.0,
					[9] = 506.0,
					[10] = 406.0,
					[11] = 407.0,
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
		name = "3阶段连锁：连线11格，对最近2个单位造成伤害",
		},
	},
name = "弗劳尔连锁技",
petList = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 0,
		id = 1601161,
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