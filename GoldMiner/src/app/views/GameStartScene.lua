
local GameStartScene = class("GameStartScene",cc.load("mvc").ViewBase)
local GlobalData = import(".GlobalData")
local ItemUtil = import(".ItemUtil")
local Hook = import(".Hook")
local Tool = import("..models.Tool")

function GameStartScene:onCreate() 
    
    --self.frameTime = 0.05   --每隔0.05s执行一次update
    self.hook = Hook:create():addTo(self)  --钩子
    self.hook:setPosition(self.hook.startPos_)
   
    self.miner = display.newSprite("pull.jpg")   --矿工
        :setPosition(484,430)
        :setVisible(false)
        :addTo(self)
       
    self.minerRun = false   --矿工动画是否正在播放
    
    --必须retain
    self.rope = cc.DrawNode:create():retain():addTo(self)    --绳索
      
    self.timer = 60         --倒计时 
    self.isGamePause = false   --暂停游戏
   
    display.newLayer():onTouch(handler(self,self.onTouch)):addTo(self)  --触屏监听
    display.newSprite("game_bg.jpg")   --添加背景图片精灵
        :setPosition(display.cx,display.cy)
        :addTo(self)
        :setLocalZOrder(-100)
    
    
    --添加暂停游戏按钮    
    local startSwitch = ccui.Button:create("switch_on.png")
        :setPosition(138,386)
        :scaleTo({time=0,scale=0.5})
        :addTo(self)

    local pauseSwitch = ccui.Button:create("switch_off.png")
        :setPosition(138,386)
        :scaleTo({time=0,scale=0.5})
        :setVisible(false)
        :addTo(self) 
        
    --当前状态为游戏进行状态,若点击则会切换到暂停状态
    startSwitch:addTouchEventListener(function(sender,eventType)
        if eventType == 2  then--and self.isGamePause == false then 
            
            startSwitch:setVisible(false)
            pauseSwitch:setVisible(true)
            self.isGamePause = true
            self:pause()
            --暂停移动物体的动画
            for _,item in ipairs(GlobalData.activeItems) do
                item:stopAllActions()
            end            
            
        end
    end    
    )
    
    --当前状态为暂停状态,若点击则会切换到游戏进行状态
    pauseSwitch:addTouchEventListener(function(sender,eventType)
        if eventType == 2 and self.isGamePause == true then 
            startSwitch:setVisible(true)
            pauseSwitch:setVisible(false)
            self.isGamePause = false
            self:start()
            --唤醒移动物体
            for _,item in ipairs(GlobalData.activeItems) do
                if item.active_state_ == 1 then
                    item:runAction(item:moveLeftAnimation())  --左移 
                else 
                    item:runAction(item:moveRightAnimation()) --右移 
                end
            end
        end 
    end
    )


    --添加闹钟
    self.clockSprite = display.newSprite("clock.png")
        :setPosition(225,388)
        :addTo(self)
    self.timeLab = cc.Label:createWithSystemFont("60","Arial",20)
        :setColor(cc.c3b(180,255,0))
        :setPosition(265,385)
        :addTo(self)
                
    --添加控制音乐播放按钮
    if GlobalData.isMusicPlaying == true then
        local playMusicBtn = ccui.Button:create("playMusicBtn_2.png")
        local stopMusicBtn = ccui.Button:create("stopMusicBtn_2.png")

        if GlobalData.isMusicPlaying == true then
            playMusicBtn:setVisible(false)
            stopMusicBtn:setVisible(true)
        else
            playMusicBtn:setVisible(true)
            stopMusicBtn:setVisible(false)
        end

        playMusicBtn:scaleTo({time=0,scale=0.2})
            :setPosition(display.right-50,display.top-80)
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

        stopMusicBtn:scaleTo({time=0,scale=0.2})
            :setPosition(display.right-50,display.top-80)
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
    end
    
    --显示当前关卡
    cc.Label:createWithSystemFont("第 " .. GlobalData.curLevel .. " 关","Arial",26)
        :setColor(cc.c3b(0,180,0))
        :setPosition(display.cx,display.top-15)
        :addTo(self)
        
    --我的金子
    self.myGoldLab = cc.Label:createWithSystemFont(GlobalData.totalMoney,"Arial",20)
        :setColor(cc.c3b(0,180,0))
        :setPosition(585,388)
        --:setAnchorPoint(0,0.5) 
        :addTo(self)
    --本关需要金子
    self.needGoldLab = cc.Label:createWithSystemFont(GlobalData.needMoneyPerLevel[GlobalData.curLevel],"Arial",20)
        :setColor(cc.c3b(200,0,200))
        :setPosition(694,388)
        :addTo(self)
    
    --添加物品
    self:addItems()
    
    self.rope:drawLine(GlobalData.ropeStart,
        cc.p(self.hook:getPositionX(),self.hook:getPositionY()),cc.c4f(0,0,0,100))
    

    cc.bind(self,"event")    --绑定touch事件
    self:start()          
    
end 


function GameStartScene:start()
    self:scheduleUpdate(handler(self,self.step))
end

function GameStartScene:pause()
    self:unscheduleUpdate()
    self.miner:stopAllActions()
    self.minerRun = false
end 

--function GameStartScene:step(dt)
    
--end

