----------------------------------------------------------------------------------
--[[
    FILE:           BigSkillPreView.lua
    DESCRIPTION:    
    AUTHOR:         ZhaoLu
    CREATED:        2016-08-19 
--]]
----------------------------------------------------------------------------------
local GameConfig = require("data.GameConfig")
local BigSkillPreView = class("BigSkillPreView", function()
    return display.newNode()
end)

function BigSkillPreView:ctor(skillTag)

	self._mainNode = CsbContainer:createPushCsb("BigSkillPreView.csb"):addTo(self)

    CsbContainer:setNodesVisible(self._mainNode, {
        mSkillBombAllSprite = skillTag==GameConfig.BigSkillCfg.bombAll,
        mFreezeRoundSprite = skillTag==GameConfig.BigSkillCfg.freezeRound,
    })

    local fireBtn = cc.uiloader:seekNodeByName(self._mainNode,"mOnfireBtn")
	CsbContainer:decorateBtn(fireBtn,function()
        sendMessage({msg="GameScene_BigSkillAni",tag=skillTag})
        if skillTag==GameConfig.BigSkillCfg.bombAll then
            sendMessage({msg="GAMESCENE_DISABLE"})
        end
		self:removeFromParent()
		self._mainNode = nil
	end)

end

return BigSkillPreView