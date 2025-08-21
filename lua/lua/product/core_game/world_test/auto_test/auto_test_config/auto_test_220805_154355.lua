AutoTest_220805_154355 = {
cases = {
	[1] = {
		[1] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e1",
				pos = 604,
				},
			},
		[2] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 101314,
				name = "e2",
				pos = 703,
				},
			},
		[3] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 101314,
				name = "e3",
				pos = 407,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 101314,
				name = "e4",
				pos = 408,
				},
			},
		[5] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 101314,
				name = "e5",
				pos = 504,
				},
			},
		[6] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 101314,
				name = "e6",
				pos = 503,
				},
			},
		[7] = {
			action = "SetTeamPosition",
			args = {
				name = "team",
				pos = 502,
				},
			},
		[8] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 2,
				layerType = 4001580,
				name = "e1",
				trigger = 88,
				},
			},
		[9] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 4,
				layerType = 4001580,
				name = "e5",
				trigger = 88,
				},
			},
		[10] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 4,
				layerType = 4001580,
				name = "e6",
				trigger = 88,
				},
			},
		[11] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 0,
				layerType = 4001580,
				name = "e3",
				trigger = 88,
				},
			},
		[12] = {
			action = "CaptureFormulaAttr",
			args = {
				attr = "damagePercent",
				damageIndex = 1,
				defname = "e1",
				key = "CalcDamage_4",
				skillid = 2001622,
				trigger = 102,
				varname = "v1",
				},
			},
		[13] = {
			action = "CheckLocalValue",
			args = {
				target = 1.6000000238419,
				trigger = 88,
				varname = "v1",
				},
			},
		[14] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e1",
				trigger = 88,
				},
			},
		[15] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				name = "e2",
				trigger = 88,
				},
			},
		[16] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				name = "e3",
				trigger = 88,
				},
			},
		[17] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = "==",
				name = "e4",
				trigger = 88,
				},
			},
		[18] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e5",
				trigger = 88,
				},
			},
		[19] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e6",
				trigger = 88,
				},
			},
		[20] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 502.0,
					[2] = 602.0,
					[3] = 701.0,
					[4] = 601.0,
					[5] = 501.0,
					[6] = 401.0,
					[7] = 301.0,
					[8] = 302.0,
					[9] = 303.0,
					[10] = 403.0,
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
		name = "对周围3圈内的3个敌人造成160%攻击力的伤害，叠加2层印记，对雷属性敌人改为4层",
		},
	},
name = "mona连锁技2",
petList = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 0,
		id = 1501621,
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