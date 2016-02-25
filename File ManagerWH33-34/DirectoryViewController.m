//
//  DirectoryViewController.m
//  File ManagerWH33-34
//
//  Created by Nikolay Berlioz on 23.02.16.
//  Copyright © 2016 Nikolay Berlioz. All rights reserved.
//

#import "DirectoryViewController.h"
#import "FileCell.h"

@interface DirectoryViewController ()


@property (strong, nonatomic) NSArray *contents;
@property (strong, nonatomic) NSString *createFolder;

@end

@implementation DirectoryViewController

- (id) initWithFolderPath:(NSString*)path
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self)
    {
        self.path = path;
    }
    return self;
}

- (void) setPath:(NSString *)path
{
    _path = path;
    
    NSError *error = nil;
    
    self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:self.path
                                                                        error:&error];
    if (error)
    {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [self.tableView reloadData];
    
    self.navigationItem.title = [self.path lastPathComponent];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.path)
    {
        self.path = @"/Users/Berlioz/Desktop/ObjectiveC";
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    UIBarButtonItem *createFolder = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                               target:self
                                                                               action:@selector(actionCreateFolder:)];
    self.navigationItem.rightBarButtonItem = createFolder;
}

#pragma mark - Actions

- (void) actionCreateFolder:(UIBarButtonItem*)sender
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"New Folder"
                                  message:@"Create New Folder"
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Create" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   
                                                   self.createFolder = alert.textFields.firstObject.text;
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"New folder";
        textField.textAlignment = NSTextAlignmentCenter;
        
        
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Private methods

- (NSString*) fileSizeValue:(unsigned long long)size
{
    static NSString *units[] = {@"B", @"KB", @"MB", @"GB", @"TB"};
    static int unitsCount = 5;
    
    int index = 0;
    
    double fileSize = (double) size;
    
    while (fileSize > 1024 && index < unitsCount)
    {
        fileSize /= 1024;
        index++;
    }
    
    return [NSString stringWithFormat:@"%.2f %@", fileSize, units[index]];
}

- (BOOL) isDirectoryAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *fileName = [self.contents objectAtIndex:indexPath.row];
    
    NSString *filePath = [self.path stringByAppendingPathComponent:fileName];
    
    BOOL isDirectory = NO;
    
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    
    return isDirectory;
}

- (NSString*) dateFormatter:(NSDate*)currentDate
{
    static NSDateFormatter *dateFormatter = nil;
    static NSString *date;
    
    if (!dateFormatter)
    {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    }
    
    date = [dateFormatter stringFromDate:currentDate];
    
    return date;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *fileIdentifier = @"FileCell";
    static NSString *folderIdentifier = @"FolderCell";
    
    NSString *fileName = [self.contents objectAtIndex:indexPath.row];
    
    if ([self isDirectoryAtIndexPath:indexPath])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:folderIdentifier];
        cell.textLabel.text = fileName;
        
        return cell;
    }
    else
    {
        NSString *path = [self.path stringByAppendingPathComponent:fileName];
        
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        
        FileCell *cell = [tableView dequeueReusableCellWithIdentifier:fileIdentifier];
        cell.nameLabel.text = fileName;
        cell.sizeLabel.text = [self fileSizeValue:[attributes fileSize]];
        cell.dateLabel.text = [self dateFormatter:[attributes fileModificationDate]];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isDirectoryAtIndexPath:indexPath])
    {
        return 44.f;
    }
    else
    {
        return 80.f;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self isDirectoryAtIndexPath:indexPath])
    {
        NSString *fileName = [self.contents objectAtIndex:indexPath.row];
        NSString *filePath = [self.path stringByAppendingPathComponent:fileName];

        DirectoryViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DirectoryViewController"];
        vc.path = filePath;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end










//- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(nullable NSDictionary<NSString *, id> *)attributes error:(NSError **)error NS_AVAILABLE(10_5, 2_0);











