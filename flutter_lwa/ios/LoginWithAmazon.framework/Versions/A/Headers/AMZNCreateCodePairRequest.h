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

/**
 This class is used to define an input request object when calling createCodePair:handler method in AMZNCreateCodePairHandler
 class.
 
 @since 3.0
 */
@interface AMZNCreateCodePairRequest : NSObject

/**
 This property represents a list of scopes object that request codePair. Each scope object in the scopes array
 should be in AMZNScope type.
 
 @since 3.0
 */
@property (nonatomic) NSArray *scopes;

@end
