----------------------------------------------------------------------------------
--[[
    FILE:           SetView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-24 
--]]
----------------------------------------------------------------------------------
local SetView = class("SetView", function()
    return display.newNode()
end)

function SetView:ctor()

	self._mainNode = CsbContainer:createPushCsb("SetView.csb"):addTo(self)

    local closeBtn = cc.uiloader:seekNodeByName(self._mainNode,"mCloseBtn")
	CsbContainer:decorateBtn(closeBtn,function()
		self:removeFromParent()
		self._mainNode = nil
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
end

return SetView