----------------------------------------------------------------------------------
--[[
    FILE:           CsbContainer.lua
    DESCRIPTION:    Csb创建工具
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-08
--]]
----------------------------------------------------------------------------------

CsbContainer = {}

function CsbContainer:createCsb( filename )
	local _node = cc.uiloader:load(filename)

	self:fitScreen(_node)
	return _node
end

function CsbContainer:fitScreen( csbNode )

	local _topNode = cc.uiloader:seekNodeByName(csbNode,"TopNode")
	if _topNode then
		fitScreenNode(_topNode)
		_topNode:setPosition(display.cx,display.top)
	end

	local _bottomNode = cc.uiloader:seekNodeByName(csbNode,"BottomNode")
	if _bottomNode then
		fitScreenNode(_bottomNode)
		_bottomNode:setPosition(display.cx,display.bottom)
	end

	local _topLeftNode = cc.uiloader:seekNodeByName(csbNode,"TopLeftNode")
	if _topLeftNode then
		fitScreenNode(_topLeftNode)
		_topLeftNode:setPosition(0,display.top)
	end

	local _topRightNode = cc.uiloader:seekNodeByName(csbNode,"TopRightNode")
	if _topRightNode then
		fitScreenNode(_topRightNode)
		_topRightNode:setPosition(display.right,display.top)
	end

	local _topAniNode = cc.uiloader:seekNodeByName(csbNode,"AniTopNode")
	if _topAniNode then
		fitScreenNode(_topAniNode)
		_topAniNode:setPosition(display.cx,display.top)
	end

	local _aniBottomNode = cc.uiloader:seekNodeByName(csbNode,"AniBottomNode")
	if _aniBottomNode then
		fitScreenNode(_aniBottomNode)
		_aniBottomNode:setPosition(display.cx,display.bottom)
	end
end

function CsbContainer:createPushCsb( filename )
	local _node = cc.uiloader:load(filename)

	if _node then
		_node:setPosition(display.cx,display.cy)
		_node:setAnchorPoint(cc.p(0.5,0.5))
		fitScreenNode(_node)
	end
	return _node
end

function CsbContainer:createLoadingCsb( filename )
	local _node = cc.uiloader:load(filename)

	if _node then
		_node:setPosition(display.cx,display.cy)
		_node:setAnchorPoint(cc.p(0.5,0.5))
		if display.right>=720 then
			_node:setScale(display.right/1080)
		else 
			_node:setScale(display.top/1920)
		end
	end
	return _node
end

function CsbContainer:createMapCsb( filename )
	local _node = cc.uiloader:load(filename)

	if _node then
		local _leftTopNode = cc.uiloader:seekNodeByName(_node,"LeftTopNode")
		if _leftTopNode then
			fitMapNode(_leftTopNode)
			_leftTopNode:setPosition(0,display.top)
		end
		local _leftBottomNode = cc.uiloader:seekNodeByName(_node,"LeftBottomNode")
		if _leftBottomNode then
			fitMapNode(_leftBottomNode)
			_leftBottomNode:setPosition(0,0)
		end
		local _rightBottomNode = cc.uiloader:seekNodeByName(_node,"RightBottomNode")
		if _rightBottomNode then
			fitMapNode(_rightBottomNode)
			_rightBottomNode:setPosition(display.right,0)
		end
		local _bottomNode = cc.uiloader:seekNodeByName(_node,"BottomNode")
		if _bottomNode then
			fitMapNode(_bottomNode)
			_bottomNode:setPosition(display.cx,0)
		end
		local _rightTopNode = cc.uiloader:seekNodeByName(_node,"RightTopNode")
		if _rightTopNode then
			fitMapNode(_rightTopNode)
			_rightTopNode:setPosition(display.right,display.top)
		end
	end
	return _node
end

-- 修改当前btn的样子
function CsbContainer:refreshBtnView(btn,normalPic,selectedPic,disablePic)
	if normalPic then
		btn:loadTextureNormal(normalPic, 0) --替换正常显示的效果
	end
	if selectedPic then
		btn:loadTexturePressed(selectedPic, 0) --替换按下显示的效果
	end
	if disablePic then
		btn:loadTextureDisabled(disablePic, 0) --替换禁用的效果
	end
end

-- 装饰button
function CsbContainer:decorateBtn(btn,callBackFunc)
	btn:addTouchEventListener(function(sender,eventType)
        if eventType==ccui.TouchEventType.began then
        	if game.SoundOn==true then
	            audio.playSound(GAME_SOUND.tapButton)
	        end
	        btn:setScale(0.8)
        elseif eventType==ccui.TouchEventType.ended then
	        btn:setScale(1)
        	if callBackFunc then
	            callBackFunc()
	        end
        elseif eventType==ccui.TouchEventType.canceled then
	    	btn:setScale(1)
        end
    end)
end
-- 装饰button不带放大缩小
function CsbContainer:decorateBtnNoTrans(btn,callBackFunc)
	btn:addTouchEventListener(function(sender,eventType)
        if eventType==ccui.TouchEventType.began then
        	if game.SoundOn==true then
	            audio.playSound(GAME_SOUND.tapButton)
	        end
        elseif eventType==ccui.TouchEventType.ended then
        	if callBackFunc then
	            callBackFunc()
	        end
        end
    end)
end
-- 给node注册监听事件，当做button用
function CsbContainer:nodeToBtn( node,callBackFunc )
	node:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
        if event.name=="began" then
        	if game.SoundOn==true then
	            audio.playSound(GAME_SOUND.tapButton)
	        end
            return true
        elseif event.name=="ended" then
            if callBackFunc then
	            callBackFunc()
	        end
        end
    end)
end

-- 设置label显示文字
function CsbContainer:setStringForLabel(mainNode, labelMap)
	for name, str in pairs(labelMap) do
		local labelNode = cc.uiloader:seekNodeByName(mainNode,name)
		if labelNode then
			labelNode:setString(tostring(str))
		else
			print("CsbContainer:setStringForLabel no label ====>" .. name)
		end
	end
end

--设置nodes现隐
function CsbContainer:setNodesVisible(mainNode, visibleMap)
	for name, visible in pairs(visibleMap) do
		local node = cc.uiloader:seekNodeByName(mainNode,name)
		if node then
			node:setVisible(visible)
		end
	end
end

--设置sprite图片
function CsbContainer:setSpritesPic(mainNode, picMap)
	for spriteName, pic in pairs(picMap) do
		local spriteNode = cc.uiloader:seekNodeByName(mainNode,spriteName)
		if spriteNode then
			spriteNode:setTexture(pic)
		end
	end
end

--设置node颜色
function CsbContainer:setColorForNodes(mainNode, colorMap)
	for nodeName, color in pairs(colorMap) do
		local node = cc.uiloader:seekNodeByName(mainNode,nodeName)
		if node then
			node:setColor(color)
		end
	end
end

-- 设置button是否可用
function CsbContainer:setButtonEnabled(mainNode, ableMap)
	for nodeName, able in pairs(ableMap) do
		local node = cc.uiloader:seekNodeByName(mainNode,nodeName)
		if node then
			node:setEnabled(able)
		end
	end
end