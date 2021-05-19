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
 These constants will be used to identify what global end-points the SDK connects to. Set the `region` property to one of the following values
 
 @since 3.0
 */
typedef NS_ENUM(NSInteger, AMZNRegion) {
    /** Setting region property to this value causes the SDK to determine the best end-points to connect to. This will be the default value in case you don't set region property explicitly */
    AMZNRegionAuto = 0,
    /** Setting region property to this value causes the SDK to connect to end-points in North America. */
    AMZNRegionNA = 1,
    /** Setting region property to this value causes the SDK to connect to end-points in Europe. */
    AMZNRegionEU = 2,
    /** Setting region property to this value causes the SDK to connect to end-points in far East. */
    AMZNRegionFE = 3
    
};
