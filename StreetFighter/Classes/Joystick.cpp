#include "Joystick.h"
#include <cmath>
USING_NS_CC;

#define PI 3.1415926f

bool Joystick::init() {
	if (!Node::init()) {
		return false;
	}
	
	mIsActive = false;
	mIsTouching = false;
	initSprites();

	//register events
	auto listener = EventListenerTouchOneByOne::create();
	listener->onTouchBegan = [&](Touch* touch, Event* event) {
		auto location = this->convertToNodeSpace(touch->getLocation());
		auto sz = this->getContentSize();
		if (Rect(-sz.width/2, -sz.height/2, sz.width, sz.height).containsPoint(location)) {
			float seq = location.x * location.x + location.y * location.y;
			if (seq < this->mJoystickRadius * this->mJoystickRadius) {
				this->mIsTouching = true;
				this->updateVelocity(location);
			}
			return true;
		}
		return false;
	};
	listener->onTouchMoved = [&](Touch* touch, Event* event) {
		auto location = this->convertToNodeSpace(touch->getLocation());
		this->mIsTouching = true;
		this->updateVelocity(location);
	};
	listener->onTouchCancelled = listener->onTouchEnded = [&](Touch* touch, Event* event) {
		this->mIsTouching = false;
		this->updateVelocity(Vec2::ZERO);
		this->notify();
	};
	_eventDispatcher->addEventListenerWithSceneGraphPriority(listener, this);
	this->scheduleUpdate();
	return true;
}

void Joystick::update(float dt) {
	if (mIsTouching) {
		this->notify();
	}
}

void Joystick::initSprites() {
	SpriteFrameCache::getInstance()->addSpriteFramesWithFile("images/UI.plist");
	mThumbSprite = Sprite::createWithSpriteFrameName("JoyStick-thumb.png");
	mBackgroundSprite = Sprite::createWithSpriteFrameName("JoyStick-base.png");
	this->addChild(mBackgroundSprite, 0);
	this->addChild(mThumbSprite, 1);
	this->setContentSize(mBackgroundSprite->getContentSize());

	//set params
	this->mThumbRadius = mThumbSprite->getContentSize().width / 2;
	this->mJoystickRadius = mBackgroundSprite->getContentSize().width / 2;
	this->mDeadRadius = 10.0f;
}

void Joystick::updateVelocity(const Vec2& stickPos) {
	float dx = stickPos.x, dy = stickPos.y, dSeq = dx * dx + dy * dy;
	if (dSeq <= mDeadRadius * mDeadRadius) {
		mThumbSprite->setPosition(stickPos);
		mIsActive = false;
		return;
	}
	mIsActive = true;
	float ang = atan2f(dy, dx);	
	if (ang < 0) {
		ang += 2 * PI;
	}
	//update mAngle
	mAngle = ang;
	if (dSeq > mJoystickRadius * mJoystickRadius) {
		dx = mJoystickRadius * cosf(ang);
		dy = mJoystickRadius * sinf(ang);
	}
	mThumbSprite->setPosition(Vec2(dx, dy));
}
