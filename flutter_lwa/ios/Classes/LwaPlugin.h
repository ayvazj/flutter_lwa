#import <Flutter/Flutter.h>
#import "LwaDelegate.h"

@interface LwaPlugin : NSObject<FlutterPlugin>
@property LwaDelegate *delegate;
- (instancetype)init;
@end

