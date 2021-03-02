//
//  CellConfigurableProtocol.h
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 03.03.2021.
//

#import <Foundation/Foundation.h>

@class FileModel;
@protocol CellConfigureProtocol <NSObject>

- (void)configureWithModel:(FileModel *)model;

@end

@protocol CellUpdateProtocol <NSObject>

- (void)updateWithModel:(FileModel *)model;
- (void)progressHidden:(BOOL)YesOrNo;
- (void)progressValue:(double)value;

@end
