#ifndef __HERO_H__
#define __HERO_H__

#include "cocos2d.h";
#include "ActorBase.h"

class ActorLayer;
class NPC;
class Hero : public Observer, public ActorBase {
private:
	ActorLayer* mMediator;
	void initData();
	void initSprites();
protected:
	Hero(): ActorBase("Hero") {}
public:
	virtual bool init() override;
	virtual void update(Observable* pObservable) override;
	void setMediator(ActorLayer* pMediatorLayer);
	void attackByNPC(NPC* npc);
	void die();
	CREATE_FUNC(Hero);
};

#endif