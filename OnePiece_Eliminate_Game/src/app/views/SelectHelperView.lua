----------------------------------------------------------------------------------
--[[
    FILE:           SelectHelperView.lua
    DESCRIPTION:    选择帮助人员页面
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-23 
--]]
----------------------------------------------------------------------------------
local GuideFingerPushView = import(".GuideFingerPushView")
local CommonConfirmView = import(".CommonConfirmView")
local BuyEnergyView = import(".BuyEnergyView")

local GameConfig = require("data.GameConfig")
local helperCfg = require("data.data_helper")
local skillCfg = require("data.data_skill")
local common = require("app.common")

local SelectHelperView = class("SelectHelperView", function()
    return display.newNode()
end)

function SelectHelperView:ctor(isFromBattlePage)
	-- 是从页面详情进来还是从战斗页面进来
	self._isFromBattlePage = isFromBattlePage or false

	-- 显示在上面的选择的角色
	self.helperOnShowTb = common:table_deep_copy(game.helperOnFight)
	-- 可以出战的角色
	self.helperTb = {}
	for i=2,#game.helper do
		if game.helper[i]~=0 then
			table.insert(self.helperTb,i)
		end
	end

	self._mainNode = CsbContainer:createPushCsb("SelectHelpView.csb"):addTo(self)

	local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
	CsbContainer:decorateBtn(closeBtn,function()
		self:removeFromParent()
		self._mainNode = nil
	end)
	local startBtn = cc.uiloader:seekNodeByName(self._mainNode,"mStartBtn")
	CsbContainer:decorateBtnNoTrans(startBtn,function()
		if game.helper[2]>0 and game.nowStage==13 and game.guideStep==15 then
			sendMessage({msg="GuideFingerPushView_onNext"})
		end 

		if common:energyIsEnough(5) then
			self:onStart(false)
			app:enterScene("GameScene", nil, "fade", 0.6, display.COLOR_WHITE)
		else
			CommonConfirmView.new(GameConfig.NotEnoughEnergy,function()
				BuyEnergyView.new():addTo(self)
			end):addTo(self)
		end
	end)
	local confirmBtn = cc.uiloader:seekNodeByName(self._mainNode,"mConfirmBtn")
	CsbContainer:decorateBtn(confirmBtn,function()
		self:onStart(true)
	end)

	-- 战斗页面进来显示确认，地图详情进来显示进入战斗
	CsbContainer:setNodesVisible(self._mainNode,{
		mConfirmBtn = self._isFromBattlePage==true,
		mStartBtn = self._isFromBattlePage~=true,
		mCloseBtn = self._isFromBattlePage~=true,
	})
	-- 有几个角色开启显示几个cell
	for i=1,5 do
		CsbContainer:setNodesVisible(self._mainNode,{
			["mHelperCell"..i] = i<=#self.helperTb
		})
	end

	-- 刷新初始页面
	for i,v in ipairs(self.helperTb) do
		self:refreshFightBtn(i)
	end
	self:refreshShowHelper()
	-- 角色的头像，数值
	for i,v in ipairs(self.helperTb) do
		CsbContainer:setSpritesPic(self._mainNode,{
			["mPic"..i] = helperCfg[v].pic
		})

		local helperLevel = game.helper[v]
		local _useCost = tonumber(common:parseStrWithComma(skillCfg[helperLevel].useCost)[1].count)
		CsbContainer:setStringForLabel(self._mainNode,{
			["mLevelLabel"..i] = helperLevel,
			["mDirectHurtLabel"..i] = helperCfg[v].skillDes..skillCfg[helperLevel]["skill"..v],
			["mName"..i] = helperCfg[v].name,
			["mNeedGoldLabel"..i] = _useCost,
		})

		local fightBtn = cc.uiloader:seekNodeByName(self._mainNode,"mFightBtn"..i)
		CsbContainer:decorateBtnNoTrans(fightBtn,function()
			self:onFightOrCancel(i,false)
		end)
		local fightCellBtn = cc.uiloader:seekNodeByName(self._mainNode,"mFightCellBtn"..i)
		CsbContainer:decorateBtnNoTrans(fightCellBtn,function()
			if game.helper[2]>0 and game.nowStage==13 and game.guideStep==14 then
				sendMessage({msg="GuideFingerPushView_onNextGuide"})
			end 
			self:onFightOrCancel(i,false)
		end)

		local cancelBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCancelBtn"..i)
		CsbContainer:decorateBtnNoTrans(cancelBtn,function()
			self:onFightOrCancel(i,true)
		end)
		local cancelCellBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCancelCellBtn"..i)
		CsbContainer:decorateBtnNoTrans(cancelCellBtn,function()
			self:onFightOrCancel(i,true)
		end)
	end
	-- 点击头像取消帮忙角色
	for i=1,4 do
		local cancelBtn = cc.uiloader:seekNodeByName(self._mainNode,"mFightHelperBtn"..i)
		CsbContainer:decorateBtnNoTrans(cancelBtn,function()
			if self._isFromBattlePage==false then
				self:onHelperBtn(i)
			end
		end)
	end

	-- 新手引导
	if game.helper[2]>0 and game.nowStage==13 and game.guideStep==14 then
		-- TODO 金币不够
		if game.myGold>500 then
			GuideFingerPushView.new():addTo(self)
		else
			game.guideStep = game.MAXGUIDESTEP+1
		end
	end

	-- 自己的金币数
	self._myGold = game.myGold
	self:refreshPage()
