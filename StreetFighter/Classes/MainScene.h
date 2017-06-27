#ifndef __MAIN_SCENE_H__
#define __MAIN_SCENE_H__

#include "cocos2d.h"
#include "HandLayer.h"
#include "ActorLayer.h"

class MainScene : public cocos2d::Scene {
private:
	HandLayer* mHandLayer;
	ActorLayer* mActorLayer;
public:
	static cocos2d::Scene* createScene();
	virtual bool init();

	CREATE_FUNC(MainScene);
};

#endif // !__MAIN_SCENE_H__
