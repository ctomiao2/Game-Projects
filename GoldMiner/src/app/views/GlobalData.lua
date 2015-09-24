
local GlobalData = class("GlobalData")

GlobalData.TopScoreLastScene = ""  --在切换英雄榜场景用到
GlobalData.AboutLastScene = ""  --在切换关于场景用到

GlobalData.yourName = ""
GlobalData.isMusicPlaying = true
GlobalData.totalMoney = 0   --当前金钱
GlobalData.curLevel = 1     --当前关卡
GlobalData.itemsArray = {}
GlobalData.activeItems = {}        --活动的东西

GlobalData.initRopeLen = 77  --绳索初始长度
GlobalData.ropeStart = cc.p(427,387)   --绳索起点
GlobalData.itemType = { "diamond","gold","rock","mouse","mouse_tnt","mine_package","mine_tnt" }
GlobalData.needMoneyPerLevel = {650,1480,2500,3700,6000,7500,9200,12000,15000,20000} 
GlobalData.maxLevel = 10    --总关卡


GlobalData.itemsNum = { 
    diamond = { 1,2,3,0,4,3,5,5,6,7 },
    gold = { 6,5,7,13,7,6,6,4,7,5 },
    rock = { 4,5,4,2,5,3,5,4,5,7 },
    mouse = { 1,1,2,3,5,3,5,6,7,8 },
    mouse_tnt = { 1,0,1,2,2,1,2,3,4,4 },
    mine_package = { 1,2,0,2,2,1,1,2,1,2 },
    mine_tnt = { 1,2,1,2,1,3,2,3,3,4 }
}  --每个关卡各物品的数量

GlobalData.itemsValue = {   --按大、中、小顺序
    diamond = {600,600,600},
    gold = {250,100,50},
    rock = {50,20,10},
    mouse = {10,10,10},
    mouse_tnt = {0,0,0},
    mine_package = {0,0,0},
    mine_tnt = {0,0,0}
}

GlobalData.itemsWeight = {
    diamond = {2,2,2},
    gold = {20,10,5},
    rock = {16,8,4},
    mouse = {3,3,3},
    mouse_tnt = {6,6,6},
    mine_package = {3,3,3},
    mine_tnt = {3,3,3}
}

GlobalData.itemsSize = {
    diamond = {{23,16},{23,16},{23,16}},
    gold = {{66,72},{48,44},{40,30}},
    rock = {{64,60},{54,36},{30,20}},
    mouse = {{42,44},{42,44},{42,44}},
    mouse_tnt = {{42,44},{42,44},{42,44}},
    mine_package = {{42,36},{42,36},{42,36}},
    mine_tnt = {{58,62},{58,62},{58,62}}
}

--物品的圆形碰撞区域的半径，按size的大中小排序
--[[
GlobalData.itemsSize = {
    diamond = {10,10,10},
    gold = {38,23,18},
    rock = {35,25,15},
    mouse = {25,25,25},
    mouse_tnt = {25,25,25},
    mine_package = {23,23,23},
    mine_tnt = {34,34,34}
}
]]

return GlobalData