
local ItemUtil = class("ItemUtil",function()
    return cc.Sprite:create() end
)
local GlobalData = import(".GlobalData")
local Tool = import("..models.Tool")

function ItemUtil:ctor(itemType)
    --print(itemType)
    self.type_ = itemType
    self.size_ = math.random(1,3)
    self.value_ = GlobalData.itemsValue[self.type_][self.size_] 
    self.weight_ = GlobalData.itemsWeight[self.type_][self.size_]
    self.sprite_ = ""
    self.sprite1_ = ""
    self.sprite2_ = ""
    self.sprite3_ = ""
    self.sprite4_ = ""
    
    self.bomb_ = false   --是否会爆炸 
    self.active_state_ = 0  --活动状态,-1为初始右移，1为初始左移,0则不动
    
    ItemUtil.alreadyAddItem = false  --是否添加物品完毕 
    
    local px = math.random(50,780)
    local py = 0
    
    --检测是否与已经存在的物品发生碰撞,如果OK则返回true
    local function check(Rect_1)
        if #GlobalData.itemsArray == 0 then return true end
        --local Rect_1 = self:getRect()
        for i=1,#GlobalData.itemsArray do
            --碰撞检测不考虑老鼠
            if GlobalData.itemsArray[i].active_state_ == 0 and
                Tool.checkAlignHit(Rect_1,GlobalData.itemsArray[i]:getRect()) == true then 
                return false
            end 
        end
       
        return true  
    end  
    
    --设置精灵
    if itemType == "diamond" then
        self.sprite_ = "mine_diamond_" .. math.random(1,4) .. ".png"
        py = math.random(20,80)
        self:setPosition(px,py) 
        while check(self:getRect()) == false do
            px = math.random(50,780)
            py = math.random(20,80)
            self:setPosition(px,py) 
        end
        
    elseif itemType == "gold" then
        if self.size_ == 1 then
            self.sprite_ = "mine_gold_b_"
            py = math.random(20,110)
            self:setPosition(px,py) 
            while check(self:getRect()) == false do
                px = math.random(50,780)
                py = math.random(20,110)
                self:setPosition(px,py) 
            end
            
        elseif self.size_ == 2 then
            self.sprite_ = "mine_gold_m_"
            py = math.random(20,150)
            self:setPosition(px,py) 
            while check(self:getRect()) == false do
                px = math.random(50,780)
                py = math.random(20,150)
                self:setPosition(px,py) 
            end
            
        else 
            self.sprite_ = "mine_gold_s_"
            py = math.random(20,200)
            self:setPosition(px,py) 
            while check(self:getRect()) == false do
                px = math.random(50,780)
                py = math.random(20,200)
                self:setPosition(px,py) 
            end
            
        end
        
        self.sprite_ = self.sprite_ .. math.random(1,4) .. ".png"
        
    elseif itemType == "rock" then
        if self.size_ == 1 then 
            self.sprite_ = "mine_rock_b.png"
        elseif self.size_ == 2 then
            self.sprite_ = "mine_rock_m.png"
        else 
            self.sprite_ = "mine_rock_s.png"
        end
        
        py = math.random(50,250)
        self:setPosition(px,py) 
        while check(self:getRect()) == false do
            px = math.random(50,780)
            py = math.random(50,250)
            self:setPosition(px,py) 
        end
        
    elseif itemType == "mine_package" then
        self.sprite_ = "mine_package.png"
        local v = math.random(1,10)       
        self.value_ = 10*v*v
        py = math.random(20,70)
        self:setPosition(px,py) 
        while check(self:getRect()) == false do
            px = math.random(50,780)
            py = math.random(20,70)
            self:setPosition(px,py) 
        end
        
    elseif itemType == "mouse" or itemType == "mouse_tnt" then 
        local v = 2*math.random(1,2) - 1
        self.sprite_ = itemType .. v .. ".png"
        py = math.random(120,240)
        self:setPosition(px,py) 
       --[[                   --老鼠不需要碰撞检测
        while check(self:getRect()) == false do
            px = math.random(50,780)
            py = math.random(120,240)
            self:setPosition(px,py) 
        end
        ]]
        self.sprite1_ = itemType .. "1.png"
        self.sprite2_ = itemType .. "2.png"
        self.sprite3_ = itemType .. "3.png"
        self.sprite4_ = itemType .. "4.png"
        
        if v == 1 then        
            self.active_state_ = 1  --初始向左移动
        else
            self.active_state_ = -1 --初始向右移动
        end
            
        if itemType == "mouse_tnt" then 
            self.bomb_ = true   --会爆炸
            self.bomb_range_ = 75  --爆炸范围
        end
        
    else
        self.sprite_ = "mine_tnt.png"
        py = math.random(20,150)
        self:setPosition(px,py) 
        while check(self:getRect()) == false do
            px = math.random(50,780)
            py = math.random(20,150)
            self:setPosition(px,py) 
        end
        self.bomb_ = true
        self.bomb_range_ = 110
    end
    
    if self.active_state_ ~= 0 then  
        table.insert(GlobalData.activeItems,self)  --活动物体列表
    end
    
    table.insert(GlobalData.itemsArray,self)
    
    --创建精灵
    self:onCreate()   
     
