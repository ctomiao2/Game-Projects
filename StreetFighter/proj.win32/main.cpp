#include "main.h"
#include "AppDelegate.h"
#include "cocos2d.h"
#include <ctime>

USING_NS_CC;

int WINAPI _tWinMain(HINSTANCE hInstance,
                       HINSTANCE hPrevInstance,
                       LPTSTR    lpCmdLine,
                       int       nCmdShow)
{
    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);

	srand(time_t(0));
    // create the application instance
    AppDelegate app;
    return Application::getInstance()->run();
}
