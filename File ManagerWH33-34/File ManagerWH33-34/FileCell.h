//
//  FileCell.h
//  File ManagerWH33-34
//
//  Created by Nikolay Berlioz on 24.02.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
