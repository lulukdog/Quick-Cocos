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

function UnlockConfirmView_video( result )
    if result=="success" then
        common:javaSaveUserData("AdvVideo",tostring(GameConfig.AdvType.shanzhiHelper))
        sendMessage({msg="UnlockConfirmView_buySuccess",helperNum=5})
    else
        MessagePopView.new(10):addTo(self)
    end
end

function UnlockConfirm_namei( result )
    if result == "fail" then
        MessagePopView.new(8):addTo(self)
    else
        sendMessage({msg="UnlockConfirmView_buySuccess",helperNum=3})
    end
end
function UnlockConfirm_qiaoba( result )
    if result == "fail" then
        MessagePopView.new(8):addTo(self)
    else
        print("UnlockConfirm_qiaobaVideo")
        sendMessage({msg="UnlockConfirmView_buySuccess",helperNum=6})
    end
end

function UnlockConfirmView:buyHelperSuccess(data)
    local helperNum = data.helperNum
    print("UnlockConfirmView:buyHelperSuccess")
    game.helper[helperNum] = 1
    UserDefaultUtil:saveHelperLevel()
    sendMessage({msg="UnlockRoleView_refreshUnlockNode"})
    sendMessage({msg="MapScene_RefreshPage"})
    sendMessage({msg="MapScene_PushRoleGetView",_btnNum=helperNum})
end

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
                common:javaOnVideo(UnlockConfirmView_video)
            -- 娜美
            elseif btnNum==3 then
                common:javaOnUseMoney(UnlockConfirm_namei,100)
            -- 乔巴
            elseif btnNum==6 then
                common:javaOnUseMoney(UnlockConfirm_qiaoba,100)
            end
            if device.platform == "windows" then
                sendMessage({msg="UnlockConfirmView_buySuccess",helperNum=btnNum})
            end
            self:removeFromParent()
            self._mainNode = nil
        end
    end)
    if btnNum==5 then
        CsbContainer:refreshBtnView(confirmBtn, "kanshipin_btn.png", "kanshipin_btn.png")
    end

    addMessage(self, "UnlockConfirmView_buySuccess", self.buyHelperSuccess)
end



return UnlockConfirmView