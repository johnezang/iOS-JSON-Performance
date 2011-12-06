//
//  MCTestViewController.h
//  JSONlibs
//
//  Created by Junior Bontognali on 6.12.11.
//  Copyright (c) 2011 Mocha Code. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface MCTestViewController : UITableViewController <MBProgressHUDDelegate>

@property (strong, nonatomic) NSArray *selectedLibraries;
@property (strong, nonatomic) NSString *selectedFile;
@property (strong, nonatomic) MBProgressHUD *hud;
@property (strong, nonatomic) NSMutableDictionary *results;

- (void)parse;
- (float)parseWithJSONKit:(NSString *)content;
- (float)parseWithSBJSON:(NSString *)content;
- (float)parseWithTouchJSON:(NSString *)content;
- (float)parseWithNXJSON:(NSString *)content;
- (float)parseWithNSJSONSerialization:(NSString *)content;

@end
