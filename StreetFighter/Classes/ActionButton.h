#ifndef __ACTION_BUTTON_H__
#define __ACTION_BUTTON_H__

#include "cocos2d.h"
#include "Observable.h"

class ActionButton : public Observable, public cocos2d::Node {
private:
	//cocos2d::Sprite* mDefaultSprite;
	cocos2d::Sprite* mPressedSprite;
	cocos2d::Sprite* mActivatedSprite;

	void initSprites();
protected:
	ActionButton() : Observable("ActionButton") {}
public:
	virtual bool init();

	CREATE_FUNC(ActionButton);
};

#endif // !__ACTION_BUTTON_H__

