----------------------------------------------------------------------------------
--[[
    FILE:           StoryView.lua
    DESCRIPTION:    剧情页面
    AUTHOR:         ZhaoLu
    CREATED:        2016-07-20 
--]]
----------------------------------------------------------------------------------
local storyCfg = require("data.data_story")
local stageCfg = require("data.data_stage")
local common = require("app.common")

local StoryView = class("StoryView", function()
    return display.newNode()
end)

function StoryView:ctor()

	self._mainNode = CsbContainer:createCsb("StoryView.csb"):addTo(self)

    self._storyIdTb = common:parseStrOnlyWithComma(stageCfg[game.nowStage].storyId)
    self._storyNum = 1

    local _nextBtn = cc.uiloader:seekNodeByName(self._mainNode, "mNextBtn")
    CsbContainer:decorateBtnNoTrans(_nextBtn,function()
        self._storyNum = self._storyNum + 1
        self:refreshPage()
    end)

    self:refreshPage()
end

function StoryView:refreshPage()
    print("StoryView:refreshPage "..self._storyNum)

    if self._storyNum<=#self._storyIdTb then
        local _cfg = storyCfg[tonumber(self._storyIdTb[self._storyNum])]
        CsbContainer:setStringForLabel(self._mainNode, {
            mDialogLabel = _cfg.dialog,
        })
        -- 1是左面，2是右面
        CsbContainer:setNodesVisible(self._mainNode, {
            mLeftSprite =_cfg.pos==1,
            mRightSprite =_cfg.pos==2,
        })
        if _cfg.pos==1 then
            CsbContainer:setSpritesPic(self._mainNode, {mLeftSprite=_cfg.pic})
        elseif _cfg.pos==2 then
            CsbContainer:setSpritesPic(self._mainNode, {mRightSprite=_cfg.pic})
        end
    else
        self:onExit()
    end
end

function StoryView:onExit( )
    sendMessage({msg="StoryView_Exit"})

    self._mainNode:removeFromParent()
    self._mainNode = nil
end

return StoryView