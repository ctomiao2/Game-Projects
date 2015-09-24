
local AboutScene = class("AboutScene",cc.load("mvc").ViewBase)
local GlobalData = import(".GlobalData")

function AboutScene:onCreate()

    --if GlobalData.AboutLastScene == "GameCompletedScene" then
    audio.stopMusic(true)
    audio.playMusic("sound/tail_bgm.mp3",true)
    --end
    
    display.newSprite("about_scene.png")
        :setPosition(display.cx,display.cy)
        :addTo(self)
    local backBtn = ccui.Button:create("backarrow.png")
        :setPosition(display.right-60,display.cy-200)
        :addTo(self)
    
    backBtn:addTouchEventListener(function(sender,eventType)
        if eventType == 2 then
            audio.stopMusic(true)
            audio.playMusic("sound/bgm.mp3",true)
            
            self:getApp():enterScene(GlobalData.AboutLastScene)         
        end
    end
    )   
end

return AboutScene