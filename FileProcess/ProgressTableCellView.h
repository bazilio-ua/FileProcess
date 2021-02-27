//
//  ProgressTableCellView.h
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 27.02.2021.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProgressTableCellView : NSTableCellView

@property (nullable, assign) IBOutlet NSProgressIndicator *progressIndicator;

@end

NS_ASSUME_NONNULL_END
