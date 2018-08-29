//
// Generated by CocoaPods-Keys
// on 29/08/2018
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
  
    
      char cString[5] = { KurozoraKeysData[199], KurozoraKeysData[36], KurozoraKeysData[34], KurozoraKeysData[84], '\0' };
    
    return [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
  
}

static NSString *_podKeys115c586ce6bd229590fe4135c590e510(KurozoraKeys *self, SEL _cmd)
{
  
    
      char cString[5] = { KurozoraKeysData[169], KurozoraKeysData[148], KurozoraKeysData[113], KurozoraKeysData[58], '\0' };
    
    return [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
  
}


static char KurozoraKeysData[218] = "uwNl/M/y6yyUX9AYvqJWUSjZJwc1E3Cikvnqo5t/tIyUmaZp4/74Ykg8x1eL419t14vhXv/EWii5iaXRLCVae/NZCWsSZtr9nERO1wlnvwrcdK238nlo52BUzdBhxzgoxGgs6nPOVXVCskFeSliHoui3ULwd7vF+RBL4nVsHrnPP7YQvaUOSIdVl6kPSEHt3B1GxXyRnTuclqIBmbf9Xnw==\\\"";

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
