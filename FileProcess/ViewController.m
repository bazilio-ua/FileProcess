//
//  ViewController.m
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 19.02.2021.
//

#import "ViewController.h"
#import "FileModel.h"
#import "CellConfigurableProtocol.h"

@interface ViewController ()

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSButton *processButton;

@property (weak) IBOutlet NSTextField *progressLabel;
@property (weak) IBOutlet NSProgressIndicator *progressIndicator;

@property (nonatomic, strong) NSArray<FileModel *> *checkedArray;
@property (atomic, assign) NSUInteger processedCount;

@property (nonatomic, strong) dispatch_group_t dispatchGroup;

@end

@implementation ViewController

- (id)representedObject {
    return [super representedObject];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    [self.tableView reloadData];
    
    [self.progressIndicator setHidden:YES];
    [self.progressIndicator setIndeterminate:YES];
    [self.progressLabel setHidden:YES];
    [self.progressLabel setStringValue:@""];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.tableView setAllowsMultipleSelection:YES];
    [self.tableView setTarget:self];
    [self.tableView setDoubleAction:@selector(onCellDoubleClick:)];
    
    [self.progressIndicator setHidden:YES];
    [self.progressIndicator setIndeterminate:YES];
    [self.progressLabel setHidden:YES];
    [self.progressLabel setStringValue:@""];
    
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
    
    FileModel *file = self.representedObject[row];
    
    NSTableCellView<CellConfigureProtocol> *cell = nil;
    if ([tableColumn.identifier isEqualToString:@"checkColumn"]) {
        cell = [tableView makeViewWithIdentifier:@"checkCell" owner:self];
        
    } else if ([tableColumn.identifier isEqualToString:@"nameColumn"]) {
        cell = [tableView makeViewWithIdentifier:@"nameCell" owner:self];
        
    }  else if ([tableColumn.identifier isEqualToString:@"typeColumn"]) {
        cell = [tableView makeViewWithIdentifier:@"typeCell" owner:self];
        
    } else if ([tableColumn.identifier isEqualToString:@"statusColumn"]) {
        cell = [tableView makeViewWithIdentifier:@"statusCell" owner:self];
        
    } else if ([tableColumn.identifier isEqualToString:@"deleteColumn"]) {
        cell = [tableView makeViewWithIdentifier:@"deleteCell" owner:self];
        
    }
    
    [cell configureWithModel:file];
    
    return cell;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    
}

- (void)onCellDoubleClick:(id)sender {
    FileModel *file = self.representedObject[self.tableView.selectedRow];
    if (file) {
        if ([file isPackage]) {
            NSLog(@"try open package");
            [NSWorkspace.sharedWorkspace openURL:file.url];
        } else
        if ([file isDirectory]) {
            NSLog(@"try open dir");
            
            NSDirectoryEnumerator *directoryEnumerator = [file directoryEnumerator];
            
            NSMutableArray<FileModel *> *files = [NSMutableArray array];
            for (NSURL *url in directoryEnumerator) {
                [files addObject:[[FileModel alloc] initWithURL:url]];
            }
            
            [self setRepresentedObject:[files copy]];
        } else {
            NSLog(@"try open file");
            [NSWorkspace.sharedWorkspace openURL:file.url];
        }
    }
}

