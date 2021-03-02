//
//  NameTableCellView.h
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 02.03.2021.
//

#import <Cocoa/Cocoa.h>
#import "FileModel.h"
#import "CellConfigurableProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface NameTableCellView : NSTableCellView <CellConfigureProtocol>


@end

NS_ASSUME_NONNULL_END
