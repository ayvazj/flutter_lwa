/**
 * Copyright 2012-2015 Amazon.com, Inc. or its affiliates. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy
 * of the License is located at
 *
 * http://aws.amazon.com/apache2.0/
 *
 * or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
 */

#import <Foundation/Foundation.h>

#import "AMZNRegion.h"

NS_ASSUME_NONNULL_BEGIN

@class AMZNCreateCodePairRequest;
@class AMZNCreateCodePairResult;
@class AMZNGetTokenRequest;
@class AMZNGetTokenResult;

typedef void (^AMZNCreateCodePairRequestHandler)(AMZNCreateCodePairResult * _Nullable result, NSError * _Nullable error);
typedef void (^AMZNGetTokenRequestHandler)(AMZNGetTokenResult * _Nullable result, NSError * _Nullable error);

/**
 AMZNCodePairManager defines methods used to create codePair and get a token for a given scope.
 
 @since 3.0
 */
@interface AMZNCodePairManager : NSObject

/**
 This property is used to decide which region to use.
 Set this value to one of the constants defined as part of the enum `AMZNRegion`.
 
 @since 3.0
 */
@property (nonatomic) AMZNRegion region;

/**
 This property is used for polling to check codePair authorization.

 @since 3.0
 */
@property (nonatomic) NSTimer *timer;

+ (instancetype)sharedManager;

/**
 This method is used to create codePair for a given scope. The method accepts input in AMZNCreateCodePairRequest type.

 The result is passed into the AMZNCreateCodePairRequestHandler block callback. If success, the result object will
 contain the user code and verification uri.

 If failed, the block callback will return an NSError object with corresponding error code and error domain.

 @since 3.0
 */
- (void)createCodePair:(AMZNCreateCodePairRequest *)request handler:(AMZNCreateCodePairRequestHandler)handler;

/**
 This method is used to get token for a given scope. The method accepts input in AMZNGetTokenRequest type.
 
 The result is passed into the AMZNGetTokenRequestHandler block callback. If success, the result object will
 contain the accessToken.
 
 If failed, the block callback will return an NSError object with corresponding error code and error domain.
 
 @since 3.0
 */
- (void)getToken:(AMZNGetTokenRequest *)request handler:(AMZNGetTokenRequestHandler)handler;

@end
NS_ASSUME_NONNULL_END
