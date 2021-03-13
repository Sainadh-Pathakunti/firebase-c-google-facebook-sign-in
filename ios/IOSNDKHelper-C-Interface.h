

#ifndef EasyNDK_for_cocos2dx_IOSNDKHelper_C_Interface_h
#define EasyNDK_for_cocos2dx_IOSNDKHelper_C_Interface_h

#include <iostream>
#include <string>
#include "cocos2d.h"
#include "jansson.h"

USING_NS_CC;

using namespace std;

class IOSNDKHelperImpl
{
public:
    IOSNDKHelperImpl();
    ~IOSNDKHelperImpl();
    
    static void receiveCPPMessage(json_t *methodName, json_t *methodParams , const char* ndkIdentifier);
    static void setNDKReceiver(void *receiver);
    static void addNDKReceiver(void *receiver, const char* moduleName);
};

#endif
