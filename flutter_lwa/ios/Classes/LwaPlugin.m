#import "LwaPlugin.h"


#import <LoginWithAmazon/LoginWithAmazon.h>

@implementation LwaPlugin
NSString *const kMethodSignIn = @"SIGNIN";
NSString *const kMethodSignOut = @"SIGNOUT";
NSString *const kMethodGetToken = @"GETTOKEN";
NSString *const kMethodGetProfile = @"GETPROFILE";
NSString *const kScopesArgument = @"scopes";

NSString *const kProfileScopeProfile = @"profile";
NSString *const kProfileScopePostalCode = @"postal_code";
NSString *const kProfileScopeUserId = @"user_id";

NSDictionary *kDefinedScopes;

- (instancetype)init {
    self = [super init];
    if (self) {
        kDefinedScopes = [NSDictionary dictionaryWithObjectsAndKeys:
                          [AMZNProfileScope profile], kProfileScopeProfile,
                          [AMZNProfileScope postalCode],kProfileScopePostalCode,
                          [AMZNProfileScope userID],kProfileScopeUserId,
                          nil
                          ];
        self.delegate = [[LwaDelegate alloc] init];
    }
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"com.github.ayvazj/flutter_lwa"
                                     binaryMessenger:[registrar messenger]];
    LwaPlugin* instance = [[LwaPlugin alloc] init];
    [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([kMethodSignIn isEqualToString:call.method.uppercaseString]) {
        [self.delegate signIn:result scopes:[LwaPlugin getScopesArgument:call]];
    } else if ([kMethodSignOut isEqualToString:call.method.uppercaseString]) {
        [self.delegate signOut:result];
    } else if ([kMethodGetToken isEqualToString:call.method.uppercaseString]) {
        [self.delegate getToken:result scopes:[LwaPlugin getScopesArgument:call]];
    } else if ([kMethodGetProfile isEqualToString:call.method.uppercaseString]) {
        [self.delegate fetchUser:result];
    } else {
        result(FlutterMethodNotImplemented);
    }
}

+ (NSArray*) getScopesArgument:(FlutterMethodCall*)call {
    NSMutableArray* res = [[NSMutableArray alloc] init];
    NSArray* scopesArgument = call.arguments[kScopesArgument];
    if (scopesArgument != nil) {
        int i;
        for (i = 0; i < [scopesArgument count]; i++) {
            id obj = [scopesArgument objectAtIndex:i];
            NSString* name = obj[@"name"];
            NSDictionary* scopeData = obj[@"scopeData"];
            NSObject* definedScope = kDefinedScopes[name];
            if (definedScope != nil) {
                [res addObject:definedScope];
            } else {
                [res addObject:[AMZNScopeFactory scopeWithName:name data:scopeData]];
            }
        }
    }
    return [NSArray arrayWithArray:res];
}

@end
