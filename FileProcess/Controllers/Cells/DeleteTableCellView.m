//
//  DeleteTableCellView.m
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 03.03.2021.
//

#import "DeleteTableCellView.h"

@interface DeleteTableCellView ()

@property (nonatomic, strong) FileModel *model;

@end

@implementation DeleteTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)onDeleteTapped:(NSButton *)sender {
    
    if (sender.state == NSControlStateValueOn) {
        id alert = [NSAlert new];
        [alert setIcon:[NSImage imageNamed:NSImageNameCaution]];
        [alert setMessageText:@"You are sure?"];
        [alert addButtonWithTitle:@"No"];
        [alert addButtonWithTitle:@"Yes"];
        [alert setInformativeText:@"Deleted file cannot be restored"];
        [alert beginSheetModalForWindow:self.window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == 1001) {
                [self.model setDeleted:(sender.state == NSControlStateValueOn) ? YES : NO];
            } else {
                [sender setState:NSControlStateValueOff];
            }
        }];
    } else {
        [self.model setDeleted:NO];
    }
}

- (void)configureWithModel:(FileModel *)model {
    
    self.model = model;
    [self.deleteButton setState:(model.shouldDelete) ? NSControlStateValueOn : NSControlStateValueOff];
}

@end
