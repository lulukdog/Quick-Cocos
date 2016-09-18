----------------------------------------------------------------------------------
--[[
    FILE:           PauseView.lua
    DESCRIPTION:    暂停页面
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-22
--]]
----------------------------------------------------------------------------------
local PauseView = class("PauseView", function()
    return display.newNode()
end)

function PauseView:ctor(closeCallback)
	self.closeCallback = closeCallback

	self._mainNode = CsbContainer:createPushCsb("PauseView.csb"):addTo(self)
	
	local mCloseBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
	CsbContainer:decorateBtn(mCloseBtn,function()
		self:close()
	end)

	local mBackMapBtn = cc.uiloader:seekNodeByName(self._mainNode,"mBackMapBtn")
	CsbContainer:decorateBtnNoTrans(mBackMapBtn,function()
		-- 记录统计
		UserDefaultUtil:recordResult(3,game.nowStage,0)
		app:enterScene("MapScene", nil, "fade", 0.6, display.COLOR_WHITE)
	end)

	local mResumeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mResumeBtn")
	CsbContainer:decorateBtnNoTrans(mResumeBtn,function()
		self:close()
	end)

	local mMusicBtn = cc.uiloader:seekNodeByName(self._mainNode,"mMusicBtn")
	local mCloseMusic = cc.uiloader:seekNodeByName(self._mainNode,"mCloseMusic")
	mCloseMusic:setVisible(not game.MusicOn)
	CsbContainer:decorateBtnNoTrans(mMusicBtn,function()
		game.MusicOn = not game.MusicOn
		GameUtil_resetMusic()
		mCloseMusic:setVisible(not game.MusicOn)
	end)

	local mSoundBtn = cc.uiloader:seekNodeByName(self._mainNode,"mSoundBtn")
	local mCloseSound = cc.uiloader:seekNodeByName(self._mainNode,"mCloseSound")
	mCloseSound:setVisible(not game.SoundOn)
	CsbContainer:decorateBtnNoTrans(mSoundBtn,function()
		game.SoundOn = not game.SoundOn
		UserDefaultUtil:saveSound()
		mCloseSound:setVisible(not game.SoundOn)
	end)


	self:setVisible(false)
end

function PauseView:open()
	self:setVisible(true)
	-- self:runAction(cc.Sequence:create(
	-- 	cc.ScaleTo:create(0.1, 1.3, 1),
	-- 	cc.ScaleTo:create(0.1, 1, 1)
	-- ))	
end

function PauseView:close()
	self:setVisible(false)
	if self.closeCallback ~= nil then
	    self.closeCallback()
	end

end

return PauseView