#include "ActorBase.h"
#include <cassert>
USING_NS_CC;

void ActorBase::attack() {
	mAttackStatus = kStart;
	runAnimation(kActionAttack);
}

void ActorBase::walk() {
	runAnimation(kActionWalk);
}

void ActorBase::idle() {
	runAnimation(kActionIdle);
}

void ActorBase::hurt() {
	mHurtStatus = kStart;
	runAnimation(kActionHurt);
}

void ActorBase::knockout() {
	runAnimation(kActionKnockout);
}

void ActorBase::runAnimation(ActionState state) {
	auto it = mActionDict.find(state);
	auto curActionIt = mActionDict.find(mState);
	assert(it != mActionDict.end() && curActionIt != mActionDict.end());
	mSprite->stopAction(curActionIt->second);
	this->mState = state;
	mSprite->runAction(it->second);
}

void ActorBase::setFlippedX(bool flippedX) {
	this->mSprite->setFlippedX(flippedX);
	if (!flippedX) {
		if (mAttackBox.origin.x + mAttackBox.size.width < 0) {
			mAttackBox.origin.x = -(mAttackBox.origin.x + mAttackBox.size.width);
		}
	}
	else {
		if (mAttackBox.origin.x > 0) {
			mAttackBox.origin.x = -mAttackBox.origin.x - mAttackBox.size.width;
		}
	}
}

Rect ActorBase::getHitBox() const {
	return Rect(mHitBox.origin + this->getPosition(), mHitBox.size);
}

Rect ActorBase::getAttackBox() const {
	return Rect(mAttackBox.origin + this->getPosition(), mAttackBox.size);
}

bool ActorBase::canAttack(const ActorBase* rhs) const {
	return abs(this->getPosition().y - rhs->getPosition().y) < 5.0f
		&& this->getAttackBox().intersectsRect(rhs->getHitBox());
}

Vec2 ActorBase::getVisibleLocation(const Vec2& location) const {
	Vec2 pos = location;
	float left = pos.x + mHitBox.origin.x,
		bottom = pos.y + mHitBox.origin.y,
		right = pos.x + mHitBox.origin.x + mHitBox.size.width;

	if (left < LEFT_BOUND) pos.x = LEFT_BOUND - mHitBox.origin.x;
	else if (right > RIGHT_BOUND) pos.x = RIGHT_BOUND - mHitBox.origin.x - mHitBox.size.width;
	if (bottom < BOTTOM_BOUND) pos.y = BOTTOM_BOUND - mHitBox.origin.y;
	else if (bottom > TOP_BOUND) pos.y = TOP_BOUND - mHitBox.origin.y;
	return pos;
}