function GameStartScene:step(dt)
    
    self:timeRun(dt)
    
    --金钱部分
    self.myGoldLab:setString(GlobalData.totalMoney)
    
    --钩子部分
    if self.hook.runTarget_ == false and self.hook.runBack_ == false then
        self.hook:hookRun(dt) 
        if self.minerRun == true then 
            self.minerRun = false 
            self.miner:stopAllActions()
            self.miner:setVisible(false)
        end
        
    elseif self.hook.runTarget_ == true then
        self.hook:runTarget(dt)
        
        --抓到东西
        if self:checkCatchItem() == true then
            --print(self.hook.catchingItem_.type_)
            --是炸弹
            if self.hook.catchingItem_.bomb_ == true then
               -- self.hook.runTarget_ = false
               -- self.hook.runBack_ = false
                self.hook.catchingItem_:bomb()   --爆炸
                self.hook.catchingItem_ = nil
                
            else
                
                self.hook:catchItemAction()  --抓取瞬间动作           
                self.hook.speed_ = self.hook.speed_/self.hook.catchingItem_.weight_ --抓取速度与重量相关     
            end
                      
            self.hook.runTarget_ = false
            self.hook.runBack_ = true
        end
    else
        
        if self.minerRun == false and self.hook.catchingItem_ ~= nil and self.hook.catchingItem_.weight_>=10 then  
            self.minerRun = true 
            self.miner:setVisible(true)
            self.miner:runAction(self:minerAnimation()) 
        end
        self.hook:runBack(dt) 
    end 
    
    self:moveRope()
    
end


--移动绳索终点
function GameStartScene:moveRope()
    
    self.rope:clear()
   
    self.rope:drawLine(GlobalData.ropeStart,
        cc.p(self.hook:getPositionX(),self.hook:getPositionY()),cc.c4f(0,0,0,100))
end

--倒计时
function GameStartScene:timeRun(dt)
    
    local t1 = tonumber(string.format("%d",self.timer))
    self.timer = self.timer - dt 
    
    --时间到,判断是否通过关卡
    
    if self.timer < 0 then 
        --过关失败
        self:pause()
        GlobalData.activeItems = {}
        GlobalData.itemsArray = {}
        
        cc.Director:getInstance():getActionManager():removeAllActions() --释放所有的action
        display.removeUnusedSpriteFrames()     --释放纹理
        
        if GlobalData.totalMoney < GlobalData.needMoneyPerLevel[GlobalData.curLevel] then 
            self:getApp():enterScene("GameOverScene")
        else
            --还没通关
            if GlobalData.curLevel < GlobalData.maxLevel then
                audio.playSound("sound/cut-scene-2.mp3",false)
        
                self:getApp():enterScene("NextScene")
            else
                self:getApp():enterScene("GameCompletedScene") --通关
            end 
        end
        
    end
    
    local t2 = tonumber(string.format("%d",self.timer))
   
    if t2<t1 then
        if t2>=10 then
            self.timeLab:setString(t2)
        else
            self:removeChild(self.timeLab,true)
            self.timeLab = display.newSprite("number_color_" .. t2 .. ".png")
                :setPosition(265,385):addTo(self) 
        end
        
        --绳索回拉音效
        if self.hook.runBack_ == true and self.hook.catchingItem_ ~= nil then 
            if self.hook.catchingItem_.weight_ >=25 then
                audio.playSound("sound/pull.mp3",false)
            elseif self.hook.catchingItem_.weight_ >= 10 then
                audio.playSound("sound/pull-org.mp3",false)
            else end
              
        end
    end
    
    --判断活动物体是否走出视线，若是则调转方向返回
    for i,item in ipairs(GlobalData.activeItems) do
        if item ~= nil then
            local x = item:getPositionX()  

            if x<-50 and item.active_state_ == 1 then

                item.active_state_ = -1
                item:stopAllActions()
                item:runAction(item:moveRightAnimation())
            elseif x>display.width+50 and item.active_state_==-1 then

                item.active_state_ = 1
                item:stopAllActions()
                item:runAction(item:moveLeftAnimation())
            else
            end
        end
    end
    
end

function GameStartScene:onTouch(event)
    --钩子正在朝目标移动时触屏无效
    if event.name ~= "began" or self.hook.runTarget_ == true or self.hook.runBack_ == true then return end 
    self.hook.runTarget_ = true  --将钩子的runTarget_设为true,从而在setp(dt)中可调用hook:runTarget(dt)
    self.hook.backPos_ = cc.p(self.hook:getPositionX(),self.hook:getPositionY()) 
    --播放丢绳子的声音
    audio.playSound("sound/dig.mp3",false)
end

--添加道具
function GameStartScene:addItems()
    for _,v in ipairs(GlobalData.itemType) do 
        self:addItemWithNum(v,GlobalData.itemsNum[v][GlobalData.curLevel])
    end
    
    ItemUtil.alreadyAddItem = true  --添加完毕
end

function GameStartScene:addItemWithNum(type,num)
    --print(type,num)
    for i=1,num do
        local item = ItemUtil:create(type):addTo(self)
        
        if item.active_state_ == 1 then
            item:runAction(item:moveLeftAnimation())  --左移 
        elseif item.active_state_ == -1 then
            item:runAction(item:moveRightAnimation()) --右移 
        else
        end 
    end
end

--检查是否抓到物品
function GameStartScene:checkCatchItem()
    for i,item in ipairs(GlobalData.itemsArray) do
        if Tool.checkHit(item:getRect(),self.hook:getRect()) == true then
            
            table.remove(GlobalData.itemsArray,i) 
            self.hook.catchingItem_ = item 
            return true
        end
    end 
    return false
end

--矿工动画
function GameStartScene:minerAnimation()
    local action1 = cc.FadeTo:create(0.3,0)
    local action2 = cc.FadeTo:create(0.3,255)
    local action = cc.Sequence:create(action1,action2)
    return cc.RepeatForever:create(action)  
end

return GameStartScene   