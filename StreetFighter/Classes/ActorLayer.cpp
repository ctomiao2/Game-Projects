#include "ActorLayer.h"
USING_NS_CC;

bool ActorLayer::init() {
	if (!Layer::init()) {
		return false;
	}

	initTileMap();
	initHero();
	initNPCs();

	return true;
}

void ActorLayer::subscribe(HandLayer* pHandLayer) {
	pHandLayer->registerActor(mHero);
}

void ActorLayer::initTileMap() {
	mTileMap = TMXTiledMap::create("images/pd_tilemap.tmx");
	auto children = mTileMap->getChildren();
	for each (auto child in children) {
		TMXLayer* tmxLayer = dynamic_cast<TMXLayer*>(child);
		tmxLayer->getTexture()->setAliasTexParameters();
	}
	mTileMap->setScaleY(2.4f);
	this->addChild(mTileMap, 0);
}

void ActorLayer::initHero() {
	mHero = Hero::create();
	mHero->setMediator(this);
	mHero->setPosition(Vec2(100, 125));
	this->addChild(mHero, 2);
}

void ActorLayer::initNPCs() {
	mRestOfNPC = 10;
	mNPCs.pushBack(NPC::create());
	mNPCs.at(0)->setPosition(Vec2(400, 200));
	for each (auto npc in mNPCs) {
		npc->setMediator(this);
		this->addChild(npc, 1);
	}
}

bool ActorLayer::isHeroDead() const {
	return mHero == nullptr;
}

Vec2 ActorLayer::getHeroPosition() const {
	return mHero->getPosition();
}

bool ActorLayer::canNPCAttack(const NPC* npc) const {
	return npc->canAttack(this->mHero);
}

void ActorLayer::attackByHero() {
	for (auto &it : mNPCs) {
		if (mHero->canAttack(it)) {
			it->attackByHero(mHero);
		}
	}
}

void ActorLayer::attackByNPC(NPC* npc) {
	if (npc->canAttack(mHero)) {
		mHero->attackByNPC(npc);
	}
}

void ActorLayer::npcDie(NPC* npc) {
	auto& it = this->mNPCs.find(npc);
	mNPCs.erase(it);
	npc->removeFromParentAndCleanup(true);
}

void ActorLayer::heroDie() {
	mHero->removeFromParentAndCleanup(true);
	mHero = nullptr;
}