#import <Flutter/Flutter.h>
#import "LwaDelegate.h"
#import <LoginWithAmazon/LoginWithAmazon.h>

@implementation LwaDelegate

NSString* const kAMZNLWAErrorNonLocalizedDescription = @"AMZNLWAErrorNonLocalizedDescription";

- (void) signIn:(FlutterResult)result scopes:(NSArray*)scopes {
    // Build an authorize request.
    AMZNAuthorizeRequest *request = [[AMZNAuthorizeRequest alloc] init];
    request.scopes = scopes;
    
    //scopes;
    // Set interactive strategy as 'AMZNInteractiveStrategyNever'.
    //    request.interactiveStrategy = AMZNInteractiveStrategyNever;
    
    [[AMZNAuthorizationManager sharedManager] authorize:request
                                            withHandler:^(AMZNAuthorizeResult *_result, BOOL
                                                          userDidCancel, NSError *error) {
        if (error) {
            result([FlutterError errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                                       message:error.userInfo[kAMZNLWAErrorNonLocalizedDescription]
                                       details:nil]);
        } else if (userDidCancel) {
            // Handle errors caused when user cancels login.
        } else {
            // Authentication was successful.
            NSDictionary *usermap = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     _result.user.userID ? _result.user.userID : @"", @"userId",
                                     _result.user.email ? _result.user.email : @"", @"email",
                                     _result.user.name ? _result.user.name : @"", @"name",
                                     _result.user.postalCode ? _result.user.postalCode : @"", @"postalCode",
                                     _result.user.profileData ? _result.user.profileData : @"", @"profileData",
                                     nil];
            NSDictionary *authmap = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     _result.token ? _result.token : @"", @"accessToken",
                                     _result.authorizationCode ? _result.authorizationCode : @"", @"authorizationCode",
                                     _result.clientId ? _result.clientId : @"", @"clientId",
                                     _result.redirectUri ? _result.redirectUri : @"", @"redirectURI",
                                     usermap ? usermap : @"", @"user",
                                     nil];
            
            result(authmap);
        }
    }];
}

- (void) signOut:(FlutterResult)result {
    [[AMZNAuthorizationManager sharedManager] signOut:^(NSError * _Nullable error) {
        if (error) {
            result([FlutterError errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                                       message:error.localizedDescription
                                       details:nil]);
        } else {
            result([[NSDictionary alloc] init]);
        }
    }];
}

- (void) getToken:(FlutterResult)result scopes:(NSArray*)scopes {
    // Build an authorize request.
    AMZNAuthorizeRequest *request = [[AMZNAuthorizeRequest alloc] init];
    request.scopes = scopes;
    // Set interactive strategy as 'AMZNInteractiveStrategyNever'.
    request.interactiveStrategy = AMZNInteractiveStrategyNever;
    
    [[AMZNAuthorizationManager sharedManager] authorize:request
                                            withHandler:^(AMZNAuthorizeResult *_result, BOOL
                                                          userDidCancel, NSError *error) {
        if (error) {
            result([FlutterError errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                                       message:error.localizedDescription
                                       details:nil]);
        } else if (userDidCancel) {
            // Handle errors caused when user cancels login.
        } else {
            // Authentication was successful.
            NSDictionary *usermap = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     _result.user.userID ? _result.user.userID : @"", @"userId",
                                     _result.user.email ? _result.user.email : @"", @"email",
                                     _result.user.name ? _result.user.name : @"", @"name",
                                     _result.user.postalCode ? _result.user.postalCode : @"", @"postalCode",
                                     _result.user.profileData ? _result.user.profileData : @"", @"profileData",
                                     nil];
            NSDictionary *authmap = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     _result.token ? _result.token : @"", @"accessToken",
                                     _result.authorizationCode ? _result.authorizationCode : @"", @"authorizationCode",
                                     _result.clientId ? _result.clientId : @"", @"clientId",
                                     _result.redirectUri ? _result.redirectUri : @"", @"redirectURI",
                                     usermap ? usermap : @"", @"user",
                                     nil];
            result(authmap);
        }
    }];
}

- (void) fetchUser:(FlutterResult)result {
    [AMZNUser fetch:^(AMZNUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            result([FlutterError errorWithCode:[NSString stringWithFormat: @"%ld", (long)error.code]
                                       message:error.localizedDescription
                                       details:nil]);
        } else {
            NSDictionary *usermap = [[NSDictionary alloc] initWithObjectsAndKeys:
                                     user.userID ? user.userID : @"", @"userId",
                                     user.email ? user.email : @"", @"email",
                                     user.name ? user.name : @"", @"name",
                                     user.postalCode ? user.postalCode : @"", @"postalCode",
                                     user.profileData ? user.profileData : @"", @"profileData",
                                     nil];
            result(usermap);
        }
    }];
}
@end
