AutoTest_220804_215922 = {
cases = {
	[1] = {
		[1] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 101311,
				name = "e1",
				pos = 604,
				},
			},
		[2] = {
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 101313,
				name = "e2",
				pos = 605,
				},
			},
		[3] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 4,
				layerType = 4001580,
				name = "e1",
				trigger = 88,
				},
			},
		[4] = {
			action = "CheckEntityBuffLayer",
			args = {
				layer = 8,
				layerType = 4001580,
				name = "e2",
				trigger = 88,
				},
			},
		[5] = {
			action = "CaptureFormulaAttr",
			args = {
				attr = "damagePercent",
				damageIndex = 1,
				defname = "e1",
				key = "CalcDamage_4",
				skillid = 2001613,
				trigger = 102,
				varname = "v1",
				},
			},
		[6] = {
			action = "CheckLocalValue",
			args = {
				target = 1.4500000476837,
				trigger = 88,
				varname = "v1",
				},
			},
		[7] = {
			action = "FakeInputChain",
			args = {
				chainPath = {
					[1] = 502.0,
					[2] = 602.0,
					[3] = 702.0,
					[4] = 802.0,
					[5] = 701.0,
					[6] = 601.0,
					[7] = 501.0,
					[8] = 401.0,
					[9] = 301.0,
					[10] = 302.0,
					[11] = 303.0,
					[12] = 403.0,
					[13] = 503.0,
					[14] = 603.0,
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
		name = "对纵向3列范围造成145%攻击力的伤害，叠加4层印记，对森属性敌人改为8层",
		},
	},
name = "芳泽霞连锁技3",
petList = {
	[1] = {
		awakening = 0,
		equiplv = 1,
		grade = 0,
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