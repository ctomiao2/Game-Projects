
local MainMenu = class("MainMenu",cc.load("mvc").ViewBase)
local GlobalData = import(".GlobalData")

function MainMenu:onCreate()
    display.removeUnusedSpriteFrames()     --释放上一场景的资源
    --添加背景图片
    display.newSprite("menu_bg.jpg")
        :setPosition(display.center)
        :addTo(self)
    --添加三块金子
    
    local act1_1 = cc.FadeTo:create(2,255)
    local act1_2 = cc.FadeTo:create(2,0)
    local act1_3 = cc.FadeTo:create(2,255)
    local act1_4 = cc.FadeTo:create(2,0)
    local act1_5 = cc.FadeTo:create(2,255)
    
    local actions1 = cc.Sequence:create(act1_1,act1_2,act1_3,act1_4,act1_5)
    
    
    display.newSprite("mine_gold_b_1.png")
        :setPosition(display.cx-115,display.cy-100)
        :addTo(self)
        :runAction(cc.RepeatForever:create(actions1))
    
    local act2_1 = cc.FadeTo:create(2,0)
    local act2_2 = cc.FadeTo:create(2,255)
    local act2_3 = cc.FadeTo:create(2,0)
    local act2_4 = cc.FadeTo:create(2,255)
    local act2_5 = cc.FadeTo:create(2,0)
    local act2_6 = cc.FadeTo:create(2,255)
    
    local actions2 = cc.Sequence:create(act2_1,act2_2,act2_3,act2_4,act2_5,act2_6)
         
    display.newSprite("mine_gold_b_2.png")
        :setPosition(display.cx-5,display.cy-100)
        :addTo(self)
        :runAction(cc.RepeatForever:create(actions2))
    
    
    local act3_1 = cc.FadeTo:create(2,255)
    local act3_2 = cc.FadeTo:create(2,0) 
    local act3_3 = cc.FadeTo:create(2,255)
    local act3_4 = cc.FadeTo:create(2,0)
    local act3_5 = cc.FadeTo:create(2,255)
    
    local actions3 = cc.Sequence:create(act3_1,act3_2,act3_3,act3_4,act3_5)
       
    display.newSprite("mine_gold_b_3.png")
        :setPosition(display.cx+105,display.cy-100)
        :addTo(self)
        :runAction(cc.RepeatForever:create(actions3))
    
    ------------------------ 英雄榜 ------------------------------
    
    local topScoreBtn = ccui.Button:create("top_table.png")
        :setPosition(display.left+120,display.cy+90)
        :addTo(self) 
    
    topScoreBtn:addTouchEventListener(function(sender,eventType)
        if eventType == 2 then
            GlobalData.TopScoreLastScene = "MainMenu"
            self:getApp():enterScene("TopScoreScene")
        end
    end
    )
    --开始游戏按钮
    local startGameBtn = ccui.Button:create("gameStart.png")
        :setPosition(display.right-100,display.cy+120)
        :scaleTo({time=0,scale=0.4})
        :addTo(self)
    local exitGameBtn = ccui.Button:create("gameExit.png")
        :setPosition(display.right-100,display.cy+20)
        :scaleTo({time=0,scale=0.4})
        :addTo(self)
    local gameAboutBtn = ccui.Button:create("gameAbout.png")
        :setPosition(display.right-100,display.cy-80) 
        :scaleTo({time=0,scale=0.4})
        :addTo(self)
   
    --关于按钮监听事件
    gameAboutBtn:addTouchEventListener(function(sender,eventType)
        if eventType == 2 then   
            GlobalData.AboutLastScene = "MainMenu"       
            self:getApp():enterScene("AboutScene")
        end 
    end
    ) 
    
    --退出游戏
    exitGameBtn:addTouchEventListener(function(sender,eventType) 
        if eventType == 2 then
             self:getApp():exit()
        end
    end
    )
    
    --开始游戏
    startGameBtn:addTouchEventListener(function(sender,eventType)
        if eventType == 2 then 
            self:unscheduleUpdate()
            cc.Director:getInstance():getActionManager():removeAllActions() --释放所有的action
            --audio.playSound("sound/cut-scene-2.mp3",false)
            self:getApp():enterScene("GameStartScene")
            
        end
    end
    )
    
    --cc.FileUtils:getInstance():addSearchPath("res/")
    GlobalData.isMusicPlaying = true
    local playMusicBtn = ccui.Button:create("playMusicBtn.png")
    local stopMusicBtn = ccui.Button:create("stopMusicBtn.png")
    
    playMusicBtn:scaleTo({time=0,scale=0.28})
        :setPosition(display.right-100,display.cy-180)
        :setVisible(false)
        :addTo(self)
        
    playMusicBtn:addTouchEventListener(function(sender,eventType)
            if eventType == 2 and GlobalData.isMusicPlaying == false then
                playMusicBtn:setVisible(false)
                stopMusicBtn:setVisible(true)
                cc.SimpleAudioEngine:getInstance():resumeMusic()
                GlobalData.isMusicPlaying = true
            end
        end
        )      
              
    
    stopMusicBtn:scaleTo({time=0,scale=0.28})
        :setPosition(display.right-100,display.cy-180)
        :addTo(self)
        
    stopMusicBtn:addTouchEventListener(function(sender,eventType)
        if eventType == 2 and GlobalData.isMusicPlaying == true then 
            playMusicBtn:setVisible(true)
            stopMusicBtn:setVisible(false)
            cc.SimpleAudioEngine:getInstance():pauseMusic()
            GlobalData.isMusicPlaying = false
        end      
    end 
    )
    
    self.mouse = display.newSprite("mouse3.png"):setPosition(20,50):addTo(self) 
    self.direct_ = -1    --  1为左，-1为右      
    self.mouse:runAction(self:MainMoveRightAnimation())
    self:scheduleUpdate(handler(self,self.step))     
             
end  

function MainMenu:step(dt)
    if self.mouse:getPositionX()<-50 and self.direct_ == 1 then
        self.mouse:stopAllActions()
        self.mouse:runAction(self:MainMoveRightAnimation())
        self.direct_ = -1
    elseif self.mouse:getPositionX()>display.width+50 and self.direct_ == -1 then
        self.mouse:stopAllActions() 
        self.mouse:runAction(self:MainMoveLeftAnimation())
        self.direct_ = 1
    else end
end

function MainMenu:MainMoveLeftAnimation()
    local frameCache = {}
    local rect_ = cc.Sprite:create("mouse1.png"):getTextureRect()

    frameCache[1] = cc.SpriteFrame:create("mouse1.png",rect_)
    frameCache[2] = cc.SpriteFrame:create("mouse2.png",rect_)
    local animation = cc.Animation:createWithSpriteFrames(frameCache,0.2,1)
    local moveLeft = cc.MoveBy:create(0.4,cc.p(-15,0))
    local animate = cc.Animate:create(animation)
    local action = cc.Spawn:create(moveLeft,animate)
    return cc.RepeatForever:create(action)
end

function MainMenu:MainMoveRightAnimation()
    local frameCache = {}
    local rect_ = cc.Sprite:create("mouse3.png"):getTextureRect()
    
    frameCache[1] = cc.SpriteFrame:create("mouse3.png",rect_)
    frameCache[2] = cc.SpriteFrame:create("mouse4.png",rect_)
    local animation = cc.Animation:createWithSpriteFrames(frameCache,0.2,1)
    local moveRight = cc.MoveBy:create(0.4,cc.p(15,0))
    local animate = cc.Animate:create(animation)
    local action = cc.Spawn:create(moveRight,animate)
    return cc.RepeatForever:create(action)
end

return MainMenu