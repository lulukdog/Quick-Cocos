----------------------------------------------------------------------------------
--[[
    FILE:           Ship2PopView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-24 
--]]
----------------------------------------------------------------------------------
local GameConfig = require("data.GameConfig")
-- local shipCfg = require("data.data_ship2")
local ShipGetPushView = import(".ShipGetPushView")


local Ship2PopView = class("Ship2PopView", function()
    return display.newNode()
end)

function Ship2PopView:ctor()

	self._mainNode = CsbContainer:createPushCsb("Ship2PopView.csb"):addTo(self)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
	CsbContainer:decorateBtn(closeBtn,function()
		self:removeFromParent()
		self._mainNode = nil
	end)

    local buyBtn = cc.uiloader:seekNodeByName(self._mainNode,"mBuyBtn")
    CsbContainer:decorateBtn(buyBtn,function()
        if game.nowShip<#GameConfig.ShipNamePic then
            game.nowShip = game.nowShip+1
            UserDefaultUtil:saveShipType()
            sendMessage({msg = "MapScene_RefreshPage"})
            sendMessage({msg = "SHIP_UPGRADE_REFRESH"})
            ShipGetPushView.new():addTo(self:getParent())
        end
        self:removeFromParent()
        self._mainNode = nil
    end)

    -- CsbContainer:setStringForLabel(self._mainNode, {
    --     mAttackLabel = shipCfg[game.nowShipLevel].attack,
    --     mDefLabel = shipCfg[game.nowShipLevel].def,
    --     mLifeLabel = shipCfg[game.nowShipLevel].life,
    -- })

end

return Ship2PopView