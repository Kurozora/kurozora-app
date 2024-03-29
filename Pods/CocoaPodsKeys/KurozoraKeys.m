//
// Generated by CocoaPods-Keys
// on 14/10/2018
// For more information see https://github.com/orta/cocoapods-keys
//

#import <objc/runtime.h>
#import <Foundation/NSDictionary.h>
#import "KurozoraKeys.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation KurozoraKeys

  @dynamic kListClientID;
  @dynamic kListClientSecret;

#pragma clang diagnostic pop

+ (BOOL)resolveInstanceMethod:(SEL)name
{
  NSString *key = NSStringFromSelector(name);
  NSString * (*implementation)(KurozoraKeys *, SEL) = NULL;

  if ([key isEqualToString:@"kListClientID"]) {
    implementation = _podKeys29f112d1f913c267dd4795185e6cf1c6;
  }

  if ([key isEqualToString:@"kListClientSecret"]) {
    implementation = _podKeys115c586ce6bd229590fe4135c590e510;
  }

  if (!implementation) {
    return [super resolveInstanceMethod:name];
  }

  return class_addMethod([self class], name, (IMP)implementation, "@@:");
}

static NSString *_podKeys29f112d1f913c267dd4795185e6cf1c6(KurozoraKeys *self, SEL _cmd)
{
  
    
      char cString[5] = { KurozoraKeysData[175], KurozoraKeysData[125], KurozoraKeysData[18], KurozoraKeysData[185], '\0' };
    
    return [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
  
}

static NSString *_podKeys115c586ce6bd229590fe4135c590e510(KurozoraKeys *self, SEL _cmd)
{
  
    
      char cString[5] = { KurozoraKeysData[80], KurozoraKeysData[204], KurozoraKeysData[203], KurozoraKeysData[36], '\0' };
    
    return [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
  
}


static char KurozoraKeysData[238] = "zYv9TCoWrTXUrgTgtan68gKXPU18nRSG7/3peZ/9eiNEUL/q935roao0gnLykWhEk3ROINUrkFg65v61naI2S0j4Zt1BJ1We7sblAtSw2bQV/kKI3YK8V7ilPpGKsoDfLa2vznMl79aSQgtmo0V3c9HRXer0XpgmaMg6d0lGK0MDe4pn0sBgIj2eVehVcDa1WuErgx+JrYQnoLQCT/DzK1KGVY+7XdC0J0gasVWzkRM=\\\"";

- (NSString *)description
{
  return [@{
            @"kListClientID": self.kListClientID,
            @"kListClientSecret": self.kListClientSecret,
  } description];
}

- (id)debugQuickLookObject
{
  return [self description];
}

@end
