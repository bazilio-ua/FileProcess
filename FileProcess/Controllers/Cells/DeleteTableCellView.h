//
//  DeleteTableCellView.h
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 03.03.2021.
//

#import <Cocoa/Cocoa.h>
#import "FileModel.h"
#import "CellConfigurableProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DeleteTableCellView : NSTableCellView <CellConfigureProtocol>

@property (nullable, assign) IBOutlet NSButton *deleteButton;

@end

NS_ASSUME_NONNULL_END
