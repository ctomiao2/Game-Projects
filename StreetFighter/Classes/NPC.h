#ifndef __NPC_H__
#define __NPC_H__

#include "cocos2d.h"
#include "ActorBase.h"

class ActorLayer;
class NPCAutomation;
class Hero;
class NPC : public ActorBase {
private:
	ActorLayer* mMediator;  //weak ref
	NPCAutomation* mAutoState;
	void initData();
	void initSprites();
protected:
	NPC(): ActorBase("NPC") {};
public:
	virtual bool init();
	virtual void update(float dt) override;
	void setMediator(ActorLayer* pMediatorLayer);
	ActorLayer* getMediator() const { return mMediator; }
	void attackByHero(Hero* hero);
	void setAutoState(NPCAutomation* nextState);
	void die();
	virtual ~NPC();
	CREATE_FUNC(NPC);
};

class NPCAutomation {
protected:
	NPC* mNPC;  //weak ref
public:
	NPCAutomation(NPC* target) : mNPC(target) {}
	virtual void next() = 0;
};

class NPCTrackState: public NPCAutomation {
public:
	NPCTrackState(NPC* target) : NPCAutomation(target) {}
	void next() override;
};

class NPCIdleState: public NPCAutomation {
public:
	NPCIdleState(NPC* target) : NPCAutomation(target) {}
	void next() override;
};

class NPCAttackState : public NPCAutomation {
public:
	NPCAttackState(NPC* target) : NPCAutomation(target) {}
	void next() override;
};

class NPCHurtState : public NPCAutomation {
public:
	NPCHurtState(NPC* target) : NPCAutomation(target) {}
	void next() override;
};

class NPCBackState : public NPCAutomation {
private:
	cocos2d::Vec2 mDestPos;
	bool mInitDestPos;
public:
	NPCBackState(NPC* target) : NPCAutomation(target), mInitDestPos(false) {}
	void next() override;
};

class NPCDeadState : public NPCAutomation {
public:
	NPCDeadState(NPC* target) : NPCAutomation(target) {}
	void next() override;
};

#endif