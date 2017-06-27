#include "MainScene.h"
USING_NS_CC;

Scene* MainScene::createScene() {
	return MainScene::create();
}

bool MainScene::init() {
	if (!Scene::init()) {
		return false;
	}
	mHandLayer = HandLayer::create();
	mActorLayer = ActorLayer::create();
	mActorLayer->subscribe(mHandLayer);
	this->addChild(mActorLayer, 0);
	this->addChild(mHandLayer, 1);
	return true;
}