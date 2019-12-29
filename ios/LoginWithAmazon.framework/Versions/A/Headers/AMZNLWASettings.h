//
//  AMZNLWASettings.h
//  LoginWithAmazon
//
//  Created by Hu, Xinyue on 2/22/19.
//  Copyright © 2019 Amazon. All rights reserved.
//

@interface AMZNLWASettings : NSObject

/**
 * Return YES if AMZNLWASettings singleton has been set to disable createAccount Link
 * Return NO if AMZNLWASettings singleton has not been set to disable createAccount Link
 */
+ (BOOL)isCreateAccountLinkDisabled;
/**
 * If this is set to be @YES, the sign in page will not show the createAccount Link.
 *
 * @param disableCreateAccountLink The BOOL param to be used.
 * @note Defaults to NO
 */
+ (void)setDisableCreateAccountLink:(BOOL)disableCreateAccountLink;
@end

