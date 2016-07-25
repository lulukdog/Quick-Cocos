
require("config")
require("cocos.init")
require("framework.init")

require("data.GameConstants")
require("app.UserDefaultUtil")
require("app.GameUtil")
require("app.MessageManager")
require("app.CsbContainer")
require("app.views.MessagePopView")


local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    cc.FileUtils:getInstance():addSearchPath("res/font")
    cc.FileUtils:getInstance():addSearchPath("res/sprites")
    cc.FileUtils:getInstance():addSearchPath("res/plist")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/pic")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/LoadingScene")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/FightBg")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/luffy")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/helper")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/boss")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/GameScene")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/MapScene")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/MapDetail")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/WinPopPage")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/haizei")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/haijun")

    cc.FileUtils:getInstance():addSearchPath("res/sprites/ShipUpgrade")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/PauseView")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/SelectHelperView")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/UnlockRoleView")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/UnlockConfirmView")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/RoleDetailView")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/SetView")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/BattleFailPopView")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/BuyGoldView")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/BuyEnergyView")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/MessagePopView")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/StageNode")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/LinkNum")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/GuideView")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/UpgradePushView")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/RoleGetPushView")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/Prefacemov")
    cc.FileUtils:getInstance():addSearchPath("res/sprites/GoldBoxView")

    --preload all sounds
    for k, v in pairs(GAME_SOUND) do
        audio.preloadSound(v)
    end
    for k, v in pairs(GAME_MUSIC) do
        audio.preloadMusic(v)
    end

    self:enterScene("LoadingScene")
end



return MyApp
