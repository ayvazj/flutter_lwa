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

@class AMZNLWAError;

#pragma mark - API

/**
  These constants identify which API succeeded or failed when calling AMZNLWAAuthenticationDelegate. The value identifying
  the API is passed in the APIResult and APIError objects.

  @since 1.0
*/
typedef NS_ENUM(NSUInteger, API) {
    /** Refers to `[AMZNLWAMobileLib authorizeUserForScopes:delegate:]` */
    kAPIAuthorizeUser = 1,
    /** Refers to `[AMZNLWAMobileLib getAccessTokenForScopes:withOverrideParams:delegate:]` */
    kAPIGetAccessToken = 2,
    /** Refers to `[AMZNLWAMobileLib clearAuthorizationState:]` */
    kAPIClearAuthorizationState = 3,
    /** Refers to `[AMZNLWAMobileLib getProfile:]` */
    kAPIGetProfile = 4,
    /** Refers to `[AMZNLWAMobileLib authorizeUserForScopes:delegate:options]` */
    kAPIGetAuthorizationCode = 5,
    /** Refers to [AMZNCodePairManager getCodePair]' */
    kAPIGetCodePair = 6,
    /** Refers to [AMZNCodePairManager getToken]' */
    kAPIGetTokenForCodePair = 7
};

#pragma mark - APIResult
/**
  This class encapsulates success information from an AMZNLWAMobileLib API call.
*/
@interface APIResult : NSObject

- (id)initResultForAPI:(API)anAPI andResult:(id)theResult;

/**
  The result object returned from the API on success. The API result can be `nil`, an `NSDictionary`, or an `NSString`
  depending upon which API created the APIResult.

- `[AMZNLWAMobileLib authorizeUserForScopes:delegate:]` : Passes `nil` as the result to the delegate.
- `[AMZNLWAMobileLib getAccessTokenForScopes:withOverrideParams:delegate:]` : Passes an access token as an `NSString` object
  to the delegate.
- `[AMZNLWAMobileLib clearAuthorizationState:]` : Passes nil as the result to the delegate.
- `[AMZNLWAMobileLib getProfile:]` : Passes profile data in an `NSDictionary` object to the delegate. See the API description
  for information on the key:value pairs expected in profile dictionary.

  @since 1.0
 */
@property (strong) id result;

/**
  The API returning the result.

  @since 1.0
*/
@property API api;

@end

#pragma mark - APIError

/**
  This class encapsulates the failure result from an AMZNLWAMobileLib API call.
*/
@interface APIError : NSObject

- (id)initErrorForAPI:(API)anAPI andError:(id)theErrorObject;

/**
  The error object returned from the API on failure.

  @see See AMZNLWAError for more details.

  @since 1.0
*/
@property (strong) AMZNLWAError *error;

/**
  The API which is returning the error.

  @since 1.0
*/
@property API api;

@end

#pragma mark - AMZNLWAAuthenticationDelegate
/**
  Applications calling AMZNLWAMobileLib APIs must implement the methods of this protocol to receive success and failure
  information.
*/
@protocol AMZNLWAAuthenticationDelegate <NSObject>

@required

/**
  The APIs call this delegate method with the result when it completes successfully.

  @param apiResult An APIResult object containing the information about the calling API and the result generated.
  @see See APIResult for more information on the content of the apiResult.
  @since 1.0
*/
- (void)requestDidSucceed:(APIResult *)apiResult;


/**
 The APIs call this delegate method with the result when it fails.

 @param errorResponse An APIResult object containing the information about the API and the error that occurred.
 @see See APIError for more information on the content of the result.
 @since 1.0
*/
- (void)requestDidFail:(APIError *)errorResponse;

@end