end

function SelectHelperView:refreshPage()
	CsbContainer:setStringForLabel(self._mainNode, {
		mMyGoldLabel = self._myGold,
	})
end

function SelectHelperView:onStart(isConfirm)
	game.helperOnFight = {}
	game.helperOnFight = common:table_deep_copy(self.helperOnShowTb)
	self.helperOnShowTb = {}

	-- 选中的帮助角色扣钱
	game.myGold = self._myGold
	UserDefaultUtil:saveGold()

	if isConfirm==true then
		sendMessage({msg ="GAMESCENE_REFRESH_HELPER"})
	end

	self:removeFromParent()
	self._mainNode = nil
end

-- 选中出战显示取消，选中取消显示出战
function SelectHelperView:setHelperOnFight( btnNum,isCancel )
	local heplerNum = self.helperTb[btnNum]
	if isCancel==false then
		if #self.helperOnShowTb>=4  then
			print("this helper can't on fight")
		else
			table.insert(self.helperOnShowTb,heplerNum)
		end
	-- 选择出战
	else
		for i,v in ipairs(self.helperOnShowTb) do
			if v==heplerNum then
				table.remove(self.helperOnShowTb,i)
			end
		end
	end
end
-- 选中出战显示取消，选中取消显示出战
function SelectHelperView:refreshFightBtn( btnNum )
	local heplerNum = self.helperTb[btnNum]
	for i,v in ipairs(self.helperTb) do
		CsbContainer:setNodesVisible(self._mainNode,{
			["mFightBtn"..i] = not common:table_has_value(self.helperOnShowTb, v),
			["mFightCellBtn"..i] = not common:table_has_value(self.helperOnShowTb, v),
			["mCancelBtn"..i] = common:table_has_value(self.helperOnShowTb, v),
			["mCancelCellBtn"..i] = common:table_has_value(self.helperOnShowTb, v),
			["mSelectPic"..i] = common:table_has_value(self.helperOnShowTb, v),
		})
	end
	
	-- 战斗页面进来的没有取消
	if self._isFromBattlePage==true then
		for i,v in ipairs(self.helperTb) do
			CsbContainer:setNodesVisible(self._mainNode,{
				["mCancelBtn"..i] = false,
				["mCancelCellBtn"..i] = false,
			})
		end
	end
end
-- 刷新上面显示的出战角色
function SelectHelperView:refreshShowHelper()
	--显示几个出战英雄
	for i=1,4 do
		CsbContainer:setNodesVisible(self._mainNode,{
			["mFightHelperBtn"..i] = i<=#self.helperOnShowTb
		})
	end

	for i,v in ipairs(self.helperOnShowTb) do
		local helperShowBtn = cc.uiloader:seekNodeByName(self._mainNode,"mFightHelperBtn"..i)
		local helperPic = helperCfg[v].pic
		CsbContainer:refreshBtnView(helperShowBtn,helperPic,helperPic)
	end
	
end
function SelectHelperView:onFightOrCancel( btnNum,isCancel )

	-- 扣钱
	local helperLevel = game.helper[self.helperTb[btnNum]]
	local _useCost = tonumber(common:parseStrWithComma(skillCfg[helperLevel].useCost)[1].count)
	if isCancel==false then
		if self._myGold >= _useCost then
			self._myGold = self._myGold - _useCost
			self:refreshPage()
		else
			MessagePopView.new(2):addTo(self)
			return
		end
	else
		self._myGold = self._myGold + _useCost
		self:refreshPage()
	end
	
	-- 显示取消或是显示出战
	self:setHelperOnFight(btnNum,isCancel)
	self:refreshFightBtn(btnNum)

	-- 上面显示的人物要换
	self:refreshShowHelper()
end
-- 点击帮忙角色头像
function SelectHelperView:onHelperBtn( btnNum )
	for i,v in ipairs(self.helperTb) do
		if v==self.helperOnShowTb[btnNum] then
			self:onFightOrCancel(i,true)
			return
		end
	end
end

return SelectHelperView