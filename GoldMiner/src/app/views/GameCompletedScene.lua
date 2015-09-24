
local GameCompletedScene = class("GameCompletedScene",cc.load("mvc").ViewBase)
local GlobalData = import(".GlobalData")

function GameCompletedScene:onCreate()
    display.removeUnusedSpriteFrames()     --释放上一场景的资源
    display.newSprite("cut_scene.png")
        :setPosition(display.cx,display.cy)
        :addTo(self)
    display.newSprite("game_completed.png")
        :setPosition(display.cx,display.cy)
        :addTo(self)
    
    
    ------------------------ 英雄榜 ------------------------------

    local topScoreBtn = ccui.Button:create("top_table.png")
        :setPosition(display.left+120,display.cy+90)
        :addTo(self) 

    topScoreBtn:addTouchEventListener(function(sender,eventType)
        if eventType == 2 then
            GlobalData.TopScoreLastScene = "GameCompletedScene"
            self:getApp():enterScene("TopScoreScene")
        end
    end
    )

    ------------------------ 桃花源------------------------------

    local topScoreBtn = ccui.Button:create("about_table.png")
        :setPosition(display.right-120,display.cy+90)
        :addTo(self) 

    topScoreBtn:addTouchEventListener(function(sender,eventType)
        if eventType == 2 then
            GlobalData.AboutLastScene = "GameCompletedScene"
            self:getApp():enterScene("AboutScene")
        end
    end
    )


    self.textField = nil   --文本框
    local haveInputName = false  
    
    local backBtn = ccui.Button:create("game_back.png")
        :setPosition(display.cx, 100) 
        :addTo(self)
        
           
    -- 不能连着写监听事件,否则会有非常坑爹的bug!!!!
    backBtn:addTouchEventListener(function(sender,eventType)  
            if eventType == 2 then             
                self:restart()
            end
        end
        )
    --第一次按下弹出文本框，第二次按下保存输入内容并退出视野
    
    if GlobalData.yourName == "" then
        backBtn:setVisible(false)
    self.inputNameBtn = ccui.Button:create("save_your_name.png")
        :setPosition(display.cx,100) 
        :addTo(self)
               
    self.inputNameBtn:addTouchEventListener(function(sender,eventType)  
        if eventType == 2 then 
            --还没输入，按此按钮则跳出输入框          
            if haveInputName == false then 
                self:inputYourName()
                haveInputName = true 
                
            --输完名字后，再按就保存 ，同时使输入框、该按钮消失     
            else
                GlobalData.yourName = self:checkName(self.textField:getText())
                if GlobalData.yourName ~= "" then

                    ------------------检查是否更新top10榜单-------------------------
                    --获取top10榜单
                    local topScore = {}
                    local userDefault = cc.UserDefault:getInstance()
                    for i=1,10 do
                        topScore[i] = {} 
                        topScore[i].name = userDefault:getStringForKey("name" .. i,"null")
                        topScore[i].score = userDefault:getIntegerForKey("score" .. i,0)
                    end
                    --查找插入位置
                    local pos = 11
                    for i=10,1,-1 do
                        if i==1 then pos = 1 break end
                        if GlobalData.totalMoney>topScore[i].score and 
                            GlobalData.totalMoney<=topScore[i-1].score then
                            pos = i
                            break
                        end
                    end

                    for i=10,pos+1,-1 do
                        userDefault:setStringForKey("name" .. i,topScore[i-1].name)
                        userDefault:setIntegerForKey("score" .. i,topScore[i-1].score)
                    end
                    if pos <= 10 then
                        userDefault:setStringForKey("name" .. pos,GlobalData.yourName)
                        userDefault:setIntegerForKey("score" .. pos,GlobalData.totalMoney) 
                    end
                    ---------------------------更新完毕-----------------------------------

                    --提示成功保存            
                    local savedLab = cc.Label:createWithSystemFont("保存成功！","Arial",30)
                        :setPosition(display.cx + 10,display.cy+100)
                        :setColor(cc.c3b(180,0,0))
                        :addTo(self)
                        :fadeTo({time=2,removeSelf = true})
                           
                end
                                                
                self:removeChild(self.textField,true)            --移除输入框  
                self:removeChild(self.inputNameBtn,true)         --移除输入名字按钮
                backBtn:setVisible(true)                         --重现返回按钮
               
            end
        end
    end    
    )
  end  
end

function GameCompletedScene:inputYourName()
    local res = ""
    local inputBg = ccui.Scale9Sprite:create("input_name_box.png") 
    self.textField = ccui.EditBox:create(cc.size(480,125),inputBg,inputBg,inputBg)
        :setPosition(display.cx+10,display.top - 130)
        :setFont("Arial",24)
        :setPlaceHolder("  输完按换行键再按保存,或直接按保存退出:")
        :setFocused(true)
        :addTo(self)
    
    self.textField:registerScriptEditBoxHandler(function(eventType)
            if eventType == "ended" then  
                local txt = self.textField:getText()
                if self:checkName(txt) ~= "" then 
                    self.textField:setText("  " .. txt) 
                        :setFontColor(cc.c3b(180,0,0)) 
                        :setColor(cc.c3b(0,220,0))
                end
            end
        end
        )
        
end

--回到游戏主界面
function GameCompletedScene:restart()
    GlobalData.yourName = ""
    GlobalData.isMusicPlaying = true
    GlobalData.totalMoney = 0   --当前金钱
    GlobalData.curLevel = 1     --当前关卡
    GlobalData.itemsArray = {}
    GlobalData.activeItems = {}        --活动的东西
    self:getApp():enterScene("MainMenu")
end

function GameCompletedScene:checkName(name)
    local n = string.len(name)
    local s,e = 1,n

    while string.sub(name,s,s) == " " do
        s = s+1
    end

    while string.sub(name,e,e) == " " do
        e = e+1
    end

    if e<s then return "" end
    e = math.min(s+9,e)   --截取前10位
    return string.sub(name,s,e)

end

return GameCompletedScene
