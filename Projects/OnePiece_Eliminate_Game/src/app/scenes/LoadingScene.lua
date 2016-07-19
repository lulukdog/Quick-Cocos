local BubbleButton = import("..views.BubbleButton")
local picPath = require("data.data_picPath")
local plistPngPath = require("data.data_plistPath")

local LoadingScene = class("LoadingScene", function()
    return display.newScene("LoadingScene")
end)

function LoadingScene:ctor()
  self.bg = display.newSprite("Login/BG.png", display.cx, display.cy)
  self.bg:setScale(display.right/self.bg:getContentSize().width)
  self:addChild(self.bg)

  self.startButton = BubbleButton.new({
          image = "Login/StartBtn.png",
          prepare = function()
              audio.playSound(GAME_SOUND.tapButton)
              self.startButton:setButtonEnabled(false)
          end,
          listener = function()
              self:enterMapScene()
          end,
      })
      :align(display.CENTER, display.cx, display.bottom + 150)
      :addTo(self)
  self.startButton:setScale(display.right/self.bg:getContentSize().width)
  self.all_num = #picPath + #plistPngPath
  self.load_num = 0
  self.load_plist = 0

  -- 设置全局随机种子
  math.newrandomseed()

  -- 初始化倒计时和体力值
  self:initEnergyNum()
  -- 初始化当前关卡
  self:initNowStage()
  -- 初始化星星
  self:initStageStars()
  -- 初始化关卡最大分数
  self:initStageMaxScore()
  -- 初始化帮手等级
  self:initHelperLevels()
  -- 初始化船的等级和经验
  self:initShipLevelAndExp()
  -- 初始化船的类型
  self:initShipType()
  -- 初始化金币数
  self:initGold()
  -- 初始化音乐和音效开关
  self:initMusicAndSound()

  -- 每秒走一次，倒计时用
  GameUtil_addSecond()
end

-- 初始化倒计时和体力值
function LoadingScene:initEnergyNum()
  if UserDefaultUtil:GetEnergy() == nil then
    return
  end
  local osTime,countTime,energyNum = UserDefaultUtil:GetEnergy()
  if energyNum>=game.MAXENERGY then
    game.myEnergy = energyNum
    return
  end

  local diffTime = math.max((os.time() - osTime),0)
  game.myEnergy = math.min((math.floor(diffTime/game.addOneEnergyTime)+energyNum),game.MAXENERGY)
  game.countTime = math.max((countTime-diffTime),0)
end
-- 初始化当前关卡
function LoadingScene:initNowStage()
  if UserDefaultUtil:GetNowMaxStage()~=0 then
    game.NowStage = UserDefaultUtil:GetNowMaxStage()
  end
end
-- 初始化星星
function LoadingScene:initStageStars()
  if UserDefaultUtil:getStageStars()~=nil then
    game.stageStars = UserDefaultUtil:getStageStars()
    game.myStarNum = 0
    for i,v in ipairs(game.stageStars) do
      game.myStarNum = game.myStarNum + v
    end
  end
end
-- 初始化关卡最大分数
function LoadingScene:initStageMaxScore()
  if UserDefaultUtil:getStageMaxScore()~=nil then
    game.stageMaxScore = UserDefaultUtil:getStageMaxScore()
  end
end
-- 初始化帮手等级
function LoadingScene:initHelperLevels()
  if UserDefaultUtil:getHelperLevel()~=nil then
    game.helper = UserDefaultUtil:getHelperLevel()
  end
end
-- 初始化船的等级和经验
function LoadingScene:initShipLevelAndExp()
  if UserDefaultUtil:getShipLevel()~=0 then
    game.nowShipLevel = UserDefaultUtil:getShipLevel()
  end
  if UserDefaultUtil:getShipExp()~=0 then
    game.nowShipExp = UserDefaultUtil:getShipExp()
  end
