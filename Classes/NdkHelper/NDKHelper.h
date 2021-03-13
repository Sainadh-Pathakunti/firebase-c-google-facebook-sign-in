

#ifndef __EasyNDK_for_cocos2dx__NDKHelper__
#define __EasyNDK_for_cocos2dx__NDKHelper__

#include "cocos2d.h"
#include "NDKCallbackNode.h"
#include "jansson.h"
class NDKHelper
{
public:
    static void addSelector(const char *groupName, const char *name, FuncNV selector, cocos2d::Node *target);
    static void printSelectorList();
    static void removeSelectorsInGroup(const char *groupName);
    
    static cocos2d::Value getValueFromJson(json_t *obj);
    static json_t *getJsonFromValue(cocos2d::Value value);
    
    static void handleMessage(json_t *methodName, json_t *methodParams);

#if CC_TARGET_PLATFORM == CC_PLATFORM_WP8

	static void CPPNativeCallHandler(Platform::String^ json);

#endif
    
private:
    static std::vector<NDKCallbackNode> selectorList;
};

extern "C"
{
    void sendMessageWithParams(std::string methodName, cocos2d::Value methodParams, const char* ndkIdentifier);
}

#endif /* defined(__EasyNDK_for_cocos2dx__NDKHelper__) */