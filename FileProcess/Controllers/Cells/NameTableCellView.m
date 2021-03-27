//
//  NameTableCellView.m
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 02.03.2021.
//

#import "NameTableCellView.h"

@implementation NameTableCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)configureWithModel:(FileModel *)model {
    
    [self.textField setStringValue:model.name];
    [self.imageView setImage:model.icon];
}

@end
