AutoTest_129={
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
				pos = 303,
				},
			},
		[5] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e2",
				pos = 504,
				},
			},
		[6] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				name = "e1",
				trigger = 30,
				},
			},
		[7] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e2",
				trigger = 30,
				},
			},
		[8] = {
			action = "CheckEntityPos",
			args = {
				name = "e1",
				pos = 303,
				trigger = 30,
				},
			},
		[9] = {
			action = "CheckEntityPos",
			args = {
				name = "e2",
				pos = 509,
				trigger = 30,
				},
			},
		[10] = {
			action = "CheckPieceType",
			args = {
				pieceType = 1,
				pos = 303,
				trigger = 30,
				},
			},
		[11] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 501,
				trigger = 30,
				},
			},
		[12] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 503,
				trigger = 30,
				},
			},
		[13] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 504,
				trigger = 30,
				},
			},
		[14] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 505,
				trigger = 30,
				},
			},
		[15] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 506,
				trigger = 30,
				},
			},
		[16] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 507,
				trigger = 30,
				},
			},
		[17] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 508,
				trigger = 30,
				},
			},
		[18] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 509,
				trigger = 30,
				},
			},
		[19] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 202,
				trigger = 30,
				},
			},
		[20] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 302,
				trigger = 30,
				},
			},
		[21] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 402,
				trigger = 30,
				},
			},
		[22] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 602,
				trigger = 30,
				},
			},
		[23] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 702,
				trigger = 30,
				},
			},
		[24] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 802,
				trigger = 30,
				},
			},
		[25] = {
			action = "FakeCastSkill",
			args = {
				name = "p1",
				pickUpPos = {
					[1] = 502.0,
					},
				},
			},
		[26] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "对十字形最大范围造成伤害并击退敌人，同时将攻击范围内的格子转成雷属性",
		},
	},
name = "奈弥西斯主动技",
petList = {
	[1] = {
		affinity = 1,
		awakening = 0,
		equiplv = 1,
		grade = 0,
		id = 1500121,
		level = 1,
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