//
//  FileModel.h
//  FileProcess
//
//  Created by Vasyl Nikitiuk on 02.03.2021.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * const kFileUnprocessed = @"unprocessed";
static NSString * const kFileUpdated = @"";
static NSString * const kFileDeleted = @"deleted";

@interface FileModel : NSObject

@property (nonatomic, copy) NSURL *url;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSImage *icon;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, assign) size_t size;
@property (nonatomic, assign, getter=isDirectory) BOOL directory;
@property (nonatomic, assign, getter=isPackage) BOOL package;

@property (nonatomic, strong) NSString *status;
@property (nonatomic, assign, getter=isChecked) BOOL check;

@property (nonatomic, assign, getter=shouldDelete) BOOL deleted;

- (instancetype)initWithURL:(NSURL *)url;

- (NSDirectoryEnumerator *)directoryEnumerator;

@end

NS_ASSUME_NONNULL_END