end
-- 初始化船的类型
function LoadingScene:initShipType()
  if UserDefaultUtil:getShipType()~=0 then
    game.nowShip = UserDefaultUtil:getShipType()
  end
end

-- 初始化金币
function LoadingScene:initGold()
  if UserDefaultUtil:getGold()~=0 then
    game.myGold = UserDefaultUtil:getGold()
  end
end
-- 初始化音乐和音效开关
function LoadingScene:initMusicAndSound()
  if UserDefaultUtil:getMusic()==0 or UserDefaultUtil:getSound()==0 then
    return
  end
  game.MusicOn = UserDefaultUtil:getMusic()==1
  game.SoundOn = UserDefaultUtil:getSound()==1
end


-- 加载资源进度条
function LoadingScene:enterMapScene()
  for i=1,#picPath do
    display.addImageAsync(picPath[i], handler(self,self.loadPic))
  end
  for i=1,#plistPngPath do
    display.addImageAsync(plistPngPath[i], handler(self,self.loadPlist))
  end
  
end

function LoadingScene:cacheAni()
    -- add disapear ani
    local frames = display.newFrames("disappear%02d.png",1,6)
    local animation = display.newAnimation(frames,0.6/6)     --0.6s里面播放6帧
    display.setAnimationCache("disappear",animation)
    -- add mayixian ani
    frames = display.newFrames("mayixian%d.png",1,6)
    animation = display.newAnimation(frames,0.2/6)     
    display.setAnimationCache("mayixian",animation)
    -- add 冰块破碎动画
    frames = display.newFrames("ice_%d.png",1,8)
    animation = display.newAnimation(frames,0.4/8)     
    display.setAnimationCache("ice",animation)
    -- add 石块破碎动画
    frames = display.newFrames("stone_%d.png",1,8)
    animation = display.newAnimation(frames,0.4/8)     
    display.setAnimationCache("stone",animation)
    -- add 物块静止时的扫光动画
    frames = display.newFrames("dangong%d.png",1,5)
    animation = display.newAnimation(frames,0.5/5)     
    display.setAnimationCache("dangong",animation)
    frames = display.newFrames("dao%d.png",1,5)
    animation = display.newAnimation(frames,0.5/5)     
    display.setAnimationCache("dao",animation)
    frames = display.newFrames("dun%d.png",1,5)
    animation = display.newAnimation(frames,0.5/5)     
    display.setAnimationCache("dun",animation)
    frames = display.newFrames("juzi%d.png",1,5)
    animation = display.newAnimation(frames,0.5/5)     
    display.setAnimationCache("juzi",animation)
    frames = display.newFrames("maozi%d.png",1,5)
    animation = display.newAnimation(frames,0.5/5)     
    display.setAnimationCache("maozi",animation)
    frames = display.newFrames("xin%d.png",1,5)
    animation = display.newAnimation(frames,0.5/5)     
    display.setAnimationCache("xin",animation)

end

function LoadingScene:isLoadingFinish(  )
  if self.load_num==self.all_num then 
    self:cacheAni()
    app:enterScene("MapScene", nil, "fade", 0.6, display.COLOR_WHITE)
  end
end
function LoadingScene:loadPic( )
  self.load_num = self.load_num + 1
  print("LoadingScene:loadPic "..self.load_num)
  self:isLoadingFinish()
end
function LoadingScene:loadPlist( )
  self.load_plist = self.load_plist + 1
  local _plistPath = plistPngPath[self.load_plist]:sub(0,-5)..".plist"
  display.addSpriteFrames(_plistPath,plistPngPath[self.load_plist])
  self.load_num = self.load_num + 1
  print("LoadingScene:loadPlist "..self.load_num)
  self:isLoadingFinish()
end


function LoadingScene:onEnter()
  print("LoadingScene:onEnter")
  GameUtil_resetMusic()
end

function LoadingScene:onExit()
	print("LoadingScene:onExit")
end

return LoadingScene
