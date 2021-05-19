#import <Flutter/Flutter.h>

#ifndef LwaDelegate_h
#define LwaDelegate_h

@interface LwaDelegate : NSObject
- (void) signIn:(FlutterResult)result scopes:(NSArray*)scopes;
- (void) signOut:(FlutterResult)result;
- (void) getToken:(FlutterResult)result scopes:(NSArray*)scopes;
- (void) fetchUser:(FlutterResult)result;
@end

#endif /* LwaDelegate_h */
