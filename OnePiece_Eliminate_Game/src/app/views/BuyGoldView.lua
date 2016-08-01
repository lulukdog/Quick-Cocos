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
    if device.platform == "android" then
        self:buyItem()
    elseif device.platform == "windows" then
        game.myGold = game.myGold + GameConfig.GoldTb[btnNum]
        UserDefaultUtil:saveGold()
        sendMessage({msg="REFRESHGOLD"})
    end
end



local function callback(result)
    if result == "success" then
        game.myGold = game.myGold + 500
        UserDefaultUtil:saveGold()
        sendMessage({msg="REFRESHGOLD"})
    end
end

function BuyGoldView:buyItem()
    local args = {
        "items",
        10,
        8,
        callback,
        1,
    }
    print("BuyGoldView:buyItem")
    if device.platform == "android" then

        -- Java 类的名称
        local className = "org/cocos2dx/sdk/EyeCat"
        -- 调用 Java 方法
        print("BuyGoldView:buyItem"..className)
        local ok, ret = luaj.callStaticMethod(className, "wxpee", args, "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;II)V")
        if not ok then
            print("luaj error:", ret)
        else
            print("ret:", ret) -- 输出 ret: 5
        end
    end
    
end

return BuyGoldView