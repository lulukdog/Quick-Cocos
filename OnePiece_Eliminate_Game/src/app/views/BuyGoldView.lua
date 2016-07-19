----------------------------------------------------------------------------------
--[[
    FILE:           BuyGoldView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-25
--]]
----------------------------------------------------------------------------------
local GameConfig = require("data.GameConfig")

local BuyGoldView = class("BuyGoldView", function()
    return display.newNode()
end)

function BuyGoldView:ctor()

	self._mainNode = CsbContainer:createPushCsb("BuyGoldView.csb"):addTo(self)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
	CsbContainer:decorateBtn(closeBtn,function()
		self:removeFromParent()
		self._mainNode = nil
	end)

    for i=1,5 do
        local buyBtn = cc.uiloader:seekNodeByName(self._mainNode,"mBuyBtn"..i)
        CsbContainer:decorateBtn(buyBtn,function()
            self:buyGold(i)
        end)
    end

end

-- 点击购买相应价格的游戏币
function BuyGoldView:buyGold( btnNum )
    game.myGold = game.myGold + GameConfig.GoldTb[btnNum]
    UserDefaultUtil:saveGold()
    sendMessage({msg="REFRESHGOLD"})
end

return BuyGoldView