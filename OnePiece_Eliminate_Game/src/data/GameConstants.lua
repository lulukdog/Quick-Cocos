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
game.MAXENERGY = 50 --最大体力值
game.MAXSTAGE = 100 --最大关卡数
game.MAXGUIDESTEP = 16 --最大引导步数16
game.ITEM = {
	GOLD = 1,
	EXP = 2,
}
game.MAPHEIGHT = 8400

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
game.myStarNum = 0 -- 玩家拥有的星星总数
game.myGold = 0 -- 自己的游戏币数量
game.myEnergy = 50 -- 自己的体力值
game.countTime = 0 -- 恢复满体力剩余时间（秒）
game.count50EnergyTime = 0 -- 购买50体力倒计时
game.energy50Time = 1800 -- 50体力购买恢复时间
game.addOneEnergyTime = 3600 -- 体力涨1需要的间隔时间
game.stageStars={} --每关对应的星星数
game.stageMaxScore = {}--每关对应的最高分
game.getScores = 0 -- 当前关卡获得的积分数
game.isShipUpgrade = false -- 是否播放船升级画面
game.guideStep = 1 --当前引导步数
game.firstEnterGame = true --第一次进入游戏直接跳转到关卡不去地图

game.MusicOn = true
game.SoundOn = true

game.PLAYERID = "PlayerID1_"

-------------------- 游戏中数据不保存 --------------------
game.collectNum = 0 -- 收集物数量
game.stageLoseTimes = {} -- 游戏中关卡失败的次数





--game.SPRITE_INDEX_NOT_INITIALIZED = 0xffffffff