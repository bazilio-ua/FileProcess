//
//  StatusTableCellView.h
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 27.02.2021.
//

#import <Cocoa/Cocoa.h>
#import "FileModel.h"
#import "CellConfigurableProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface StatusTableCellView : NSTableCellView <CellConfigureProtocol, CellUpdateProtocol>

@property (nullable, assign) IBOutlet NSProgressIndicator *progressIndicator;

@end

NS_ASSUME_NONNULL_END
