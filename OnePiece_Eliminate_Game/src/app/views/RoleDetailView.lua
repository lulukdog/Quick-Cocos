----------------------------------------------------------------------------------
--[[
    FILE:           RoleDetailView.lua
    DESCRIPTION:    升级角色页面
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-24 
--]]
----------------------------------------------------------------------------------
local GuideFingerPushView = import(".GuideFingerPushView")
local CommonConfirmView = import(".CommonConfirmView")
local HelperUpgradeView = import(".HelperUpgradeView")
local BuyGoldView = import(".BuyGoldView")

local GameConfig = require("data.GameConfig")
local helperCfg = require("data.data_helper")
local skillCfg = require("data.data_skill")
local common = require("app.common")

local RoleDetailView = class("RoleDetailView", function()
    return display.newNode()
end)

function RoleDetailView:ctor(btnNum)
	self.btnNum = btnNum
	self.roleCfg = helperCfg[btnNum]

	self._mainNode = CsbContainer:createPushCsb("RoleDetailView.csb"):addTo(self)
	self.needGold = 0 -- 升级需要金钱

	self:refreshPage()

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
	CsbContainer:decorateBtn(closeBtn,function()
		sendMessage({msg="UnlockRoleView_refreshUnlockNode"})
		self:removeFromParent()
		self._mainNode = nil
	end)

	local upgradeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mUpgradeBtn")
	CsbContainer:decorateBtn(upgradeBtn,function()
		if game.guideStep==14 then
			sendMessage({msg="GuideFingerPushView_onNext"})
		end

		if (game.helper[btnNum]+1) > #skillCfg then
			MessagePopView.new(3):addTo(self)
			return
		end

		if common:goldCost(self.needGold) then
			game.helper[btnNum] = game.helper[btnNum] + 1
			UserDefaultUtil:saveHelperLevel(btnNum,self.needGold)
			HelperUpgradeView.new(btnNum):addTo(self)
			self:refreshPage()
			sendMessage({msg="REFRESHGOLD"})
		else
			-- MessagePopView.new(2):addTo(self)
			CommonConfirmView.new(GameConfig.NotEnoughGold,function()
				BuyGoldView.new():addTo(self)
			end):addTo(self)
		end
		
	end)

	CsbContainer:setNodesVisible(self._mainNode,{
		mUpgradeBtn = game.helper[btnNum]~=0,
	})

	if game.guideStep==14 then
		GuideFingerPushView.new():addTo(self)
	end

	-- 动画
	local _ani = cc.CSLoader:createTimeline("RoleDetailView.csb")
	self._mainNode:runAction(_ani)
	_ani:gotoFrameAndPlay(0,45,true)
end

-- 刷新等级，伤害，所需物品
function RoleDetailView:refreshPage()
	local lvNum = math.max(game.helper[self.btnNum],1)
	local costCfg = common:parseStrWithComma(skillCfg[lvNum].cost)
	for i,v in ipairs(costCfg) do
		if v.id==1 then
			self.needGold = tonumber(v.count)
		end
	end
	
	CsbContainer:setNodesVisible(self._mainNode, {
		mMaxNode = lvNum>=#skillCfg,
		mCostNode = lvNum<#skillCfg,
	})

	local skillName = skillCfg[lvNum]["skill"..self.btnNum] or ""
	CsbContainer:setStringForLabel(self._mainNode,{
        mNameLabel = self.roleCfg.name,
        mLevelLabel = "Lv"..game.helper[self.btnNum],
        mSkillLabel = self.roleCfg.skillDes..skillName,
        mAttrLabel = self.roleCfg.attrDes..skillCfg[lvNum]["attr"..self.btnNum],
    })
    CsbContainer:setSpritesPic(self._mainNode,{
    	mRolePic = self.roleCfg.detailPic,
    })
    --TODO 需要物品
    -- CsbContainer:setSpritesPic(self._mainNode,{
    -- 	mPic1 = ""
    -- })
    CsbContainer:setStringForLabel(self._mainNode,{
        mNum1 = self.needGold,
    })
end

return RoleDetailView