AutoTest_230104_114237 = {
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
			action = "SetEntityHPPercent",
			args = {
				name = "team",
				percent = 0.5,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e1",
				pos = 507,
				},
			},
		[5] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e1",
				trigger = 88,
				},
			},
		[6] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 502.0,
					[2] = 602.0,
					[3] = 601.0,
					[4] = 501.0,
					[5] = 401.0,
					[6] = 402.0,
					[7] = 403.0,
					[8] = 503.0,
					[9] = 504.0,
					[10] = 505.0,
					[11] = 506.0,
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
		name = "为队伍恢复相当于厘清190%攻击力的血量",
		},
	},
name = "厘青连锁技Ⅱ",
petList = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 0,
		id = 1501831,
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