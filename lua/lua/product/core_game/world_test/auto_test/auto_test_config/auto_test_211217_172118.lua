AutoTest_211217_172118 = {
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
				id = 5100111,
				name = "e1",
				pos = 303,
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
				attr = "damagePercent",
				attr_select_index = 8,
				defname = "e1",
				expect = 0.40000000596046,
				key = "CalcDamage_113",
				key_select_index = 35,
				skillid = 4201121,
				trigger = 102,
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
		name = "主动技和连锁技对每只怪首次造成伤害时,额外造成1次XXX%攻击力的真伤,本场只触发1次",
		},
	},
name = "斯莫奇觉醒1（连锁技）",
petList = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 1,
		id = 1601121,
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