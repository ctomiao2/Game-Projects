#include "Hero.h"
#include "Joystick.h"
#include "ActionButton.h"
#include "ActorLayer.h"
#include "NPC.h"

USING_NS_CC;
using namespace std;

bool Hero::init() {
	if (!Node::init()) {
		return false;
	}
	
	initData();
	initSprites();

	return true;
}

//joystick and actionbutton control hero's action
void Hero::update(Observable* pObservable) {
	string typeName = pObservable->getTypeName();
	if (typeName == "Joystick") {
		Joystick* pJoystick = dynamic_cast<Joystick*>(pObservable);
		if (pJoystick->isActive()) {
			if (mState != kActionWalk) {
				this->walk();
			}
			auto angle = pJoystick->getAngle();
			float ds = this->mSpeed * 1.0 / 60;
			float cosAng = cosf(angle), sinAng = sinf(angle);
			if (cosAng < 0) { this->mSprite->setFlippedX(true); }
			else { this->mSprite->setFlippedX(false); }
			auto roundPos = this->getVisibleLocation(this->getPosition() + Vec2(ds*cosAng, ds*sinAng));
			if (this->getPosition().distanceSquared(roundPos) > 0.1f) {
				this->setPosition(roundPos);
			}
		}
		else if (mState != kActionIdle) {	
			this->idle();
		}
	}
	else if (typeName == "ActionButton") {
		if (mState != kActionAttack) {
			this->attack();	
		}
	}
}

void Hero::initData() {
	mATK = 100.0f;
	mHP = 500.0f;
	mSpeed = 200.0f;
	mHitBox = Rect(-29.0f, -39.0f, 29.0f * 2, 39.0f * 2);
	mAttackBox = Rect(29.0f, -10.0f, 25.0f, 20.0f);
}

void Hero::initSprites() {
	auto cache = SpriteFrameCache::getInstance();
	cache->addSpriteFramesWithFile("images/pd_sprites.plist");
	mSprite = Sprite::createWithSpriteFrameName("hero_idle_00.png");
	mSprite->setAnchorPoint(Vec2(0, 0));
	this->addChild(mSprite);
	this->setContentSize(mSprite->getContentSize());
	this->setAnchorPoint(Vec2(0.5, 0.5));
	
	Vector<SpriteFrame*> tmpFrames;
	char str[32] = { 0 };
	//idle animation
	for (int i = 0; i < 6; ++i) {
		sprintf(str, "hero_idle_%02d.png", i);
		auto frame = cache->getSpriteFrameByName(str);
		tmpFrames.pushBack(frame);
	}
	auto idleAnimation = Animation::createWithSpriteFrames(tmpFrames, 1.0f / 12);
	auto idleAction = RepeatForever::create(Animate::create(idleAnimation));
	idleAction->setTag(kActionIdle);
	mActionDict.insert(kActionIdle, idleAction);

	//attack animation
	tmpFrames.clear();
	for (int i = 0; i < 3; ++i) {
		sprintf(str, "hero_attack_00_%02d.png", i);
		auto frame = cache->getSpriteFrameByName(str);
		tmpFrames.pushBack(frame);
	}
	auto attackAnimation = Animation::createWithSpriteFrames(tmpFrames, 1.0f / 24);
	auto attackAction = Sequence::create(
		Animate::create(attackAnimation),
		CallFunc::create([&]() { this->mMediator->attackByHero(); }),
		CallFunc::create(CC_CALLBACK_0(Hero::idle, this)),
		NULL
	);
	attackAction->setTag(kActionAttack);
	mActionDict.insert(kActionAttack, attackAction);

	//walk animation
	tmpFrames.clear();
	for (int i = 0; i < 8; ++i) {
		sprintf(str, "hero_walk_%02d.png", i);
		auto frame = cache->getSpriteFrameByName(str);
		tmpFrames.pushBack(frame);
	}
	auto walkAnimation = Animation::createWithSpriteFrames(tmpFrames, 1.0f / 12);
	auto walkAction = RepeatForever::create(Animate::create(walkAnimation));
	walkAction->setTag(kActionWalk);
	mActionDict.insert(kActionWalk, walkAction);

	//hurt animation
	tmpFrames.clear();
	for (int i = 0; i < 3; ++i) {
		sprintf(str, "hero_hurt_%02d.png", i);
		auto frame = cache->getSpriteFrameByName(str);
		tmpFrames.pushBack(frame);
	}
	auto hurtAnimation = Animation::createWithSpriteFrames(tmpFrames, 1.0f / 12);
	auto hurtAction = Sequence::create(
		Animate::create(hurtAnimation),
		CallFunc::create([&]() { this->mHurtStatus = kFinish; }),
		CallFunc::create(CC_CALLBACK_0(Hero::idle, this)),
		NULL
	);
	hurtAction->setTag(kActionHurt);
	mActionDict.insert(kActionHurt, hurtAction);

	//knockout animation
	tmpFrames.clear();
	for (int i = 0; i < 5; ++i) {
		sprintf(str, "hero_knockout_%02d.png", i);
		auto frame = cache->getSpriteFrameByName(str);
		tmpFrames.pushBack(frame);
	}
	auto knockoutAnimation = Animation::createWithSpriteFrames(tmpFrames, 1.0f / 12);
	auto knockoutAction = Sequence::create(
		Animate::create(knockoutAnimation),
		Blink::create(2.0f, 10),
		CallFunc::create(CC_CALLBACK_0(Hero::die, this)),
		NULL
	);
	knockoutAction->setTag(kActionKnockout);
	mActionDict.insert(kActionKnockout, knockoutAction);
}

void Hero::setMediator(ActorLayer* pMediatorLayer) {
	this->mMediator = pMediatorLayer;
}

void Hero::attackByNPC(NPC* npc) {
	if (this->mHP <= 0) return;
	this->mHP -= npc->getATK();
	this->resetAttackStatus();
	this->hurt();
	if (this->mHP <= 0) {
		this->knockout();
	}
}

void Hero::die() {
	this->mMediator->heroDie();
}