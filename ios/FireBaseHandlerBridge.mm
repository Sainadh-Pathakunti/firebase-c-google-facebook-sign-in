
#include "FireBaseHandlerBridge.h"
#import "ModuleFirebase.h"

void FireBaseHandlerBridge::initialize()
{
    ModuleFirebase *handler = [[ModuleFirebase alloc] init];
    [handler initialize];
}
