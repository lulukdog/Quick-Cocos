----------------------------------------------------------------------------------
--[[
    FILE:           HelperUpgradeView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-07-28 
--]]
----------------------------------------------------------------------------------
local scheduler = require("framework.scheduler")
local skillCfg = require("data.data_skill")
local GameConfig = require("data.GameConfig")

local HelperUpgradeView = class("HelperUpgradeView", function()
    return display.newNode()
end)

function HelperUpgradeView:ctor(roleNum)

	self._mainNode = CsbContainer:createPushCsb("HelperUpgradeView.csb"):addTo(self)
    local _ani = cc.CSLoader:createTimeline("HelperUpgradeView.csb")
    self._mainNode:runAction(_ani)    
    _ani:gotoFrameAndPlay(0,115,false)
    local _schedule =  scheduler.performWithDelayGlobal(function()
        _ani:gotoFrameAndPlay(100,115,true)
    end,115/GAME_FRAME_RATE)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
	CsbContainer:decorateBtnNoTrans(closeBtn,function()
        scheduler.unscheduleGlobal(_schedule)
		self:removeFromParent()
		self._mainNode = nil
	end)

    local level = game.helper[roleNum]
    CsbContainer:setStringForLabel(self._mainNode, {
        mDirectLabel = skillCfg[level]["skill"..roleNum],
        mLinkLabel = skillCfg[level]["attr"..roleNum],
    })
    local _directPic = GameConfig.HelperUpgradeCfg.attackDirect
    local _linkPic = GameConfig.HelperUpgradeCfg.attackLink
    if roleNum==5 then
        _directPic = GameConfig.HelperUpgradeCfg.defDirect
        _linkPic = GameConfig.HelperUpgradeCfg.defLink
    end
    CsbContainer:setSpritesPic(self._mainNode, {
        mDirectSprite = _directPic,
        mLinkSprite = _linkPic,
    })

    GameUtil_PlaySound(GAME_SOUND.helperLvlUp)
end

return HelperUpgradeView