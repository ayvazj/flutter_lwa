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

NS_ASSUME_NONNULL_BEGIN

/**
 This class defines the result object of the getToken:handler method defined in AMZNCodePairManager. The result object is passed into
 the AMZNGetTokenRequestHandler block callback.

 @since 3.0
 */
@interface AMZNGetTokenResult : NSObject

@property (nonatomic) NSString *accessToken;

@end
NS_ASSUME_NONNULL_END
