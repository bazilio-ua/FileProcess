//
//  ProgressTableCellView.m
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 27.02.2021.
//

#import "StatusTableCellView.h"

@implementation StatusTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - <CellConfigureProtocol>

- (void)configureWithModel:(FileModel *)model {
    
    [self.progressIndicator setHidden:YES];
    
    [self.progressIndicator setMinValue:0];
    [self.progressIndicator setMaxValue:100];
    
    [self.textField setStringValue:model.status];
}

#pragma mark - <CellUpdateProtocol>

- (void)updateWithModel:(FileModel *)model {
    
    [self.textField setStringValue:model.status];
}

- (void)progressHidden:(BOOL)YesOrNo {
    
    [self.progressIndicator setHidden:YesOrNo];
}

- (void)progressValue:(double)value {
    
    [self.progressIndicator setDoubleValue:value];
}

@end
