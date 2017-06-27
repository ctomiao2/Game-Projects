#include "ActionButton.h"
USING_NS_CC;

bool ActionButton::init() {
	if (!Node::init()) {
		return false;
	}
	initSprites();
	//event dispatch
	auto listener = EventListenerTouchAllAtOnce::create();
	listener->onTouchesBegan = [&](std::vector<Touch*> touches, Event* event) {
		int len = touches.size();
		for (auto &touch : touches) {
			auto location = this->convertToNodeSpace(touch->getLocation());
			auto sz = this->getContentSize();
			if (!Rect(-sz.width / 2, -sz.height / 2, sz.width, sz.height).containsPoint(location)) {
				continue;
			}
			this->mActivatedSprite->setVisible(false);
			this->mPressedSprite->setVisible(true);
			return true;
		}
		return false;
	};
	listener->onTouchesEnded = [&](std::vector<Touch*> touches, Event* event) {
		for (auto &touch : touches) {
			auto location = this->convertToNodeSpace(touch->getLocation());
			auto sz = this->getContentSize();
			if (!Rect(-sz.width / 2, -sz.height / 2, sz.width, sz.height).containsPoint(location)) {
				continue;
			}
			this->mActivatedSprite->setVisible(true);
			this->mPressedSprite->setVisible(false);
			this->notify();
			break;
		}
	};
	_eventDispatcher->addEventListenerWithSceneGraphPriority(listener, this);
	return true;
}

void ActionButton::initSprites() {
	SpriteFrameCache::getInstance()->addSpriteFramesWithFile("images/UI.plist");
	mPressedSprite = Sprite::createWithSpriteFrameName("button-pressed.png");
	mActivatedSprite = Sprite::createWithSpriteFrameName("button-activated.png");
	this->addChild(mPressedSprite);
	this->addChild(mActivatedSprite);
	mPressedSprite->setVisible(false);
	this->setContentSize(mActivatedSprite->getContentSize());
}