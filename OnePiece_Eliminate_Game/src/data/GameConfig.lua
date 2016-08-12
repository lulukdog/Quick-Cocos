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
		die = {frameBegin = 60,frameEnd = 99},
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
		3000,20000,45000,100000
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
		enemyBeat2 = 5,
	},
	-- 船的类型和名字
	ShipNamePic = {
		[1] = "yangguangmeilihao_word.png",
		[2] = "wanliyangguanghao_word.png",
	},
	ShipPic = {
		[1] = "ship_01_bg.png",
		[2] = "ship_02_bg.png",
	},
	-- 升级船页面的船的图片
	ShipUpgradePic = {
		[1] = "ship_01_item.png",
		[2] = "ship_02_item.png",
	},
	-- 敌人类型对应物块Id伤害的描述
	EnemyTypeDes = {
		[1] = "pic/tips_hongse.png",
		[2] = "pic/tips_lvse.png",
		[3] = "pic/tips_huangse.png",
		[4] = "pic/tips_lanse.png",
	},
	-- 关卡目标说明
	StageGoalDes = {
		[1] = "击败敌人",
		[2] = "收集物品",
	},
	-- 购买帮助角色的顺序
	BuyHelper = {5,3,6}, --山治,奈美,乔巴
	BuyHelperPic = {
		[6] = "qiaoba_role.png",
		[3] = "namei_role.png",
		[5] = "shanzhi_role.png",
	}, --乔巴，奈美，山治
	BuyHelperWordPic = {
		[6] = "lingquqiaoba_word.png",
		[3] = "lingqunamei_word.png",
		[5] = "lingqushanzhi_word.png",
	},
	BuyHelperBgPic = {
		[6] = "buy_qiaoba_bg.png",
		[3] = "buy_namei_bg.png",
		[5] = "buy_shanzhi_bg.png",
	},
	-- 敌人属性图片
	EnemyAttrPic = {
		[1] = "pic/attr_maozi.png",
		[2] = "pic/attr_dao.png",
		[3] = "pic/attr_juzi.png",
		[4] = "pic/attr_dangong.png",
	},
	-- 无限体力文字说明
	BuyInfEnergyLabel = "是否购买无限体力",
	-- 金币不足购买金币
	NotEnoughGold = "金币不足请购买金币",
	-- 体力不足购买体力
	NotEnoughEnergy = "体力不足请购买体力",
	HelperUpgradeCfg = {
		attackDirect = "zish.png",
		attackLink = "scsh.png",
		defDirect = "zify.png",
		defLink = "scfy.png",
	},
	AdvType = {
		energy = 1,
		shanzhiHelper = 2,
		rewardBox = 3,
		winTwiceCoin = 4,
	},
	RMBGoldCfg = {
		[1] = 100,
		[2] = 600,
		[3] = 1200,
		[4] = 3000,
	},
	RMBEnergyCfg = {
		[1] = 600,
		[2] = 1200,
		[4] = 3000,
	},
	BuyGoldCfg = {
		[1] = 3000,
		[6] = 20000,
		[12] = 45000,
		[30] = 100000,
	},
	BuyEnergyCfg = {
		[6] = 10,
		[12] = 20,
		[30] = 999999,
	},
}

return GameConfig