 
local Hook = class("Hook",cc.load("mvc").ViewBase)
local GlobalData = import(".GlobalData")

function Hook:onCreate()
    
    self.sprite1_ = display.newSprite("hook_1.png")
        :setAnchorPoint(0.5,1)
        :addTo(self)
        :setGlobalZOrder(9999)
       -- :setVisible(false) 
        
    self.sprite2_ = display.newSprite("hook_2.png")
        :setAnchorPoint(0.5,0.5)
        :addTo(self)
        :setVisible(false)
        :setGlobalZOrder(9999)
        
    self.sprite3_ = display.newSprite("hook_3.png")
        :setAnchorPoint(0.9,0.5)
        :addTo(self)
        :setVisible(false) 
        :setGlobalZOrder(9999)
    
    local texture = display.loadImage("hook_1.png") 

        
    self.frameWidth = texture:getPixelsWide()
    self.frameHeight = texture:getPixelsHigh()
    
    self.startPos_ = cc.p(427,310)   --起点
    self.backPos_ = self.startPos_   --调用runBack时的返回点
    self.itemPos_ = cc.p(427,390)    --存放物品的位置
    self.direction_ = 1  --当前摆动方向,1为左,-1为右
    self.rotation_ = 0    --与竖直线的夹角 
    self.maxRotation_ = 72  --最大摆动幅度  
    self.period_ = 1   --1/4摆动周期
    self.runTarget_ = false   --是否正在朝目标移动
    self.runBack_ = false    --是否正在返回
    self.speed_ = 500  --400像素/秒
    self.catchingItem_ = nil   --当前抓取的物品 
end

function Hook:getRect()
    local Rect_1 = {}
    local rot = self:getRotation()/180 * math.pi 
    local x = self:getPositionX()
    local y = self:getPositionY() 
    local w = self.frameWidth - 10
   
    Rect_1[1] = cc.p(x - math.cos(rot)*w/2, y + math.sin(rot)*w/2)
    Rect_1[2] = cc.p(x + math.cos(rot)*w/2, y - math.sin(rot)*w/2) 
    Rect_1[3] = cc.p(Rect_1[2].x - math.sin(rot)*self.frameHeight, Rect_1[2].y - math.cos(rot)*self.frameHeight)
    Rect_1[4] = cc.p(Rect_1[1].x - math.sin(rot)*self.frameHeight, Rect_1[1].y - math.cos(rot)*self.frameHeight)
    
    return Rect_1
end


--左右摆动钩子
function Hook:hookRun(dt)
    local preRot = self.rotation_  --钩子上一次的角度   
    local delta = self.direction_ * self.maxRotation_ * dt/self.period_   --dt秒内摆动的度数 

    if preRot+delta < -self.maxRotation_ then  --摆动到了最右
        self.direction_ = 1
        delta = -delta
    elseif preRot+delta > self.maxRotation_ then  --摆动到了最左
        self.direction_ = -1
        delta = -delta
    else

    end

    self.rotation_ = preRot + delta

    local r = GlobalData.initRopeLen

    local dx = r*(math.sin(preRot/180 * math.pi) - math.sin(self.rotation_/180 * math.pi))
    local dy = r*(math.cos(preRot/180 * math.pi) - math.cos(self.rotation_/180 * math.pi))

    self:setRotation(self.rotation_)
    self:move(cc.p(self:getPositionX()+dx,self:getPositionY()+dy))
    
end

--向目标移动
function Hook:runTarget(dt)
    local dx = -self.speed_ * dt * math.sin(self.rotation_/180 * math.pi)
    local dy = -self.speed_ * dt * math.cos(self.rotation_/180 * math.pi)
    local x,y = self:getPositionX()+dx,self:getPositionY()+dy
    
    if x<0 or x>860 or y<0 then
        self.runTarget_ = false
        self.runBack_ = true
    else
        self:move(x,y)
    end 
end

--返回起点
function Hook:runBack(dt)

    local dx = self.speed_ * dt * math.sin(self.rotation_/180 * math.pi)
    local dy = self.speed_ * dt * math.cos(self.rotation_/180 * math.pi)
    local x,y = self:getPositionX()+dx,self:getPositionY()+dy
    
    if y >= self.backPos_.y then
        
        self.sprite1_:setVisible(true)
        self.sprite2_:setVisible(false)
        self.sprite3_:setVisible(false)
        
        if self.catchingItem_ ~= nil then            
                
            if self.catchingItem_.value_>=500 then   --高分
                audio.playSound("sound/high-value.mp3",false)
            elseif self.catchingItem_.value_>=200 then  
                audio.playSound("sound/score1.mp3",false)
            elseif self.catchingItem_.value_>=100 then
                audio.playSound("sound/score2.mp3",false)
            elseif self.catchingItem_.value_>=50 then    
                audio.playSound("sound/normal-value.mp3",false)
            else
                audio.playSound("sound/low-value.mp3",false)
            end
            
            GlobalData.totalMoney = GlobalData.totalMoney + self.catchingItem_.value_
            
            self.catchingItem_:move(self.itemPos_) 
                :scaleTo({time=0.5,scale=1.3})
                :fadeOut({time=0.7,removeSelf = true})  
                       
            self:scoreAction()
            self.catchingItem_ = nil   
            
        end
        
        self.direction_ = 1  
        self.rotation_ = 0    
        self.runBack_ = false
        self.speed_ = 500
        self.backPos_ = self.startPos_
        self:setPosition(self.startPos_)
        self:setRotation(0)
   
    else
        if self.catchingItem_ ~= nil then
            local x1 = self.catchingItem_:getPositionX() + dx 
            local y1 = self.catchingItem_:getPositionY() + dy  
            self.catchingItem_:move(x1,y1) 
        end
        self:move(x,y)
    end 
end

--抓取物品瞬间的动作
function Hook:catchItemAction()
    --若是移动物体
    if self.catchingItem_.active_state_ ~= 0 then
        self.catchingItem_.active_state_ = 0
        
        self.catchingItem_:cleanup()   --停止所有的动画
        --将移动物体从移动列表中移除
        for i,v in ipairs(GlobalData.activeItems) do
            if self.catchingItem_ == v then
                print("remove mouse")
                table.remove(GlobalData.activeItems,i)
                break
            end
        end
    end
    
    --self.sprite1_:setVisible(false)
    if GlobalData.itemsSize[self.catchingItem_.type_][self.catchingItem_.size_][1] > 60 then 
        self.sprite1_:setVisible(false)
        self.sprite3_:setVisible(true)      
    end
    
    local x,y = self:getPositionX(),self:getPositionY()
    local d = self:getRotation()/180 * math.pi
    local dx = -self.frameHeight * math.sin(d) 
    local dy = -self.frameHeight * math.cos(d) 
    
    self.catchingItem_:move(x+dx,y+dy) 
    
end 

--得分动画
function Hook:scoreAction()
   
    local textLabel = cc.Label:createWithSystemFont(text,"Arial",50)
   
    textLabel:setPosition(620,388)
    textLabel:setColor(cc.c3b(0,180,0))

    textLabel:setString(self.catchingItem_.value_)

    local scaleLarge = cc.ScaleTo:create(0.2,2.5,2.5)
    local scaleSmall = cc.ScaleTo:create(0.3,0.5,0.5)
    local actions = cc.Sequence:create(scaleLarge,scaleSmall,cc.CallFunc:create(function()
        textLabel:fadeTo({time=0.3,removeSelf=true})
    end) 
    )

    textLabel:runAction(actions) 
    cc.Director:getInstance():getRunningScene():addChild(textLabel)
end 


return Hook