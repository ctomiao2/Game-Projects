#include "NPC.h"
#include "ActorLayer.h"
USING_NS_CC;

bool NPC::init() {
	if (!Node::init()) {
		return false;
	}
	
	initData();
	initSprites();
	scheduleUpdate();
	return true;
}

void NPC::initData() {
	mATK = 100.0f;
	mHP = 1000.0f;
	mSpeed = 100.0f;
	mHitBox = Rect(-29.0f, -39.0f, 29.0f * 2, 39.0f * 2);
	mAttackBox = Rect(29.0f, -5.0f, 15.0f, 20.0f);
	mAutoState = new NPCIdleState(this);
}

void NPC::initSprites() {
	auto cache = SpriteFrameCache::getInstance();
	cache->addSpriteFramesWithFile("images/pd_sprites.plist");
	mSprite = Sprite::createWithSpriteFrameName("robot_idle_00.png");
	this->addChild(mSprite);
	mSprite->setAnchorPoint(Vec2(0, 0));
	this->setContentSize(mSprite->getContentSize());
	this->setAnchorPoint(Vec2(0.5, 0.5));

	Vector<SpriteFrame*> tmpFrames;
	char str[32] = { 0 };
	//idle animation
	for (int i = 0; i < 5; ++i) {
		sprintf(str, "robot_idle_%02d.png", i);
		auto frame = cache->getSpriteFrameByName(str);
		tmpFrames.pushBack(frame);
	}
	auto idleAnimation = Animation::createWithSpriteFrames(tmpFrames, 1.0f / 12);
	auto idleAction = RepeatForever::create(Animate::create(idleAnimation));
	idleAction->setTag(kActionIdle);
	mActionDict.insert(kActionIdle, idleAction);

	//attack animation
	tmpFrames.clear();
	for (int i = 0; i < 5; ++i) {
		sprintf(str, "robot_attack_%02d.png", i);
		auto frame = cache->getSpriteFrameByName(str);
		tmpFrames.pushBack(frame);
	}
	auto attackAnimation = Animation::createWithSpriteFrames(tmpFrames, 1.0f / 24);
	auto attackAction = Sequence::create(
		Animate::create(attackAnimation),
		CallFunc::create([&]() { this->mMediator->attackByNPC(this); }),
		DelayTime::create(0.3f),
		CallFunc::create([&]() { this->mAttackStatus = kFinish; }),
		NULL
	);
	attackAction->setTag(kActionAttack);
	mActionDict.insert(kActionAttack, attackAction);

	//walk animation
	tmpFrames.clear();
	for (int i = 0; i < 6; ++i) {
		sprintf(str, "robot_walk_%02d.png", i);
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
		sprintf(str, "robot_hurt_%02d.png", i);
		auto frame = cache->getSpriteFrameByName(str);
		tmpFrames.pushBack(frame);
	}
	auto hurtAnimation = Animation::createWithSpriteFrames(tmpFrames, 1.0f / 12);
	auto hurtAction = Sequence::create(
		Animate::create(hurtAnimation),
		DelayTime::create(0.3f),
		CallFunc::create([&]() { this->mHurtStatus = kFinish; }),
		NULL
	);
	hurtAction->setTag(kActionHurt);
	mActionDict.insert(kActionHurt, hurtAction);

	//knockout animation
	tmpFrames.clear();
	for (int i = 0; i < 5; ++i) {
		sprintf(str, "robot_knockout_%02d.png", i);
		auto frame = cache->getSpriteFrameByName(str);
		tmpFrames.pushBack(frame);
	}
	auto knockoutAnimation = Animation::createWithSpriteFrames(tmpFrames, 1.0f / 12);
	auto knockoutAction = Sequence::create(
		Animate::create(knockoutAnimation),
		Blink::create(2.0f, 10),
		CallFunc::create(CC_CALLBACK_0(NPC::die, this)),
		NULL
	);
	knockoutAction->setTag(kActionKnockout);
	mActionDict.insert(kActionKnockout, knockoutAction);
}

void NPC::update(float dt) {
	this->mAutoState->next();
}

void NPC::attackByHero(Hero* hero) {
	if (this->mHP <= 0) return;
	this->mHP -= hero->getATK();
	this->resetAttackStatus();
	this->setAutoState(new NPCHurtState(this));
}

