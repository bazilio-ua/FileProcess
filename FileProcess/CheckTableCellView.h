//
//  CheckTableCellView.h
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 02.03.2021.
//

#import <Cocoa/Cocoa.h>
#import "FileModel.h"
#import "CellConfigurableProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface CheckTableCellView : NSTableCellView <CellConfigureProtocol>

@property (nullable, assign) IBOutlet NSButton *checkButton;


@end

NS_ASSUME_NONNULL_END
