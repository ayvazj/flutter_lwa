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

#pragma mark - Error domains

/**
  Login With Amazon error domain for NSErrors
 */
FOUNDATION_EXPORT NSString *const kAMZNLWAErrorDomain;

#pragma mark - Error codes

/**
  No error, initial value.
*/
extern const NSUInteger kAMZNLWANoError;

/**
  A valid refresh token was not found.

  The refresh token stored in the SDK is invalid, expired, revoked, does not match
  the redirection URI used in the authorization request, does not have the required scopes, or was issued to another
  client. `[AMZNLWAMobileLib getProfile:]` and `[getAccessTokenForScopes:withOverrideParams:delegate:]` can return this
  error.

  Generally with this type of error, the app can call `[AMZNLWAMobileLib authorizeUserForScopes:delegate:]` to request
  authorization, or call `[AMZNLWAMobileLib clearAuthorizationState:]` to logout the user.
*/
extern const NSUInteger kAMZNLWAApplicationNotAuthorized;

/**
  An error occurred on the server.

  The server encountered an error while completing the request, or the SDK received an unknown response from the server.
  `[AMZNLWAMobileLib getProfile:]`, `[AMZNLWAMobileLib getAccessTokenForScopes:withOverrideParams:delegate:]`, and
  `[AMZNLWAMobileLib authorizeUserForScopes:delegate:]` can return this error.

  Generally with this type of error, the app can allow the user to retry the last action.
*/
extern const NSUInteger kAMZNLWAServerError;

/**
  The user dismissed the page.

  The user pressed cancel while on an Amazon-provided page, such as login or consent.
  `[AMZNLWAMobileLib authorizeUserForScopes:delegate:]` can return this error.

  Generally with this type of error, the app can allow the user to perform the requested operation again.
*/
extern const NSUInteger kAMZNLWAErrorUserInterrupted;

/**
  The resource owner or authorization server denied the request.

  The user declined to authorize the app on the consent page. `[AMZNLWAMobileLib authorizeUserForScopes:delegate:]` can
  return this error.

  Generally with this type of error, the app can call `[AMZNLWAMobileLib authorizeUserForScopes:delegate:]` to
  request authorization.
*/
extern const NSUInteger kAMZNLWAAccessDenied;

/**
  The SDK encountered an error on the device.

  The SDK returns this when there is a problem with the Keychain. `[AMZNLWAMobileLib getProfile:]`,
  `[AMZNLWAMobileLib getAccessTokenForScopes:withOverrideParams:delegate:]`, and
  `[AMZNLWAMobileLib authorizeUserForScopes:delegate:]` can return this error.

  Generally with this type of error, the app can call `[AMZNLWAMobileLib clearAuthorizationState:]` to reset the Keychain.
*/
extern const NSUInteger kAMZNLWADeviceError;

/**
  One of the API parameters is invalid.

  The request is missing a required parameter, includes an invalid parameter value, includes a parameter more than once,
  or is otherwise malformed.

  Check your method parameters and try again. All APIs can return this error.
*/
extern const NSUInteger kAMZNLWAInvalidInput;

/**
  A network error occurred, possibly due to the user being offline.

 `[AMZNLWAMobileLib getProfile:]`, `[AMZNLWAMobileLib getAccessTokenForScopes:withOverrideParams:delegate:]`, and
 `[AMZNLWAMobileLib authorizeUserForScopes:delegate:]` can return this error.

  Generally with this type of error, the app can ask the user to check their network connections.
*/
extern const NSUInteger kAMZNLWANetworkError;

/**
  The client is not authorized to request an authorization code using this method.

  The app is not authorized to make this call. Make sure the registered Bundle identifier matches your app, and that you
  have a valid APIKey property in the app property list.
  `[AMZNLWAMobileLib getAccessTokenForScopes:withOverrideParams:delegate:]`, and
  `[AMZNLWAMobileLib authorizeUserForScopes:delegate:]` can return this error.
*/
extern const NSUInteger kAMZNLWAUnauthorizedClient;

/**
  An internal error occurred in the SDK.

 `[AMZNLWAMobileLib getProfile:]`, `[AMZNLWAMobileLib getAccessTokenForScopes:withOverrideParams:delegate:]`, and
 `[AMZNLWAMobileLib authorizeUserForScopes:delegate:]` can return this error.

 Generally these errors cannot be handled by app. Please contact us to report recurring internal errors.
*/
extern const NSUInteger kAMZNLWAInternalError;

/**
 An version error occurred while the SDK version is not supported for LWA SSO.
 Only `[AMZNLWAMobileLib authorizeUserForScopes:delegate:]` can return this error.
 */
extern const NSUInteger kAMZNLWAVersionDenied;

/// @name userinfo keys

/**
 NSTimeInterval time until next retry attempt is added to errors of type kAMZNLWAServerError in which the server is currently unavailable and in backoff interval
*/
extern NSString *const  kAMZNLWAErrorTimeUntilNextRetryAttempt;

#pragma mark - AMZNLWAError

/**
  This class encapsulates the error information generated by the SDK. An AMZNLWAError object includes the error code and a
  meaningful error message. The error code constants are available in the header file.
*/
@interface AMZNLWAError : NSObject

/**
  The error code for the error encountered by the API.

  @since 1.0
*/
@property NSUInteger code;

/**
 An ASCII human readable error corresponding to the error code
 
 @since 1.0
 */
@property NSString *errorName;

/**
  The readable message corresponding to the error code.

  @since 1.0
*/
@property (copy) NSString *message;

/**
  Additional info which may be used to describe the error further.

  @since 3.1.1
*/

@property NSDictionary *userInfo;

@end
