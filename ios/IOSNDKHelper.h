
#ifndef __EasyNDK_for_cocos2dx__IOSNDKHelper__
#define __EasyNDK_for_cocos2dx__IOSNDKHelper__

#import "IOSNDKHelper-C-Interface.h"

@interface IOSNDKHelper : NSObject

+ (void)setNDKReceiver:(NSObject *)receiver;
+ (void)addNDKReceiver:(NSObject *)receiver moduleName:(NSString *) moduleName;
+ (void)sendMessage:(NSString *)methodName withParameters:(NSDictionary *)parameters;

@end

#endif /* defined(__EasyNDK_for_cocos2dx__IOSNDKHelper__) */
