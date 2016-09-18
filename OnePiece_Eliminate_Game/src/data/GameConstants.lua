----------------------------------------------------------------------------------
--[[
    FILE:           GameConstants.lua
    DESCRIPTION:    游戏常数
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-08
--]]
----------------------------------------------------------------------------------

game = game or {}

--[[
============版本号，控制更新==============
--]]
game.VERSION = "1.0.0"

--[[
============常量部分==============
--]]
game.CELL_WIDTH        = 106
game.CELL_HEIGHT       = 106
game.GRID_ROWS         = 7
game.GRID_COLS         = 7
game.GRID_WIDTH        = game.CELL_WIDTH * game.GRID_COLS
game.GRID_HEIGHT       = game.CELL_HEIGHT * game.GRID_ROWS
game.DROP_HEIGHT       = game.GRID_HEIGHT + game.CELL_HEIGHT
game.CELL_TYPE_UNKNOWN = 0
game.CAN_LINK_NUM = 6 --cell有的种类
game.BOMB_LINK_NUM = 7 --生成炸弹的长连数
game.BOMBID = 7 -- 炸弹cell的id
game.IRONID = 9 -- 铁块cell的id
game.MAXENERGY = 50 --最大体力值
game.MAXSTAGE = 100 --最大关卡数
game.MAXGUIDESTEP = 20 --最大引导步数16
game.ITEM = {
	GOLD = 1,
	EXP = 2,
	ENERGY = 3,
}
game.MAPHEIGHT = 8400
game.FREEZEROUND = 3 -- 冻结3回合技能

game.TOMOBILE = false -- 运营商的包购买看视频等,直接成功

--[[
============变量部分==============
--]]
game.nowStage = 1 -- 玩家选择的游戏关卡
game.nowShip = 1 -- 玩家当前的船
game.nowShipLevel = 1 -- 玩家船的等级
game.nowShipExp = 0 -- 玩家船的经验
game.helper = {
	1,0,0,0,0,0 -- level
} -- 帮手等级
game.helperOnFight = {} -- 哪个帮手在出战
game.myGold = 0 -- 自己的游戏币数量
game.myEnergy = 50 -- 自己的体力值
game.countTime = 0 -- 恢复满体力剩余时间（秒）
game.count50EnergyTime = 0 -- 购买50体力倒计时
game.energy50Time = 1800 -- 50体力购买恢复时间
game.addOneEnergyTime = 300 -- 体力涨1需要的间隔时间
game.stageStars={} --每关对应的星星数
game.stageMaxScore = {}--每关对应的最高分
game.getScores = 0 -- 当前关卡获得的积分数
game.isShipUpgrade = false -- 是否播放船升级画面
game.guideStep = 1 --当前引导步数
game.firstEnterGame = true --第一次进入游戏直接跳转到关卡不去地图
game.boxLeftTime = 0 --每次开启宝箱的剩余时间
game.boxRewardTime = 6*3600 --开启宝箱的间隔时间
game.usedHalfRebirth = false --是否已使用了看视频回半血
game.skillFreezeRound = 0 -- 使用技能冻结3回合冻结的回合数
game.needPlayAd = false -- 是否播放自己的广告内容
game.boughtOneYuan = false -- 是否已购买1元购

game.MusicOn = true
game.SoundOn = true

game.PLAYERID = ""

-------------------- 不联网的时候缓存的统计数据 -----------------------
game.recordHelperUse = {} -- 统计伙伴使用，如果发送给平台一次后清空全部
game.recordRebirthBuy = {} -- 统计复活购买信息
game.recordResult = {} -- 统计战斗结果，胜利、失败、返回

-------------------- 游戏中数据不保存 --------------------
game.collectNum = 0 -- 收集物数量
game.stageLoseTimes = {} -- 游戏中关卡失败的次数





--game.SPRITE_INDEX_NOT_INITIALIZED = 0xffffffff