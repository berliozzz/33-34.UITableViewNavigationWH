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
    
    self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.path]
                                                  includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                       error:&error];
    
    self.contents = [self cutURLString:self.contents];
    
    if ([self.contents count] > 0)
    {
        self.contents = [self sortContensWithArray:self.contents];
    }
    
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
                                                                               action:@selector(actionShowAlertWithFolderName:)];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
                                                                                target:self
                                                                                action:@selector(actionEdit:)];
    self.navigationItem.rightBarButtonItems = @[createFolder, editButton];
}

#pragma mark - Actions

- (void) actionEdit:(UIBarButtonItem*)sender
{
    BOOL isEditing = self.tableView.editing;
    
    [self.tableView setEditing:!isEditing animated:YES];
    
    UIBarButtonSystemItem item = UIBarButtonSystemItemEdit;
    
    if (self.tableView.editing)
    {
        item = UIBarButtonSystemItemDone;
    }
    
    UIBarButtonItem *createFolder = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                                  target:self
                                                                                  action:@selector(actionShowAlertWithFolderName:)];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:item
                                                                                target:self
                                                                                action:@selector(actionEdit:)];
    self.navigationItem.rightBarButtonItems = @[createFolder, editButton];
    
}

- (void) createNewFolderWithName:(NSString*)name
{
    NSString *filePath = [self.path stringByAppendingPathComponent:name];
    
    BOOL isDirectory = NO;
    
    [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory];
    
    if (isDirectory)
    {
        UIAlertController * alert =   [UIAlertController
                                       alertControllerWithTitle:@"This folder already exists!"
                                       message:@""
                                       preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
                                                           [alert dismissViewControllerAnimated:YES completion:nil];
                                                       }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:self.path error:nil];
        
        NSString *path = [self.path stringByAppendingPathComponent:name];
        
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:attributes error:nil];
        
        NSError *error = nil;
        
        self.contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.path]
                                                      includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                           error:&error];
        
        self.contents = [self cutURLString:self.contents];
        self.contents = [self sortContensWithArray:self.contents];
        
        //check object index
        NSInteger index = 0;
        
        for (NSString *string in self.contents)
        {
            if ([name isEqualToString:string])
            {
                index = [self.contents indexOfObject:string];
            }
        }
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        
        [self.tableView beginUpdates];
        
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        
        [self.tableView endUpdates];
    }
}

- (void) actionShowAlertWithFolderName:(UIBarButtonItem*)sender
{
    UIAlertController * alert =   [UIAlertController
                                  alertControllerWithTitle:@"Create New Folder"
                                  message:@""
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   
                                                   self.createFolder = alert.textFields.firstObject.text;
                                                   [self createNewFolderWithName:self.createFolder];
                                               }];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action) {
                                                       [alert dismissViewControllerAnimated:YES completion:nil];
                                                   }];
    
    
    [alert addAction:cancel];
    [alert addAction:ok];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"New folder";
        textField.textAlignment = NSTextAlignmentCenter;
        
        
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - Private methods

- (NSArray*) cutURLString:(NSArray*)array
{
    NSMutableArray *tempArray = [NSMutableArray array];
    
    for (NSString *string in array)
    {
        NSString *str = [string lastPathComponent];
        [tempArray addObject:str];
    }
    
    array = tempArray;
    
    return array;
}

- (NSArray*) sortContensWithArray:(NSArray*)array
{
    NSMutableArray* files = [NSMutableArray array];
    NSMutableArray* folders = [NSMutableArray array];
    
    for (int i = 0; i < [array count]; i ++)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        
        if ([self isDirectoryAtIndexPath:indexPath])
        {
            [folders addObject:[array objectAtIndex:i]];
        }
        else
        {
            [files addObject:[array objectAtIndex:i]];
        }
    }
    
    NSMutableArray *tempArray = [NSMutableArray arrayWithArray:folders];
    
    for (NSString *string in files)
    {
        [tempArray addObject:string];
    }
    
    return (NSArray*) tempArray;
}

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

- (unsigned long long)sizeOfFolder:(NSString *)folderPath {
    
    unsigned long long int result = 0;
    
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    
    for (NSString *fileSystemItem in array) {
        BOOL directory = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:[folderPath stringByAppendingPathComponent:fileSystemItem] isDirectory:&directory];
        if (!directory) {
            result += [[[[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:fileSystemItem] error:nil] objectForKey:NSFileSize] unsignedIntegerValue];
        }
        else {
            result += [self sizeOfFolder:[folderPath stringByAppendingPathComponent:fileSystemItem]];
        }
    }
    
    return result;
}

#pragma mark - UITableViewDataSource

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:self.contents];
        [tempArray removeObjectAtIndex:indexPath.row];
        
        
        NSString *folderName = [self.contents objectAtIndex:indexPath.row];
        NSString *path = [self.path stringByAppendingPathComponent:folderName];
        
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        
        self.contents = tempArray;
        
        [tableView beginUpdates];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        
        [tableView endUpdates];
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contents count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *fileIdentifier = @"FileCell";
    static NSString *folderIdentifier = @"FolderCell";
    
    NSString *fileName = [self.contents objectAtIndex:indexPath.row];
    
    NSString *filePath = [self.path stringByAppendingPathComponent:fileName];
    
    if ([self isDirectoryAtIndexPath:indexPath])
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:folderIdentifier];
        cell.textLabel.text = fileName;
        
        NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:[self sizeOfFolder:filePath] countStyle:NSByteCountFormatterCountStyleFile];
        cell.detailTextLabel.text = folderSizeStr;
        
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














