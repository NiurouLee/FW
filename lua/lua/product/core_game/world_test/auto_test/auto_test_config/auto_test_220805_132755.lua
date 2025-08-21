AutoTest_220805_132755 = {
cases = {
	[1] = {
		[1] = {
			action = "SetTeamPosition",
			args = {
				name = "team",
				pos = 502,
				},
			},
		[2] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 101311,
				name = "e1",
				pos = 605,
				},
			},
		[3] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 101313,
				name = "e2",
				pos = 604,
				},
			},
		[4] = {
			action = "CaptureFormulaAttr",
			args = {
				attr = "damagePercent",
				damageIndex = 1,
				defname = "e2",
				key = "CalcDamage_5",
				skillid = 320161,
				trigger = 102,
				varname = "v1",
				},
			},
		[5] = {
			action = "CheckLocalValue",
			args = {
				target = 2.2999999523163,
				trigger = 88,
				varname = "v1",
				},
			},
		[6] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 18,
				layerType = 4001580,
				name = "e2",
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
			action = "FakeCastSkill",
			args = {
				name = "p1",
				pickUpPos = {
					[1] = 603.0,
					},
				},
			},
		[9] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "主动强化：森属性敌人叠18层",
		},
	},
name = "芳泽霞觉醒2",
petList = {
	[1] = {
		awakening = 3,
		equiplv = 1,
		grade = 2,
		id = 1501611,
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