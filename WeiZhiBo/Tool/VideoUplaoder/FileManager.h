//
//  FileManager.h
//  UploadPauseAndResume
//
//  Created by KTM-Mac-003 on 16/9/12.
//  Copyright © 2016年 KTM-Mac-003. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileStreamOperation.h"

@interface FileManager : NSObject

- (void)storeFileOperation:(FileStreamOperation*)fileOperation;
- (FileStreamOperation *)getFileOperation;
- (void)removeFileOperation;
@end
