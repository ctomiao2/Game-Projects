
local NextScene = class("NextScene",cc.load("mvc").ViewBase)
local GlobalData = import(".GlobalData")

function NextScene:onCreate()
   -- display.removeUnusedSpriteFrames()   --释放纹理资源
    display.newSprite("cut_scene.png")
        :setPosition(display.cx,display.cy)
        :addTo(self)
    local nextBtn = ccui.Button:create("next_2.png")
        :setPosition(display.cx,display.cy)
        :addTo(self)
    
    local haveEnter = false 
    nextBtn:addTouchEventListener(function(sender,eventType)
        if eventType == 2 and haveEnter == false then 
            GlobalData.curLevel = GlobalData.curLevel + 1
            haveEnter = true
            audio.stopAllSounds()
         --   audio.playSound("sound/cut-scene-2.mp3",false)
            self:getApp():enterScene("GameStartScene")     --进入下一关卡      
        end
    end
    )   
end

return NextScene
