----------------------------------------------------------------------------------
--[[
    FILE:           UnlockRoleView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-24 
--]]
----------------------------------------------------------------------------------
local helperCfg = require("data.data_helper")
local GameConfig = require("data.GameConfig")
local UnlockConfirmView = import(".UnlockConfirmView")
local GuideFingerPushView = import(".GuideFingerPushView")
local RoleDetailView = import(".RoleDetailView")

local UnlockRoleView = class("UnlockRoleView", function()
    return display.newNode()
end)

function UnlockRoleView:ctor()

	self._mainNode = CsbContainer:createPushCsb("UnlockRoleView.csb"):addTo(self)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
	CsbContainer:decorateBtn(closeBtn,function()
		removeMessageByTarget(self)
		self:removeFromParent()
		self._mainNode = nil
	end)

	self:refreshUnlockNode()
	-- 解锁按钮
	for i=2,6 do
		local unlockBtn = cc.uiloader:seekNodeByName(self._mainNode,"mUnlockBtn"..i)
		if unlockBtn~=nil then
			CsbContainer:decorateBtnNoTrans(unlockBtn,function()
				self:onUnlock(i)
			end)
		end
	end
	-- 查看人物详情按钮
	for i=1,6 do
		local onRoleBtn = cc.uiloader:seekNodeByName(self._mainNode,"onRole"..i)
		if onRoleBtn~=nil then
			CsbContainer:decorateBtnNoTrans(onRoleBtn,function()
				if game.guideStep==11 then
					sendMessage({msg="GuideFingerPushView_onNext"})
				end 
				RoleDetailView.new(i):addTo(self)
			end)
		end
	end

	addMessage(self, "UnlockRoleView_refreshUnlockNode",self.refreshUnlockNode)

	-- 新手引导
	if game.guideStep==11 then
		GuideFingerPushView.new():addTo(self)
	end
end

-- 刷新解锁状态
function UnlockRoleView:refreshUnlockNode(  )
	for i=1,6 do
		CsbContainer:setNodesVisible(self._mainNode,{
			["mUnlockNode"..i] = game.helper[i]==0
		})

		CsbContainer:setStringForLabel(self._mainNode,{
			["mLvLabel"..i] = "Lv"..game.helper[i],
		})
	end
end

function UnlockRoleView:onUnlock( btnNum )
	UnlockConfirmView.new(btnNum):addTo(self)
end

return UnlockRoleView