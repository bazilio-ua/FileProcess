//
//  ViewController.m
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 19.02.2021.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSButton *processButton;

@property (nonatomic, strong, readonly) NSArray *fileKeys;
@property (nonatomic, assign, readonly) NSDirectoryEnumerationOptions fileOption;

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
    }
    
    if (file) {
        cell = [tableView makeViewWithIdentifier:identifier owner:nil];
        
        cell.textField.stringValue = text;
        cell.imageView.image = image;
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

@end
