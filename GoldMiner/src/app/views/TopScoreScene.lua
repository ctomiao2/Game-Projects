
local TopScoreScene = class("TopScoreScene",cc.load("mvc").ViewBase)
local GlobalData = import(".GlobalData")

function TopScoreScene:onCreate()
    display.removeUnusedSpriteFrames()     --释放上一场景的资源
    --if GlobalData.TopScoreLastScene == "GameCompletedScene" then
    audio.stopMusic(true)
    audio.playMusic("sound/tail_bgm.mp3",true)
    --end
    
    display.newSprite("hero_list.png")
        :setPosition(display.cx,display.cy)
        :addTo(self)
    
    --top10 
    local userDefault = cc.UserDefault:getInstance()
    
    local x,y = display.cx-240,display.cy+40
    for i=1,10 do 
        local name = userDefault:getStringForKey("name" .. i,"null") .. ":"
        local score = userDefault:getIntegerForKey("score" .. i,0)
        
        local nameLab = cc.Label:createWithSystemFont(name,"Arial",30)
            :setColor(cc.c3b(0,220,0))
            :setAnchorPoint(1,0.5) 
            :addTo(self)
            
        local scoreLab = cc.Label:createWithSystemFont(score,"Arial",30)
            :setColor(cc.c3b(220,0,0))
            :setAnchorPoint(0,0.55)
            :addTo(self)
            
        
        if i<=5 then
            nameLab:setPosition(x,y-40*(i-1))
            scoreLab:setPosition(x+10,y-40*(i-1))
        else
            nameLab:setPosition(x+500,y-40*(i-6))
            scoreLab:setPosition(x+510,y-40*(i-6))
        end
    end
    
    --返回按钮
    local backBtn = ccui.Button:create("game_back.png")
        :setPosition(display.cx, 50) 
        :addTo(self)

    backBtn:addTouchEventListener(function(sender,eventType)  
        if eventType == 2 then  
            audio.stopMusic(true)
            audio.playMusic("sound/bgm.mp3",true)
                      
            self:getApp():enterScene(GlobalData.TopScoreLastScene)
        end
    end
    )
    
end


return TopScoreScene