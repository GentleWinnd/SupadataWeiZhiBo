//
//  FileStreamOperation.h
//  UploadPauseAndResume
//
//  Created by KTM-Mac-003 on 16/9/6.
//  Copyright © 2016年 KTM-Mac-003. All rights reserved.
//

#import "FileStreamOperation.h"
#import <CommonCrypto/CommonDigest.h>

//// 把FileStreamOpenration类保存到UserDefault中
//static NSString *const UserDefaultFileInfo = @"UserDefaultFileInfo";

#pragma mark - FileStreamOperation

@interface FileStreamOperation ()
@property (nonatomic, copy) NSString                          *fileName;
@property (nonatomic, assign) NSUInteger                      fileSize;
@property (nonatomic, copy) NSString                          *filePath;
@property (nonatomic, strong) NSArray<FileFragment*>          *fileFragments;
@property (nonatomic, strong) NSFileHandle                    *readFileHandle;
@property (nonatomic, strong) NSFileHandle                    *writeFileHandle;
@property (nonatomic, assign) BOOL                            isReadOperation;
@end

@implementation FileStreamOperation

+ (NSString *)fileKey {
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfstring = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    const char *cStr = CFStringGetCStringPtr(cfstring,CFStringGetFastestEncoding(cfstring));
    unsigned char result[16];
    CC_MD5( cStr, (unsigned int)strlen(cStr), result );
    CFRelease(uuid);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%08lx",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15],
            (unsigned long)(arc4random() % NSUIntegerMax)];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:[self fileName] forKey:@"fileName"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self fileSize]] forKey:@"fileSize"];
    [aCoder encodeObject:[self filePath] forKey:@"filePath"];
    [aCoder encodeObject:[self fileFragments] forKey:@"fileFragments"];
    [aCoder encodeObject:[NSNumber numberWithInteger:[self currentIndex]] forKey:@"currentIndex"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        [self setFileName:[aDecoder decodeObjectForKey:@"fileName"]];
        [self setFileSize:[[aDecoder decodeObjectForKey:@"fileSize"] unsignedIntegerValue]];
        [self setFilePath:[aDecoder decodeObjectForKey:@"filePath"]];
        [self setFileFragments:[aDecoder decodeObjectForKey:@"fileFragments"]];
        [self setCurrentIndex:[[aDecoder decodeObjectForKey:@"currentIndex"] unsignedIntegerValue]];
    }
    
    return self;
}


- (BOOL)getFileInfoAtPath:(NSString*)path {
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:path]) {
        NSLog(@"文件不存在：%@",path);
        return NO;
    }
    
    self.filePath = path;
    
    NSDictionary *attr =[fileMgr attributesOfItemAtPath:path error:nil];
    self.fileSize = attr.fileSize;
    
    NSString *fileName = [path lastPathComponent];
    self.fileName = fileName;
    self.currentIndex = 0;
    return YES;
}

// 若为读取文件数据，打开一个已存在的文件。
// 若为写入文件数据，如果文件不存在，会创建的新的空文件。
- (instancetype)initFileOperationAtPath:(NSString*)path forReadOperation:(BOOL)isReadOperation {
    
    if (self = [super init]) {
        self.isReadOperation = isReadOperation;
        if (self.isReadOperation) {
            if (![self getFileInfoAtPath:path]) {
                return nil;
            }
            self.readFileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
            [self cutFileForFragments];
        } else {
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            if (![fileMgr fileExistsAtPath:path]) {
                [fileMgr createFileAtPath:path contents:nil attributes:nil];
            }
            
            if (![self getFileInfoAtPath:path]) {
                return nil;
            }
            
            self.writeFileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
        }
    }
    
    return self;
}

#pragma mark - 读操作
// 切分文件片段
- (void)cutFileForFragments {
    
    NSUInteger offset = FileFragmentMaxSize;
    // 块数
    NSUInteger chunks = (self.fileSize%offset==0)?(self.fileSize/offset):(self.fileSize/(offset) + 1);
    
    NSMutableArray<FileFragment *> *fragments = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger i = 0; i < chunks; i ++) {
        
        FileFragment *fFragment = [[FileFragment alloc] init];
        fFragment.fragmentStatus = NO;
        fFragment.fragmentId = [[self class] fileKey];
        fFragment.fragementOffset = i * offset;
        
        if (i != chunks - 1) {
            fFragment.fragmentSize = offset;
        } else {
            fFragment.fragmentSize = self.fileSize - fFragment.fragementOffset;
        }
        
        [fragments addObject:fFragment];
    }
    
    self.fileFragments = fragments;
}

// 通过分片信息读取对应的片数据
- (NSData*)readDateOfFragment:(FileFragment*)fragment {
    
    if (fragment) {
        [self seekToFileOffset:fragment.fragementOffset];
        return [self.readFileHandle readDataOfLength:fragment.fragmentSize];
    }
    
    return nil;
}

- (NSData*)readDataOfLength:(NSUInteger)bytes {
    return [self.readFileHandle readDataOfLength:bytes];
}


- (NSData*)readDataToEndOfFile {
    return [self.readFileHandle readDataToEndOfFile];
}

#pragma mark - 写操作

// 写入文件数据
- (void)writeData:(NSData *)data {
    [self.writeFileHandle writeData:data];
}

#pragma mark - common
// 获取当前偏移量
- (NSUInteger)offsetInFile{
    if (self.isReadOperation) {
        return [self.readFileHandle offsetInFile];
    }
    
    return [self.writeFileHandle offsetInFile];
}

// 设置偏移量, 仅对读取设置
- (void)seekToFileOffset:(NSUInteger)offset {
    [self.readFileHandle seekToFileOffset:offset];
}

// 将偏移量定位到文件的末尾
- (NSUInteger)seekToEndOfFile{
    if (self.isReadOperation) {
        return [self.readFileHandle seekToEndOfFile];
    }
    
    return [self.writeFileHandle seekToEndOfFile];
}

// 关闭文件
- (void)closeFile {
    if (self.isReadOperation) {
        [self.readFileHandle closeFile];
    } else {
        [self.writeFileHandle closeFile];
    }
}

- (NSFileHandle *)readFileHandle  {
    if (_readFileHandle == nil) {
        _readFileHandle = [NSFileHandle fileHandleForReadingAtPath:self.filePath];
    }
    return _readFileHandle;
}

- (NSFileHandle *)writeFileHandle {
    if (_writeFileHandle == nil) {
        _writeFileHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
    }
    return _writeFileHandle;
}

@end

#pragma mark - FileFragment

@implementation FileFragment

- (void)encodeWithCoder:(NSCoder *)aCoder {
    
    [aCoder encodeObject:[self fragmentId] forKey:@"fragmentId"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self fragmentSize]] forKey:@"fragmentSize"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self fragementOffset]] forKey:@"fragementOffset"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:[self fragmentStatus]] forKey:@"fragmentStatus"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self != nil) {
        [self setFragmentId:[aDecoder decodeObjectForKey:@"fragmentId"]];
        [self setFragmentSize:[[aDecoder decodeObjectForKey:@"fragmentSize"] unsignedIntegerValue]];
        [self setFragementOffset:[[aDecoder decodeObjectForKey:@"fragementOffset"] unsignedIntegerValue]];
        [self setFragmentStatus:[[aDecoder decodeObjectForKey:@"fragmentStatus"] boolValue]];
    }
    
    return self;
}



@end
