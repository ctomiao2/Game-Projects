
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():addSearchPath("src/")
cc.FileUtils:getInstance():addSearchPath("res/")

require "config"
require "cocos.init"

local function main()    
    audio.playMusic("sound/bgm.mp3",true)
    require("app.MyApp"):create():run("MainMenu")
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    print(msg)
end
