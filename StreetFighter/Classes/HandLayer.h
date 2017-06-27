#ifndef __HANDLAYER_H__
#define __HANDLAYER_H__

#include "cocos2d.h"
#include "Joystick.h"
#include "ActionButton.h"

class HandLayer : public cocos2d::Layer {
private:
	Joystick* mJoystick;
	ActionButton* mActionBtn;
public:
	virtual bool init();
	void registerActor(Observer* pObserver);
	void unregisterActor(Observer* pObserver);
	CREATE_FUNC(HandLayer);
};

#endif // !__HANDLAYER_H__
