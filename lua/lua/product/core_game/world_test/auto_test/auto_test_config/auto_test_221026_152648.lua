AutoTest_221026_152648 = {
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
				pieceType = 2,
				},
			},
		[3] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e1",
				pos = 305,
				},
			},
		[4] = {
			action = "AddBuffToEntity",
			args = {
				buffID = 10670201,
				name = "e1",
				},
			},
		[5] = {
			action = "CheckTrapExist",
			args = {
				exist = true,
				trapIds = {
					[1] = 2005.0,
					},
				trigger = 88,
				},
			exist = true,
			},
		[6] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "team",
				trigger = 88,
				},
			},
		[7] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 502.0,
					[2] = 503.0,
					[3] = 504.0,
					[4] = 404.0,
					},
				pieceType = 2,
				},
			},
		[8] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "怪物回合开始，在自己周围一圈生成地刺（火）",
		},
	},
name = "荆棘环绕火",
petList = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 0,
		id = 1600061,
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