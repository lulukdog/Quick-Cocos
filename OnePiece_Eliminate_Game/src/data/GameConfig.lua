----------------------------------------------------------------------------------
--[[
    FILE:           GameConfig.lua
    DESCRIPTION:    游戏常量数据
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-07
--]]
----------------------------------------------------------------------------------
local GameConfig = {
	MainRole = {
		stand = {frameBegin = 0,frameEnd = 59},
		shield = {frameBegin = 91,frameEnd = 149},
		shield2 = {frameBegin = 820,frameEnd = 909},
		shieldBroken = {frameBegin = 910,frameEnd = 969},
		shieldBroken2 = {frameBegin = 970,frameEnd = 1029},
		beat = {frameBegin = 160,frameEnd = 220},
		attack = {frameBegin = 221,frameEnd = 293},
		attack2 = {frameBegin = 294,frameEnd = 389},
		meat = {frameBegin = 390,frameEnd = 457},
		die = {frameBegin = 0,frameEnd = 1},
		cell_ani1 = {frameBegin = 460,frameEnd = 519},
		cell_ani2 = {frameBegin = 520,frameEnd = 579},
		cell_ani3 = {frameBegin = 580,frameEnd = 639},
		cell_ani4 = {frameBegin = 640,frameEnd = 699},
		cell_ani5 = {frameBegin = 760,frameEnd = 819},
		cell_ani6 = {frameBegin = 700,frameEnd = 759},
		
		pos = cc.p(175,934), -- 主角屏幕位置,物块飞向主角位置

	},
	Enemy = {
		stand = {frameBegin = 0,frameEnd = 59},
		beat = {frameBegin = 221,frameEnd = 293},
		beat2 = {frameBegin = 294,frameEnd = 390},
		attack = {frameBegin = 160,frameEnd = 220},
		die = {frameBegin = 60,frameEnd = 100},
	},
	Attack2AniEnd = {
		luffie = 80,
		zoro = 190,
	},
	FlyDelayTime = 0, --控制每个物块飞向人物的间隔时间
	FlyDelayInterval = 0.06, -- 物块飞到人物上的延迟时间

	Color = {
		Red = cc.c3b(255, 0, 0),
	},
	GoldTb = {
		10,20,50,100,500
	},
	EnergyTb = {
		10,20,50,999999
	},
	WinAniFrame = {
		star1 = {firstEnd = 149,frameBegin = 171,frameEnd = 200},
		star2 = {firstEnd = 159,frameBegin = 202,frameEnd = 230},
		star3 = {firstEnd = 169,frameBegin = 232,frameEnd = 262},
	},
	HasHelperPic = {
		[2] = "suolong_choose.png",
		[3] = "namei_choose.png",
		[4] = "wusuopu_choose.png",
		[5] = "shanzhi_choose.png",
		[6] = "qiaoba_choose.png",
	},
	HelperPic = {
		normal = "helper_normal.png",
		selected = "helper_selected.png",
		notAble = "helper_not_enable.png",
	},
	-- 打击弹出数字标识
	LinkNum = {
		enemyBeat = 1,
		roleBeat = 2,
		roleMeat = 3,
		enemyLose = 4,
	},
	-- 船的类型和名字
	ShipNameCfg = {
		[1] = "黄金梅丽号",
		[2] = "万里阳光号",
	},
	-- 敌人类型对应物块Id伤害的描述
	EnemyTypeDes = {
		[1] = "受到红色方块伤害减半\n受到蓝色方块伤害加倍",
		[2] = "受到绿色方块伤害减半\n受到红色方块伤害加倍",
		[3] = "受到黄色方块伤害减半\n受到绿色方块伤害加倍",
		[4] = "受到蓝色方块伤害减半\n受到黄色方块伤害加倍",
	},
	-- 关卡目标说明
	StageGoalDes = {
		[1] = "击败敌人",
		[2] = "收集物品",
	},
	-- 购买帮助角色的顺序
	BuyHelper = {6,3,5}
}

return GameConfig