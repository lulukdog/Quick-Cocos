----------------------------------------------------------------------------------
--[[
    FILE:           UpgradePushView.lua
    DESCRIPTION:    船升级页面
    AUTHOR:         ZhaoLu
    CREATED:        2016-07-21 
--]]
----------------------------------------------------------------------------------
local GameConfig = require("data.GameConfig")
local shipCfg = GameUtil_getShipCfg()

local UpgradePushView = class("UpgradePushView", function()
    return display.newNode()
end)

function UpgradePushView:ctor()

	self._mainNode = CsbContainer:createPushCsb("UpgradePushView.csb"):addTo(self)

    local confirmBtn = cc.uiloader:seekNodeByName(self._mainNode,"mConfirmBtn")
	CsbContainer:decorateBtn(confirmBtn,function()
		self:removeFromParent()
		self._mainNode = nil
	end)

    local _ani = cc.CSLoader:createTimeline("UpgradePushView.csb")
    self._mainNode:runAction(_ani)
    _ani:gotoFrameAndPlay(0,240,true)

    CsbContainer:setSpritesPic(self._mainNode, {
        mShipSprite = GameConfig.ShipUpgradePic[game.nowShip]
    })

    CsbContainer:setStringForLabel(self._mainNode, {
        mOriLevelLabel = shipCfg[game.nowShipLevel-1].level,
        mToLevelLabel = shipCfg[game.nowShipLevel].level,
        mOriAttackLabel = shipCfg[game.nowShipLevel-1].attack,
        mToAttackLabel = shipCfg[game.nowShipLevel].attack,
        mOriDefLabel = shipCfg[game.nowShipLevel-1].def,
        mToDefLabel = shipCfg[game.nowShipLevel].def,
        mOriLifeLabel = shipCfg[game.nowShipLevel-1].life,
        mToLifeLabel = shipCfg[game.nowShipLevel].life,
    })
end

return UpgradePushView