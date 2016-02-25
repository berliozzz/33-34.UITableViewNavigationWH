//
//  DirectoryViewController.h
//  File ManagerWH33-34
//
//  Created by Nikolay Berlioz on 23.02.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DirectoryViewController : UITableViewController

@property (strong, nonatomic) NSString *path;

- (id) initWithFolderPath:(NSString*)path;

@end
