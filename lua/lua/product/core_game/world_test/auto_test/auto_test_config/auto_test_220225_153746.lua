AutoTest_220225_153746 = {
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
			action = "SetTeamPowerFull",
			args = {
				name = "team",
				name_select_index = 0,
				},
			},
		[4] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 2100212,
				name = "e1",
				pos = 505,
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
			action = "CheckFormulaAttr",
			args = {
				attr = "attackPercentage",
				attr_select_index = 9,
				defname = "e1",
				expect = 0.60000002384186,
				key = "CalcDamage_125",
				key_select_index = 48,
				skillid = 43014111,
				trigger = 102,
				},
			},
		[7] = {
			action = "FakeCastSkill",
			args = {
				name = "p1",
				pickUpPos = {
					[1] = 503.0,
					},
				},
			},
		[8] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "主动技强化：额外触发一次等同于被动强度的当前生命百分比伤害",
		},
	},
name = "露比觉醒3",
petList = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 3,
		id = 1601411,
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