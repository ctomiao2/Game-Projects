#include "Observable.h"

void Observable::notify() {
	if (mObservers.empty()) return;
	for (auto &it : mObservers) {
		it->update(this);
	}
}

void Observable::addObserver(Observer* pObserver) {
	this->mObservers.push_back(pObserver);
}

void Observable::removeObserver(Observer* pObserver) {
	this->mObservers.remove(pObserver);
}