end

function ItemUtil:onCreate()
    local rect_ = cc.Sprite:create(self.sprite_):getTextureRect()
    self:setSpriteFrame(cc.SpriteFrame:create(self.sprite_,rect_)) --创建精灵
    
end

--获取物品的碰撞区域
function ItemUtil:getRect()
    local Rect_1 = {}
    local x,y = self:getPositionX(),self:getPositionY() 
    
    local w1 = GlobalData.itemsSize[self.type_][self.size_][1]
    local h1 = GlobalData.itemsSize[self.type_][self.size_][2]
    
    if ItemUtil.alreadyAddItem == false then    --添加物品时，物品之间保持一定的距离
        w1 = w1 + 15
        h1 = h1 + 15
    end 
    
    Rect_1[1] = cc.p(x - w1/2, y + h1/2) 
    Rect_1[2] = cc.p(x + w1/2, y + h1/2)
    Rect_1[3] = cc.p(x + w1/2, y - h1/2)
    Rect_1[4] = cc.p(x - w1/2,y - h1/2)
    
    return Rect_1
end

function ItemUtil:bomb()
    
    --print("bomb!!!")
    if self.bomb_ == false then return end
    
    self:setVisible(false)  
    self:createBombAnimation()
    
    local x,y = self:getPositionX(),self:getPositionY()
    local bombCircle = { x, y, self.bomb_range_}   --圆心坐标、半径
        
    local bomb_table = {}  --炸弹的爆炸区域范围内可能还有其他的炸弹
    for i,item in ipairs(GlobalData.itemsArray) do
        if Tool.checkCircleHit(bombCircle,item:getRect())==true then 
            --若是活动物体，则先将其从活动物体列表中移除
            if item.active_state_ ~= 0 then
                --暂停活动物体的动作
                item:stopAllActions() 
                for i,v in ipairs(GlobalData.activeItems) do 
                    if item == v then
                        table.remove(GlobalData.activeItems,i)
                        break
                     end
                end
                --如果不是炸弹，则使之从视野消失，若是炸弹则再当前炸弹爆炸结束后再让它爆炸
                if item.bomb_ == false then item:fadeTo({time=0,removeSelf=true}) end
            end 
            
            if item.bomb_ == true and item ~= self then 
                bomb_table[#bomb_table+1] = item  --先不消失，待当前炸弹爆炸结束后再使之爆炸
            else    
                item:fadeTo({time=0,removeSelf=true})  --炸弹本身，以及其他既不是活物也不是炸弹的物品
            end    
                    
            table.remove(GlobalData.itemsArray,i)  --不管是活物还是炸弹或都不是，都要从当前物品缓存中移除
            --其他炸弹也爆炸
            for _,item in ipairs(bomb_table) do item:bomb() end
        end
    end
    
end

--创建爆炸动画
function ItemUtil:createBombAnimation() 
    --爆炸音效
    audio.stopAllSounds() 
    audio.playSound("sound/explosive.mp3",false) 
    for i=1,5 do
        display.newSprite("effect_blast_" .. i .. ".png")
            :setPosition(self:getPositionX(),self:getPositionY())
            :addTo(cc.Director:getInstance():getRunningScene())
            :fadeOut({time=0.5,removeSelf=true})           
    end
       
end

function ItemUtil:moveLeftAnimation()  

    if self.active_state_ == 0 then return end
    
    local frameCache = {}
    local rect_ = cc.Sprite:create(self.sprite1_):getTextureRect()
   
    frameCache[1] = cc.SpriteFrame:create(self.sprite1_,rect_)  
    frameCache[2] = cc.SpriteFrame:create(self.sprite2_,rect_)
    local animation = cc.Animation:createWithSpriteFrames(frameCache,0.1,1)
    local moveLeft = cc.MoveBy:create(0.2,cc.p(-8,0))
    local animate = cc.Animate:create(animation) 
    local action = cc.RepeatForever:create(cc.Spawn:create(moveLeft,animate))
    return action
    
end

function ItemUtil:moveRightAnimation()
    if self.active_state_ == 0 then return end
    
    local frameCache = {}
    local rect_ = cc.Sprite:create(self.sprite3_):getTextureRect()
    
    frameCache[1] = cc.SpriteFrame:create(self.sprite3_,cc.rect(0,0,rect_.width,rect_.height)) 
    frameCache[2] = cc.SpriteFrame:create(self.sprite4_,cc.rect(0,0,rect_.width,rect_.height))
    local animation = cc.Animation:createWithSpriteFrames(frameCache,0.1,1)
    local moveRight = cc.MoveBy:create(0.2,cc.p(8,0))
    local animate = cc.Animate:create(animation)
    local action = cc.RepeatForever:create(cc.Spawn:create(moveRight,animate))
    return action
 
end   
return ItemUtil  