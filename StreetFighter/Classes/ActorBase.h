#ifndef __ACTOR_BASE_H__
#define __ACTOR_BASE_H__

#include "cocos2d.h"
#include "Observable.h"
#include <string>

#define LEFT_BOUND		0
#define RIGHT_BOUND		cocos2d::Director::getInstance()->getVisibleSize().width
#define TOP_BOUND		225
#define BOTTOM_BOUND	0

enum ActionState {
	kActionIdle = 0,
	kActionWalk,
	kActionAttack,
	kActionHurt,
	kActionKnockout
};

enum ActionCompletionStatus {
	kNotStart = 0,
	kStart,
	kFinish
};

//each Actor is the observable of ActorLayer
class ActorBase: public cocos2d::Node {
private:
	void runAnimation(ActionState state);
protected:
	cocos2d::Sprite* mSprite;
	cocos2d::Map<ActionState, cocos2d::Action*> mActionDict;
	ActionState mState;
	ActionCompletionStatus mAttackStatus;
	ActionCompletionStatus mHurtStatus;
	cocos2d::Rect mHitBox;
	cocos2d::Rect mAttackBox;
	float mHP;
	float mATK;
	float mSpeed;

	ActorBase(const std::string& typeName) : mSprite(nullptr), mHP(0), mATK(0), mSpeed(0), 
		mState(kActionIdle), mAttackStatus(kNotStart), mHurtStatus(kNotStart) {}
public:
	void attack();
	void walk();
	void idle();
	void hurt();
	void knockout();
	ActionCompletionStatus getAttackStatus() const { return mAttackStatus; }
	void resetAttackStatus() { mAttackStatus = kNotStart; }
	ActionCompletionStatus getHurtStatus() const { return mHurtStatus; }
	void resetHurtStatus() { mHurtStatus = kNotStart; }
	cocos2d::Rect getHitBox() const;
	cocos2d::Rect getAttackBox() const;
	void setFlippedX(bool flippedX);
	bool isFilppedX() const { return mSprite->isFlippedX(); }
	float getHP() const { return mHP; }
	float getATK() const { return mATK; }
	float getSpeed() const { return mSpeed; }
	ActionState getActionState() const { return mState; }
	cocos2d::Vec2 getVisibleLocation(const cocos2d::Vec2& location) const;
	bool canAttack(const ActorBase* rhs) const;
	virtual ~ActorBase() {}
};

#endif
