AutoTest_220718_141152 = {
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
                    pos = 305,
                },
            },
            [4] = {
                action = "AddMonster",
                args = {
                    dir = 1,
                    disableai = true,
                    id = 5100111,
                    name = "e2",
                    pos = 505,
                },
            },
            [5] = {
                action = "AddMonster",
                args = {
                    dir = 1,
                    disableai = true,
                    id = 2070421,
                    name = "e3",
                    pos = 706,
                },
            },
            [6] = {
                action = "SetEntityHPPercent",
                args = {
                    name = "e2",
                    percent = 0.20000000298023,
                },
            },
            [7] = {
                action = "CheckSanValue",
                args = {
                    compare = "==",
                    expect = 100,
                    trigger = 0,
                },
            },
            [8] = {
                action = "CheckEntityChangeHP",
                args = {
                    compare = ">",
                    name = "e2",
                    trigger = 88,
                },
            },
            [9] = {
                action = "CheckSanValue",
                args = {
                    compare = "==",
                    expect = 85,
                    trigger = 88,
                },
            },
            [10] = {
                action = "FakeCastSkill",
                args = {
                    name = "p1",
                    pickUpPos = {
                        [1] = 504.0,
                    },
                },
            },
            [11] = {
                action = "WaitGameFsm",
                args = {
                    id = 5,
                },
            },
            [12] = {
                action = "CheckSanValue",
                args = {
                    compare = "==",
                    expect = 55,
                    trigger = 88,
                },
            },
            [13] = {
                action = "FakeCastSkill",
                args = {
                    name = "p1",
                    pickUpPos = {
                        [1] = 304.0,
                    },
                },
            },
            [14] = {
                action = "WaitGameFsm",
                args = {
                    id = 5,
                },
            },
            [15] = {
                action = "CaptureFormulaAttr",
                args = {
                    attr = "damagePercent",
                    damageIndex = 3,
                    defname = "e3",
                    key = "CalcDamage_4",
                    skillid = 2301511,
                    trigger = 102,
                    varname = "v1",
                },
            },
            [16] = {
                action = "CheckLocalValue",
                args = {
                    target = 0.69999998807907,
                    trigger = 88,
                    varname = "v1",
                },
            },
            [17] = {
                action = "FakeInputChain",
                args = {
                    chainPath = {
                        [1] = 502.0,
                        [2] = 503.0,
                        [3] = 504.0,
                        [4] = 505.0,
                        [5] = 506.0,
                    },
                    pieceType = 1,
                },
            },
            [18] = {
                action = "WaitGameFsm",
                args = {
                    id = 5,
                },
            },
            name = "连锁技强化：san值低于（包括等于）60时，额外造成1次伤害（服从减少规则）；低于25时额外2次伤害",
        },
    },
    name = "贾尔斯觉醒3",
    petList = {
        [1] = {
            awakening = 0,
            equiplv = 1,
            grade = 3,
            id = 1601511,
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