- (IBAction)processClicked:(id)sender {
    
    if (self.representedObject == nil) {
        [self.delegate openFile:sender];
        return;
    }
    
    [self setCheckedArray:[self.representedObject filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(FileModel *file, NSDictionary *bindings) {
        return [file isChecked];
    }]]];
    
    if (self.checkedArray.count) {
        
        [self.processButton setEnabled:NO];
        
        self.processedCount = 0;
        
        [self.progressIndicator setHidden:NO];
        [self.progressIndicator setIndeterminate:NO];
        [self.progressIndicator setMinValue:0];
        [self.progressIndicator setMaxValue:self.checkedArray.count];
        [self.progressIndicator setDoubleValue:self.processedCount];
        
        [self.progressLabel setHidden:NO];
        [self.progressLabel setStringValue:[NSString stringWithFormat:@"%lu of %lu completed",
                                            self.processedCount,
                                            self.checkedArray.count]];
        
        __weak typeof(self)this = self;
        [self.checkedArray enumerateObjectsUsingBlock:^(FileModel *file, NSUInteger index, BOOL *stop) {
            __strong typeof(self)self = this;
            
            dispatch_group_enter(self.dispatchGroup);
            [self.delegate processFile:file.url onCompletion:^(NSURL *aFile, NSString *hash) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"file: %@", aFile);
                    NSLog(@"hash: %@", hash);
                    NSUInteger index = [self.representedObject indexOfObjectPassingTest:^BOOL(FileModel *file, NSUInteger index, BOOL *stop) {
                        return [file.url isEqual:aFile];
                    }];
                    NSLog(@"%lu", index);
                    FileModel *file = self.representedObject[index];
                    [file setStatus:hash];
                    
                    NSTableCellView<CellConfigureProtocol> *cell = [self.tableView viewAtColumn:3 row:index makeIfNecessary:NO];
                    [cell configureWithModel:file];
                    
                    self.processedCount += 1;
                    [self.progressIndicator setDoubleValue:self.processedCount];
                    
                    [self.progressLabel setStringValue:[NSString stringWithFormat:@"%lu of %lu completed",
                                                        self.processedCount,
                                                        self.checkedArray.count]];
                    
                    dispatch_group_leave(self.dispatchGroup);
                });
                
            }];
            
        }];
        
        dispatch_group_notify(self.dispatchGroup, dispatch_get_main_queue(), ^{
            NSLog(@"all processed");
            
            [self.processButton setEnabled:YES];
        });
        
    } else {
        NSLog(@"please select files to process");
        
        id alert = [NSAlert new];
        [alert setIcon:[NSImage imageNamed:NSImageNameCaution]];
        [alert setMessageText:@"Please select files to process"];
        [alert addButtonWithTitle:@"Ok"];
        
        [alert beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSModalResponseOK) {
                NSLog(@"Ok");
            }
        }];
    }
}

#pragma mark -
#pragma mark <FileProcessXPCServiceProgressProtocol>

- (void)startedProcessForFile:(NSURL *)aFile {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"begin file processing");
        NSUInteger index = [self.representedObject indexOfObjectPassingTest:^BOOL(FileModel *file, NSUInteger index, BOOL *stop) {
            return [file.url isEqual:aFile];
        }];
        NSLog(@"%lu", index);
        
        FileModel *file = self.representedObject[index];
        [file setStatus:kFileUpdated];
        
        NSTableCellView<CellUpdateProtocol> *cell = [self.tableView viewAtColumn:3 row:index makeIfNecessary:NO];
        [cell updateWithModel:file];
        [cell progressHidden:NO];
    });
}

- (void)updateProcessWithProgress:(float)percentage forFile:(NSURL *)aFile {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"file progress: %.2f", percentage);
        NSUInteger index = [self.representedObject indexOfObjectPassingTest:^BOOL(FileModel *file, NSUInteger index, BOOL *stop) {
            return [file.url isEqual:aFile];
        }];
        NSLog(@"%lu", index);
        
        NSTableCellView<CellUpdateProtocol> *cell = [self.tableView viewAtColumn:3 row:index makeIfNecessary:NO];
        [cell progressValue:percentage];
    });
}

- (void)finishedProcessForFile:(NSURL *)aFile {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"complete file processing");
        NSUInteger index = [self.representedObject indexOfObjectPassingTest:^BOOL(FileModel *file, NSUInteger index, BOOL *stop) {
            return [file.url isEqual:aFile];
        }];
        NSLog(@"%lu", index);
        
        NSTableCellView<CellUpdateProtocol> *cell = [self.tableView viewAtColumn:3 row:index makeIfNecessary:NO];
        [cell progressHidden:YES];
    });
}

@end
