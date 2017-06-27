#ifndef __OBSERVABLE_H__
#define __OBSERVABLE_H__

#include "Observer.h";
#include <list>
#include <string>

class Observable {
private:
	std::list<Observer*> mObservers;
	std::string mTypeName;
protected:
	Observable(const std::string& typeName = "") : mTypeName(typeName) {}
	void notify();
	virtual ~Observable() {};
public:
	void addObserver(Observer* pObserver);
	void removeObserver(Observer* pObserver);
	const std::string& getTypeName() const { return mTypeName; }
};

#endif
