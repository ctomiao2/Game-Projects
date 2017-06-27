#ifndef __JOYSTICK_H__
#define __JOYSTICK_H__

#include "cocos2d.h"
#include "Observable.h"

class Joystick : public Observable, public cocos2d::Node {
private:
	cocos2d::Sprite* mThumbSprite;
	cocos2d::Sprite* mBackgroundSprite;
	float mJoystickRadius;
	float mThumbRadius;
	float mDeadRadius;
	int mNumberOfDirections;
	bool mIsActive;
	bool mIsTouching;
	float mAngle;  //[0, 2*PI]

	void initSprites();
	void updateVelocity(const cocos2d::Vec2& stickPos);
	//void scheduleNotify(float dt);
protected:
	Joystick() : Observable("Joystick") {}
public:
	virtual bool init();
	//return: [0, 2*PI]
	float getAngle() const { return mAngle; }
	bool isActive() const { return mIsActive; }
	virtual void update(float dt) override;
	CREATE_FUNC(Joystick);
};

#endif