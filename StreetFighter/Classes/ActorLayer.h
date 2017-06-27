#ifndef __ACTORLAYER_H__
#define __ACTORLAYER_H__

#include "cocos2d.h"
#include "Observer.h"
#include "Hero.h"
#include "NPC.h"
#include "HandLayer.h"

class ActorLayer: public cocos2d::Layer {
private:
	size_t mRestOfNPC;
	Hero* mHero;
	cocos2d::Vector<NPC*> mNPCs;
	cocos2d::TMXTiledMap* mTileMap;
	void initTileMap();
	void initHero();
	void initNPCs();
public:
	virtual bool init();
	void subscribe(HandLayer* pHandLayer);
	bool isHeroDead() const;
	cocos2d::Vec2 getHeroPosition() const;
	bool canNPCAttack(const NPC* npc) const;
	void attackByHero();
	void attackByNPC(NPC* npc);
	void npcDie(NPC* npc);
	void heroDie();
	CREATE_FUNC(ActorLayer);
};

#endif