----------------------------------------------------------------------------------
--[[
    FILE:           GameUtil.lua
    DESCRIPTION:    游戏工具
    AUTHOR:         ZhaoLu
    CREATED:        2016-06-08
--]]
----------------------------------------------------------------------------------
local _time = 0
local scheduler = require("framework.scheduler")

function gridToPoint(row,col)
	-- body
	return cc.p((col - 1) * game.CELL_WIDTH + game.CELL_WIDTH * 0.5 , (row - 1) * game.CELL_HEIGHT + game.CELL_HEIGHT * 0.5)	
end

function fitScreenNode( node )
	if display.right>=1080 then
		node:setScale(1.4)
    elseif display.right <750 then
        node:setScale(display.top/1334)
	end
end

function fitScreenSize( size )
    local _size = size
    if display.right>=1080 then
        _size.width = size.width*1.6
        _size.height = size.height*1.6
    elseif display.right <750 then
        _size.width = size.width*(display.top/1334)
        _size.height = size.height*(display.top/1334)
    end
    return _size
end

function fitMapNode( node )
    node:setScale(display.right/750)
end

function GameUtil_addSecond()
    scheduler.scheduleGlobal(function()
        if game.count50EnergyTime>0 then
            game.count50EnergyTime= game.count50EnergyTime-1
        end

        if game.countTime>0 then
            game.countTime=game.countTime-1
            -- print("GameUtil_addSecond"..game.countTime)
            if game.countTime%game.addOneEnergyTime==0 then
                if game.myEnergy<50 then
                    game.myEnergy=game.myEnergy+1
                    sendMessage({msg="BuyEnergyView_refreshTime"})
                    sendMessage({msg="Refresh_Energy"})
                    -- print("GameUtil_addEnergy"..game.myEnergy)
                    -- 记录时间和体力
                    UserDefaultUtil:SaveEnergy()
                end
            end
        end
    end,1)
end

function GameUtil_getShipCfg()
    if game.nowShip == 1 then
        return require("data.data_ship1")
    elseif game.nowShip == 2 then
        return require("data.data_ship2")
    end
end

function GameUtil_resetMusic()
    UserDefaultUtil:saveMusic()
    if game.MusicOn==true then
        audio.playMusic(GAME_MUSIC.bgMusic,true)
    else
        audio.stopMusic()
    end
end
