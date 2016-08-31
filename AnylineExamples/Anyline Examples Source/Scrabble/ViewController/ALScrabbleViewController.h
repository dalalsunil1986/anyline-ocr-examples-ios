//
//  ALScrabbleViewController.h
//  ExampleApi
//
//  Created by David Dengg on 14.02.16.
//  Copyright © 2016 9yards. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ALBaseViewController.h"

@interface ALScrabbleViewController : ALBaseViewController
/*
 This word setter triggers the search for an anagram
 */
@property (nonatomic, strong) NSString *scrabbleWord;

@end
