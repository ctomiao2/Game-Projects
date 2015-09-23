
local Tool = class("Tool")

--矩形碰撞检测,用4个顶点表示矩形
function Tool.checkHit(Rect_1,Rect_2)
      
    for i=1,4 do
        if Tool.isContainPoint(Rect_1,Rect_2[i]) == true or Tool.isContainPoint(Rect_2,Rect_1[i]) == true then 
            return true
        end
    end
    
    return false
end

--水平矩形碰撞检测,用于设定物品初始位置,复杂度低
function Tool.checkAlignHit(Rect_1,Rect_2)
    
    for i=1,4 do
        if Rect_1[i].x>Rect_2[1].x and Rect_1[i].x<Rect_2[3].x and Rect_1[i].y<Rect_2[1].y 
            and Rect_1[i].y>Rect_2[3].y then return true end
        
        if Rect_2[i].x>Rect_1[1].x and Rect_2[i].x<Rect_1[3].x and Rect_2[i].y<Rect_1[1].y 
            and Rect_2[i].y>Rect_1[3].y then return true end
    end
    
end

--圆形碰撞检测,在爆炸时调用
function Tool.checkCircleHit(Cir_,Rect_)
    local x,y,r = Cir_[1],Cir_[2],Cir_[3]
    --矩形有顶点在圆内
    for i=1,4 do
        local x1,y1 = Rect_[i].x,Rect_[i].y
        if (x1-x)*(x1-x) + (y1-y)*(y1-y) < r*r then return true end
    end
    
    --圆内接正方形与矩形相交
    local d = r*math.sin(math.pi/4)
    local Seq_ = { cc.p(x-d,y+d),cc.p(x+d,y+d),cc.p(x+d,y-d),cc.p(x-d,y-d) }
    if Tool.checkAlignHit(Rect_,Seq_) == true then return true end
    
    --圆4条坐标线的端点与矩形相交
    local pos = { cc.p(x,y+r),cc.p(x+r,y),cc.p(x,y-r),cc.p(x-r,y) }
    for i=1,4 do 
        if Tool.isContainPoint(Rect_,pos[i]) == true then return true end
    end
    
    return false 

end

--如果点在矩形内部，则点与任意一顶点的连线两侧都至少会有一个顶点
function Tool.isContainPoint(Rect,Point)
    for i=1,4 do
        local L = Tool.getLine(Rect[i],Point)
        local t = {}
        for j=1,4 do
            if j ~= i then
                t[#t+1] = L[1]*Rect[j].x + L[2]*Rect[j].y + L[3]
            end
        end 
        --三个点都在同侧,则Point必在Rect内!
        if (t[1]>0 and t[2]>0 and t[3]>0) or (t[1]<0 and t[2]<0 and t[3]<0) then
            return false
        end
    end
    
    return true                
        
end

--两点连线的解析式,返回{A,B,C},直线表达式为Ax+By+C=0
function Tool.getLine(p1,p2)
    local line_ = {}
    if p1.x == p2.x then
        line_ = {1,0,-p1.x}
    elseif p1.y == p2.y then
        line_ = {0,1,-p1.y}
    else
        local k = (p1.y-p2.y)/(p1.x-p2.x)
        local b = p1.y - k*p1.x
        line_ = {k,-1,b}
    end
    
    return line_
end

return Tool   