void NPC::setMediator(ActorLayer* pMediatorLayer) {
	this->mMediator = pMediatorLayer;
}

void NPC::setAutoState(NPCAutomation* nextState) {
	delete mAutoState;
	mAutoState = nextState;
}

void NPC::die() {
	this->mMediator->npcDie(this);
}

NPC::~NPC() {
	delete mAutoState;
	mAutoState = nullptr;
}

void NPCTrackState::next() {
	if (!mNPC->getMediator()->isHeroDead()) {
		if (!mNPC->getMediator()->canNPCAttack(mNPC)) {
			if (mNPC->getActionState() == kActionWalk) {
				Vec2 srcPos = mNPC->getPosition();
				Vec2 destPos = mNPC->getMediator()->getHeroPosition();
				float dist = srcPos.distance(destPos);
				float ds = mNPC->getSpeed() * 1.0f / 60;
				if (destPos.x < srcPos.x) {
					mNPC->setFlippedX(true);
				}
				else {
					mNPC->setFlippedX(false);
				}
				mNPC->setPosition(srcPos + Vec2(ds * (destPos.x - srcPos.x) / dist, ds * (destPos.y - srcPos.y) / dist));
			}
			else mNPC->walk();
		}
		else {
			mNPC->setAutoState(new NPCAttackState(mNPC));
		}
	}
	else {
		mNPC->setAutoState(new NPCIdleState(mNPC));
	}
}

void NPCIdleState::next() {
	if (!mNPC->getMediator()->isHeroDead()) {
		mNPC->setAutoState(new NPCTrackState(mNPC));
	}
	else if (mNPC->getActionState() != kActionIdle) {
		mNPC->idle();
	}
}

void NPCAttackState::next() {
	if (mNPC->getMediator()->isHeroDead()) {
		mNPC->setAutoState(new NPCIdleState(mNPC));
		return;
	}
	if (mNPC->getActionState() != kActionAttack) {
		mNPC->resetHurtStatus();
		mNPC->attack();
	}
	else {
		if (mNPC->getAttackStatus() == kFinish) {
			mNPC->resetAttackStatus();
			if (rand() % 5 > 0) {
				mNPC->setAutoState(new NPCBackState(mNPC));
			}
			else {
				mNPC->idle();
				mNPC->setAutoState(new NPCAttackState(mNPC));
			}
		}
	}
}

void NPCBackState::next() {
	if (mNPC->getMediator()->isHeroDead()) {
		mNPC->setAutoState(new NPCIdleState(mNPC));
		return;
	}
	Vec2 curPos = mNPC->getPosition();
	bool isFlippedX = mNPC->isFilppedX();
	if (!mInitDestPos) {
		//set back destPos
		float backDist = (isFlippedX ? 1 : -1) * Director::getInstance()->getVisibleSize().width / 2 * (rand() % 10 + 1) / 10;
		mDestPos = Vec2(curPos.x + backDist, curPos.y);
		mInitDestPos = true;
		mNPC->walk();
	}
	else {
		float walkBackDist = (isFlippedX ? 1 : -1) * mNPC->getSpeed() * 1.0f / 60;
		if ((curPos.x - mDestPos.x) * (curPos.x + walkBackDist - mDestPos.x) <= 0) {
			mNPC->setPosition(mDestPos);
			mNPC->setAutoState(new NPCTrackState(mNPC));
		}
		else {
			mNPC->setPosition(curPos.x + walkBackDist, curPos.y);
		}
	}
}

void NPCHurtState::next() {
	if (mNPC->getActionState() != kActionHurt) {
		mNPC->hurt();
	}
	else {
		if (mNPC->getHurtStatus() == kFinish) {
			mNPC->resetHurtStatus();
			if (mNPC->getHP() <= 0) {
				mNPC->setAutoState(new NPCDeadState(mNPC));
			}
			else if (rand() % 2 == 0) {
				mNPC->setAutoState(new NPCAttackState(mNPC));
			}
			else {
				mNPC->setAutoState(new NPCBackState(mNPC));
			}
		}
	}
}

void NPCDeadState::next() {
	if (mNPC->getActionState() != kActionKnockout) {
		mNPC->knockout();
	}
}