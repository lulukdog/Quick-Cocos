----------------------------------------------------------------------------------
--[[
    FILE:           ShipUpgradeView.lua
    DESCRIPTION:    船升级页面
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-21 
--]]
----------------------------------------------------------------------------------
local GameConfig = require("data.GameConfig")
local Ship2PopView = import(".Ship2PopView")

local ShipUpgradeView = class("ShipUpgradeView", function()
    return display.newNode()
end)

function ShipUpgradeView:ctor()

	self._mainNode = CsbContainer:createPushCsb("ShipUpgrade.csb"):addTo(self)
	
	local upgradeBtn = cc.uiloader:seekNodeByName(self._mainNode,"upgradeBtn")
	CsbContainer:decorateBtnNoTrans(upgradeBtn,function()
		Ship2PopView.new():addTo(self)
	end)

	local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"closeBtn")
	CsbContainer:decorateBtn(closeBtn,function()
		self:removeFromParent()
		self._mainNode = nil
	end)

	self:refreshPage()

	addMessage(self, "SHIP_UPGRADE_REFRESH", self.refreshPage)
end

function ShipUpgradeView:refreshPage()
	local shipCfg = GameUtil_getShipCfg()

	CsbContainer:setNodesVisible(self._mainNode, {
		upgradeBtn = game.nowShip<#GameConfig.ShipNameCfg
	})

	CsbContainer:setStringForLabel(self._mainNode, {
		mShipName = GameConfig.ShipNameCfg[game.nowShip],
		mLevel = game.nowShipLevel,
		mAttack = shipCfg[game.nowShipLevel].attack,
		mDef = shipCfg[game.nowShipLevel].def,
		mLife = shipCfg[game.nowShipLevel].life,
	})

	-- 当前船的经验
    local expBar = cc.uiloader:seekNodeByName(self._mainNode,"expBar")
    local expNum = math.max((game.nowShipExp/shipCfg[game.nowShipLevel].needExp)*100,0)
    expNum = math.min(expNum,100)
    expBar:setPercent(expNum)
end

return ShipUpgradeView