#include "HandLayer.h"
USING_NS_CC;

bool HandLayer::init() {
	if (!Layer::init()) {
		return false;
	}
	mJoystick = Joystick::create();
	mActionBtn = ActionButton::create();
	auto visibleWidth = Director::getInstance()->getVisibleSize().width;
	float stickWidth = mJoystick->getContentSize().width,
		stickHeight = mJoystick->getContentSize().height,
		actionBtnWidth = mActionBtn->getContentSize().width,
		actionBtnHeight = mActionBtn->getContentSize().height;
	mJoystick->setPosition(Vec2(stickWidth/2 + 10, stickHeight/2 + 10));
	mActionBtn->setPosition(Vec2(visibleWidth - actionBtnWidth/2 - 20, actionBtnHeight / 2 + 20));
	this->addChild(mJoystick);
	this->addChild(mActionBtn);
	return true;
}

void HandLayer::registerActor(Observer* pObserver) {
	this->mJoystick->addObserver(pObserver);
	this->mActionBtn->addObserver(pObserver);
}

void HandLayer::unregisterActor(Observer* pObserver) {
	this->mJoystick->removeObserver(pObserver);
	this->mActionBtn->removeObserver(pObserver);
}