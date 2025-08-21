AutoTest_220808_202629 = {
cases = {
	[1] = {
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
			action = "SetTeamPosition",
			args = {
				name = "team",
				pos = 502,
				},
			},
		[4] = {
			action = "SetOnePieceType",
			args = {
				pieceType = 3,
				pos = 401,
				},
			},
		[5] = {
			action = "SetOnePieceType",
			args = {
				pieceType = 3,
				pos = 603,
				},
			},
		[6] = {
			action = "SetOnePieceType",
			args = {
				pieceType = 3,
				pos = 304,
				},
			},
		[7] = {
			action = "SetOnePieceType",
			args = {
				pieceType = 3,
				pos = 705,
				},
			},
		[8] = {
			action = "SetOnePieceType",
			args = {
				pieceType = 3,
				pos = 506,
				},
			},
		[9] = {
			action = "SetOnePieceType",
			args = {
				pieceType = 3,
				pos = 406,
				},
			},
		[10] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 401,
				trigger = 88,
				},
			},
		[11] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 603,
				trigger = 88,
				},
			},
		[12] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 304,
				trigger = 88,
				},
			},
		[13] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 705,
				trigger = 88,
				},
			},
		[14] = {
			action = "CheckPieceType",
			args = {
				pieceType = 4,
				pos = 506,
				trigger = 88,
				},
			},
		[15] = {
			action = "CheckPieceType",
			args = {
				pieceType = 3,
				pos = 406,
				trigger = 88,
				},
			},
		[16] = {
			action = "FakeCastSkill",
			args = {
				name = "p1",
				pickUpPos = {
					[1] = 502.0,
					},
				},
			},
		[17] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "主动技上回合处于就绪状态，本回合转色数量+1",
		},
	},
name = "琪尔突5",
petList = {
	[1] = {
		affinity = 1,
		awakening = 5,
		equiplv = 1,
		grade = 3,
		id = 1501651,
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