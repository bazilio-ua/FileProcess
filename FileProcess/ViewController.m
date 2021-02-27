//
//  ViewController.m
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 19.02.2021.
//

#import "ViewController.h"
#import "ProgressTableCellView.h"

@interface ViewController ()

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSButton *processButton;

@property (nonatomic, strong, readonly) NSArray *fileKeys;
@property (nonatomic, assign, readonly) NSDirectoryEnumerationOptions fileOption;

@property (nonatomic, strong) dispatch_group_t dispatchGroup;

@end

@implementation ViewController

- (NSArray *)fileKeys {
    return @[NSURLLocalizedNameKey,
             NSURLEffectiveIconKey,
             NSURLIsPackageKey,
             NSURLIsDirectoryKey,
             NSURLFileSizeKey,
             NSURLContentModificationDateKey,
             NSURLTypeIdentifierKey];
}

- (NSDirectoryEnumerationOptions)fileOption {
    return NSDirectoryEnumerationSkipsHiddenFiles | NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsPackageDescendants;
}

- (id)representedObject {
    return [super representedObject];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.tableView setAllowsMultipleSelection:YES];
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(onCellDoubleClick:)];
    
    self.dispatchGroup = dispatch_group_create();
}

#pragma mark - <NSTableViewDataSource>

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [self.representedObject count];
}

#pragma mark - <NSTableViewDelegate>

- (NSView *)tableView:(NSTableView *)tableView
   viewForTableColumn:(NSTableColumn *)tableColumn
                  row:(NSInteger)row {
    
    NSTableCellView *cell = nil;
    NSString *identifier = nil;
    NSString *text = nil;
    NSImage *image = nil;
    id file = self.representedObject[row];
    NSDictionary *fileResources = [file resourceValuesForKeys:self.fileKeys error:nil];

    if (tableColumn == tableView.tableColumns[0]) {
        identifier = @"nameCell";
        
        text = fileResources[NSURLLocalizedNameKey];
        image = fileResources[NSURLEffectiveIconKey];

    } else if (tableColumn == tableView.tableColumns[1]) {
        identifier = @"typeCell";
        
        text = fileResources[NSURLTypeIdentifierKey];
        
    } else if (tableColumn == tableView.tableColumns[2]) {
        identifier = @"statusCell";
        
        text = @"unprocessed";
    }
    
    if (file) {
        cell = [tableView makeViewWithIdentifier:identifier owner:nil];
        
        cell.textField.stringValue = text;
        cell.imageView.image = image;
        
        if ([identifier isEqualToString:@"statusCell"]) {
            [((ProgressTableCellView *)cell).progressIndicator setIndeterminate:YES];
            [((ProgressTableCellView *)cell).progressIndicator setHidden:YES];
            
            [((ProgressTableCellView *)cell).progressIndicator setMinValue:0];
            [((ProgressTableCellView *)cell).progressIndicator setMaxValue:100];
        }
    }
    
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
}

- (void)onCellDoubleClick:(id)sender {
    id file = self.representedObject[self.tableView.selectedRow];
    if (file) {
        NSDictionary *fileResources = [file resourceValuesForKeys:self.fileKeys error:nil];
        
        if ([fileResources[NSURLIsPackageKey] boolValue] == YES ) {
            NSLog(@"try open package");
            [NSWorkspace.sharedWorkspace openURL:file];
        } else
        if ([fileResources[NSURLIsDirectoryKey] boolValue] == YES) {
            NSLog(@"try open dir");
            
            NSDirectoryEnumerator *directoryEnumerator = [NSFileManager.defaultManager enumeratorAtURL:file
                                                                            includingPropertiesForKeys:self.fileKeys
                                                                                               options:self.fileOption
                                                                                          errorHandler:nil];
            
            NSMutableArray<NSURL *> *urls = [NSMutableArray new];
            for (NSURL *url in directoryEnumerator) {
                [urls addObject:url];
            }
            
            self.representedObject = [urls copy];
        } else {
            NSLog(@"try open file");
            [NSWorkspace.sharedWorkspace openURL:file];
        }
    }
}

- (IBAction)processClicked:(id)sender {
    
    if (self.representedObject == nil) {
        [self.delegate openFile:sender];
        return;
    }
    
    if (self.tableView.selectedRowIndexes.count) {
        
        __weak typeof(self)this = self;
        [self.tableView.selectedRowIndexes enumerateIndexesUsingBlock:^(NSUInteger index, BOOL *stop) {
            __strong typeof(self)self = this;
            
            id file = self.representedObject[index];
            if (file) {
                dispatch_group_enter(self.dispatchGroup);
                [self.delegate processFile:file onCompletion:^(NSURL *aFile, NSString *hash) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        NSLog(@"file: %@", aFile);
                        NSLog(@"hash: %@", hash);
                        NSUInteger index = [self.representedObject indexOfObject:aFile];
                        NSLog(@"%lu", index);
                        
                        ProgressTableCellView *cell = [self.tableView viewAtColumn:2 row:index makeIfNecessary:NO];
                        cell.textField.stringValue = hash;
                    });
                    
                    dispatch_group_leave(self.dispatchGroup);
                }];
            }
            
        }];
        
        dispatch_group_notify(self.dispatchGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            NSLog(@"all processed");
        });
        
    } else {
        NSLog(@"please select files to process");
        
        id alert = [NSAlert new];
        [alert setIcon:[NSImage imageNamed:NSImageNameCaution]];
        [alert setMessageText:@"Please select files to process"];
        [alert addButtonWithTitle:@"ok"];
        
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSModalResponseOK) {
                NSLog(@"ok");
            }
        }];
    }
}

#pragma mark -
#pragma mark <FileProcessXPCServiceProgressProtocol>

- (void)startedProcessForFile:(NSURL *)aFile {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"begin file processing");
        NSUInteger index = [self.representedObject indexOfObject:aFile];
        NSLog(@"%lu", index);
        
        ProgressTableCellView *cell = [self.tableView viewAtColumn:2 row:index makeIfNecessary:NO];
        [cell.progressIndicator setHidden:NO];
        [cell.progressIndicator setIndeterminate:NO];
        cell.textField.stringValue = @"";
    });
}


- (void)updateProcessWithProgress:(float)percentage forFile:(NSURL *)aFile {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"file progress: %.2f", percentage);
        NSUInteger index = [self.representedObject indexOfObject:aFile];
        NSLog(@"%lu", index);
        
        ProgressTableCellView *cell = [self.tableView viewAtColumn:2 row:index makeIfNecessary:NO];
        [cell.progressIndicator setDoubleValue:percentage];
    });
}

- (void)finishedProcessForFile:(NSURL *)aFile {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"complete file processing");
        NSUInteger index = [self.representedObject indexOfObject:aFile];
        NSLog(@"%lu", index);
        
        ProgressTableCellView *cell = [self.tableView viewAtColumn:2 row:index makeIfNecessary:NO];
        [cell.progressIndicator setHidden:YES];
        [cell.progressIndicator setIndeterminate:YES];
    });
}

@end
