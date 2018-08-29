//
// Generated by CocoaPods-Keys
// on 26/08/2018
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
  
    
      char cString[5] = { KurozoraKeysData[21], KurozoraKeysData[183], KurozoraKeysData[130], KurozoraKeysData[197], '\0' };
    
    return [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
  
}

static NSString *_podKeys115c586ce6bd229590fe4135c590e510(KurozoraKeys *self, SEL _cmd)
{
  
    
      char cString[5] = { KurozoraKeysData[144], KurozoraKeysData[17], KurozoraKeysData[6], KurozoraKeysData[86], '\0' };
    
    return [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
  
}


static char KurozoraKeysData[226] = "5m4kNanx5ISKI+UBOouK1n7FsBWUv4GxFuahgrhcDmV2CyHDf7M0TO43bmEQAGC5mSHqyhHJs/3CnDXrDkKgh0eDAC0hK59o7rxTyOLBu0T1DFY9Ny3oMM++QfRoH7dS2knpRTUKqhQRFW07nzIvDLjkU+PlFQPqQmMu4I38TElQYvBFwCIJMNDo6tq4S0n8u62q9e/E9bD9ttvL++uwgIFnIFe9fUHk\\\"";

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
