AutoTest_230104_182304 = {
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
				pos = 508,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e2",
				pos = 407,
				},
			},
		[5] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e3",
				pos = 607,
				},
			},
		[6] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e4",
				pos = 308,
				},
			},
		[7] = {
			action = "SetEntityHPPercent",
			args = {
				name = "e1",
				percent = 0.5,
				},
			},
		[8] = {
			action = "SetEntityHPPercent",
			args = {
				name = "e3",
				percent = 0.5,
				},
			},
		[9] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e1",
				trigger = 88,
				},
			},
		[10] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e2",
				trigger = 88,
				},
			},
		[11] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				name = "e3",
				trigger = 88,
				},
			},
		[12] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e4",
				trigger = 88,
				},
			},
		[13] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 502.0,
					[2] = 402.0,
					[3] = 302.0,
					[4] = 403.0,
					[5] = 504.0,
					[6] = 505.0,
					[7] = 506.0,
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
		name = "6/9/13共3段：跳到菱形内最近且血最高敌人身上跳劈，造成一圈/菱形/米字伤害 每种连锁本轮至多施放1次",
		},
	},
name = "木月白连锁技6",
petList = {
	[1] = {
		awakening = 0,
		equiplv = 0,
		grade = 0,
		id = 1601821,
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