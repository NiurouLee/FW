AutoTest_195={
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
			action = "AddMonster",
			args = {
				dir = 1,
				disableai = true,
				id = 5100111,
				name = "e1",
				pos = 605,
				},
			},
		[4] = {
			action = "CheckEntityChangeHP",
			args = {
				compare = ">",
				name = "e1",
				trigger = 30,
				},
			},
		[5] = {
			action = "CheckEntityPos",
			args = {
				name = "e1",
				pos = 205,
				trigger = 30,
				},
			},
		[6] = {
			action = "FakeCastSkill",
			args = {
				name = "p1",
				pickUpPos = {
					[1] = 605.0,
					[2] = 205.0,
					},
				},
			},
		[7] = {
			action = "WaitGameFsm",
			args = {
				id = 5,
				},
			},
		name = "新增测试用例1",
		},
	},
name = "库斯库塔主动技先制攻击",
petList = {
	[1] = {
		affinity = 1,
		awakening = 2,
		equiplv = 1,
		grade = 3,
		id = 1500981,
		level = 10,
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