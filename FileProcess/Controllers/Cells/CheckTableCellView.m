//
//  CheckTableCellView.m
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 02.03.2021.
//

#import "CheckTableCellView.h"

@interface CheckTableCellView ()

@property (nonatomic, strong) FileModel *model;

@end

@implementation CheckTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)onCheckboxTapped:(NSButton *)sender {
    
    [self.model setCheck:(sender.state == NSControlStateValueOn) ? YES : NO];
}

- (void)configureWithModel:(FileModel *)model {
    
    self.model = model;
    [self.checkButton setState:(model.isChecked) ? NSControlStateValueOn : NSControlStateValueOff];
}

@end
