#ifndef __OBSERVER_H__
#define __OBSERVER_H__

class Observable;
class Observer {
protected:
	Observer() {}
	virtual ~Observer() {}
public:
	virtual void update(Observable* pObservable) {}
};

#endif