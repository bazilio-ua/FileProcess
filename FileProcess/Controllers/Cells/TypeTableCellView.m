//
//  TypeTableCellView.m
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 02.03.2021.
//

#import "TypeTableCellView.h"

@implementation TypeTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)configureWithModel:(FileModel *)model {
    
    [self.textField setStringValue:model.type];
}

@end
