----------------------------------------------------------------------------------
--[[
    FILE:           UnlockConfirmView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-24 
--]]
----------------------------------------------------------------------------------
local helperCfg = require("data.data_helper")
local GameConfig = require("data.GameConfig")
local common = require("app.common")

local RoleGetPushView = import(".RoleGetPushView")

local UnlockConfirmView = class("UnlockConfirmView", function()
    return display.newNode()
end)

function UnlockConfirmView:ctor(btnNum)

	self._mainNode = CsbContainer:createPushCsb("UnlockConfirmView.csb"):addTo(self)

    CsbContainer:setSpritesPic(self._mainNode, {
        mRoleSprite = GameConfig.BuyHelperBgPic[btnNum]
    })

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
	CsbContainer:decorateBtn(closeBtn,function()
		self:removeFromParent()
		self._mainNode = nil
	end)

    local confirmBtn = cc.uiloader:seekNodeByName(self._mainNode,"mConfirmBtn")
    CsbContainer:decorateBtn(confirmBtn,function()
        -- TODO buy
        if game.helper[btnNum]==0 then
            -- 统计视频次数
            if btnNum==5 then
                common:javaSaveUserData("AdvVideo",tostring(GameConfig.AdvType.shanzhiHelper))

                -- 观看视频
                if device.platform == "android" then
                    local args = {}
                    local className = "org/cocos2dx/sdk/TapjoySDK"
                    local ok = luaj.callStaticMethod(className, "Tapjoy_ShowVideo", args, "()V")
                    print("Tapjoy_ShowVideo")
                    if not ok then
                        print("Tapjoy_ShowVideo error")
                    end
                end
            end

            game.helper[btnNum] = 1
            UserDefaultUtil:saveHelperLevel()
            sendMessage({msg="UnlockRoleView_refreshUnlockNode"})
            sendMessage({msg="MapScene_RefreshPage"})

            -- 弹出人物获得页面
            RoleGetPushView.new(btnNum):addTo(self:getParent())
            

            self:removeFromParent()
            self._mainNode = nil
        end
    end)
    if btnNum==5 then
        CsbContainer:refreshBtnView(confirmBtn, "kanshipin_btn.png", "kanshipin_btn.png")
    end

end

return UnlockConfirmView