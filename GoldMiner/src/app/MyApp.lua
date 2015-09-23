
local MyApp = class("MyApp", cc.load("mvc").AppBase)

function MyApp:onCreate()
    math.randomseed(tostring(os.time()):sub(-6,-1):reverse())
end

return MyApp
