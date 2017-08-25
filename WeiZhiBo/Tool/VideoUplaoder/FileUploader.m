//
//  FileUploader.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/8/7.
//  Copyright © 2017年 YH. All rights reserved.
//
#define YYEncode(str) [str dataUsingEncoding:NSUTF8StringEncoding]
#define FILENAME @"image"
#define MIME_TYPE @"image/jpeg"


#import "FileUploader.h"
#import "FileStreamOperation.h"
#import "FileManager.h"

@interface FileUploader()
{
    FileStreamOperation *operation;
    NSMutableArray *dataArray;
    NSInteger currentFragment;
}
@property (strong, nonatomic) NSString *filePath;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, assign) NSInteger perValue;;


@end

static FileUploader *uploader;

@implementation FileUploader

+ (instancetype)shareFileUploader {

    return [[self alloc] init];
}


+ (instancetype)allocWithZone:(struct _NSZone *)zone {

//    @synchronized (self) {//防止多线程同时访问，造成多次分配内存
//        uploader = [super allocWithZone:zone];
//    }
//    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        uploader = [super allocWithZone:zone];
    });
    
    return uploader;
}

- (id)copyWithZone:(NSZone *)zone {
    return uploader;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return uploader;
}

- (void)uploadFileAtPath:(NSString *)path {
    _filePath = path;
   
    [self getFileOperation:path];
    
    if (operation) {
        FileFragment *fragment = [self getUploadFileFragment];
        NSData *data = [operation readDateOfFragment:fragment];
        [self upload:FILENAME filename:FILENAME mimeType:MIME_TYPE data:data fileFragment:fragment];
    }
}

#pragma mark - 上传文件分片数据

- (void)uploadingFileFragment {

    FileFragment *frafgment = operation.fileFragments[currentFragment];
    if (frafgment.fragmentStatus) {
        [self checkFragment];
    } else {
        NSData *data = [operation readDateOfFragment:frafgment];
        [self upload:FILENAME filename:FILENAME mimeType:MIME_TYPE data:data fileFragment:frafgment];
    }
}


- (void)checkFragment {
    currentFragment++;
    if (currentFragment <= operation.fileFragments.count) {
        [self uploadingFileFragment];
    } else {
        currentFragment = 0;
        [operation closeFile];
    }
}

#pragma mark - 获取文件的分片信息

- (FileStreamOperation *)getFileOperation:(NSString *)filePath {
    FileManager *fileManager = [[FileManager alloc] init];
    operation =  [fileManager getFileOperation];
    if (operation == nil) {
        [self createFileManagerWithFilePath:filePath];
    } else {
        NSInteger fragmentIndex = [operation offsetInFile];
        currentFragment = fragmentIndex;
    }
    
    return operation;
}

#pragma mark - 创建件文件管理类

- (void)createFileManagerWithFilePath:(NSString *)filePath {
    operation = [[FileStreamOperation alloc] initFileOperationAtPath:filePath forReadOperation:YES];
    NSInteger fragmentIndex = [operation offsetInFile];
    currentFragment = fragmentIndex;
    FileManager *fileManager = [[FileManager alloc] init];
    [fileManager storeFileOperation:operation];
    
}

#pragma mark - 上传分片数据

- (void)upload:(NSString *)name filename:(NSString *)filename mimeType:(NSString *)mimeType data:(NSData *)fileData fileFragment:(FileFragment*)framgent {

    if (fileData.length == 0) {
        return;
    }
    NSString *url = @"http://112.4.28.208:38080/media21";
    NSDictionary *paramater =@{@"resourceId":@"32010020170815115026716106shxxkm",
                               @"uploadType":@"vodFile,short1",
                               @"prefix":@"20170815115026765"};
    
    [WZBNetServiceAPI postUploadFileWithURL:url paramater:paramater fileData:fileData nameOfData:@"video" nameOfFile:@"test" mimeOfType:@"video/mp4" progress:^(NSProgress *uploadProgress) {
        NSLog(@"upload-progress===%@",[uploadProgress description]);
        
    } sucess:^(id responseObject) {
        NSLog(@"_________uploaded success______/n %@",responseObject);
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:fileData options:NSJSONReadingMutableLeaves error:nil];
        framgent.fragmentStatus = YES;
        currentFragment++;
        
        if ([self getUploadState]) {//文件全部上传完成
            NSLog(@"@%%%%%%上传成功-------");
            
            if ([self.delegate performSelector:@selector(fileUploadingState:fileName:)]) {
                [self.delegate fileUploadingState:YES fileName:_filePath];
            }
            
            [self removeFileFragmentData];
        } else {//还有文件分片未上传
            [self uploadingFileFragment];
        }
//        NSLog(@"%@", dict);

    } failure:^(NSError *error) {
        NSLog(@"@%%%%%%文件上传失败--------");
        if ([self.delegate performSelector:@selector(fileUploadingState:fileName:)]) {
            [self.delegate fileUploadingState:NO fileName:_filePath];
        }
        
        [self modifyFileFragmentMassage];

        NSLog(@"_________uploaded filad______ /n  %@",[error description]);
        
    }];
}

- (void)upload:(NSString *)name fileName:(NSString *)filename mimeType:(NSString *)mimeType data:(NSData *)fileData fileFragment:(FileFragment*)framgent {
    
    /** * post的上传文件，不同于普通的数据上传， * 普通上传，只是将数据转换成二进制放置在请求体中，进行上传，有响应体得到结果。 * post上传，当上传文件是， 请求体中会多一部分东西， Content——Type，这是在请求体中必须要书写的，而且必须要书写正确，不能有一个标点符号的错误。负责就会请求不上去，或者出现请求的错误（无名的问题等） * 其中在post 请求体中加入的格式有{1、边界 2、参数 3、换行 4、具体数据 5、换行 6、边界 7、换行 8、对象 9、结束符} */
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"http://112.4.28.208:38080/media21?resourceId=32010020170814152151916103i5rthc&uploadType=vodFile,media21&prefix=20170814152151979"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 设置请求头数据 。 boundary：边界
    [request setValue:@"multipart/form-data; boundary=----WebKitFormBoundaryftnnT7s3iF7wV5q6" forHTTPHeaderField:@"Content-Type"];
    // 给请求头加入固定格式数据
    NSMutableData *data = [NSMutableData data];
    /****************文件参数相关设置*********************/
    // 设置边界 注：必须和请求头数据设置的边界 一样， 前面多两个“-”；（字符串 转 data 数据）
    [data appendData:[@"------WebKitFormBoundaryftnnT7s3iF7wV5q6" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // 设置传入数据的基本属性， 包括有 传入方式 data ，传入的类型（名称） ，传入的文件名， 。
    [data appendData:[@"Content-Disposition: form-data; name=\"file\"; filename=\"video.MP4\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // 设置 内容的类型 “文件类型/扩展名” MIME中的
    [data appendData:[@"Content-Type: video/mp4" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // 加入数据内容
    [data appendData:fileData];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // 设置边界
    [data appendData:[@"------WebKitFormBoundaryftnnT7s3iF7wV5q6" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    /******************非文件参数相关设置**********************/
    // 设置传入的类型（名称）
    [data appendData:[@"Content-Disposition: form-data; name=\"username\"" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // 传入的名称username = lxl
    [data appendData:[@"lxl" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // 退出边界
    [data appendData:[@"------WebKitFormBoundaryftnnT7s3iF7wV5q6--" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    request.HTTPBody = data;
    request.HTTPMethod = @"POST";
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (!error) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            framgent.fragmentStatus = YES;
            currentFragment++;
            
            if ([self getUploadState]) {//文件全部上传完成
                NSLog(@"@%%%%%%上传成功-------");
                
                if ([self.delegate performSelector:@selector(fileUploadingState:fileName:)]) {
                    [self.delegate fileUploadingState:YES fileName:_filePath];
                }
                
                [self removeFileFragmentData];
            } else {//还有文件分片未上传
                [self uploadingFileFragment];
            }
            NSLog(@"%@", dict);
            
        } else {
            
            NSLog(@"@%%%%%%文件上传失败--------");
            if ([self.delegate performSelector:@selector(fileUploadingState:fileName:)]) {
                [self.delegate fileUploadingState:NO fileName:_filePath];
            }
            
            [self modifyFileFragmentMassage];
        }

        NSLog(@"%@",[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [task resume];
    NSLog(@"+++++++++++++");

}


#pragma mark - NSURLSessionTaskDelegate
/** * 监听上传进度 * * @param session * @param task 上传任务 * @param bytesSent 当前这次发送的数据 * @param totalBytesSent 已经发送的总数据 * @param totalBytesExpectedToSend 期望发送的总数据 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didSendBodyData:(int64_t)bytesSent totalBytesSent:(int64_t)totalBytesSent totalBytesExpectedToSend:(int64_t)totalBytesExpectedToSend {
    
    float progress = (float)1.0*totalBytesSent / totalBytesExpectedToSend;
    NSLog(@"%f",progress);
    
}
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
   
    NSLog(@"%s",__func__);
    
}


#pragma - mark - 创建多线程上传

- (void)createCurrentExecuteThread {
    //创建多个线程用于并发上传
    __block BOOL finishedOne = NO;
    __block BOOL finishedTwo = NO;
    dispatch_group_t group = dispatch_group_create();
    //2.创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^{
        //线程一
        FileFragment *fragment = [self getUploadFileFragment];
        NSData *data = [operation readDateOfFragment:fragment];
        [self upload:FILENAME filename:FILENAME mimeType:MIME_TYPE data:data fileFragment:fragment];
        finishedOne = YES;
        currentFragment ++;
    });
    if (currentFragment>=operation.fileFragments.count) {
        NSLog(@"上传完成");
        [operation closeFile];
        return;
    }
    dispatch_group_async(group, queue, ^{
        // 线程二
        FileFragment *fragment = [self getUploadFileFragment];
        NSData *data = [operation readDateOfFragment:fragment];
        [self upload:FILENAME filename:FILENAME mimeType:MIME_TYPE data:data fileFragment:fragment];
        finishedTwo = YES;
        currentFragment ++;
    });
    dispatch_group_notify(group, queue, ^{
        //汇总
        if (finishedTwo && finishedOne) {
            [self judgementUploadState];
        }
    });
}

#pragma mark - 获取还没有上传完成的文件分片

- (FileFragment *)getUploadFileFragment {
    NSInteger indexNumber;
    FileFragment *fragment;
    for (NSInteger index = currentFragment; index<operation.fileFragments.count; index++) {
        fragment = operation.fileFragments[index];
        if (!fragment.fragmentStatus) {
            indexNumber = index;
            break;
        }
    }
    currentFragment = indexNumber;
    return fragment;
}

#pragma mark - 判断文件上传状态

- (void)judgementUploadState {
    if (currentFragment <= operation.fileFragments.count) {
        [self createCurrentExecuteThread];
    } else {
        NSLog(@"成功了！");
        [operation closeFile];
    }
}

#pragma mark - 获取文件的每个分片的上传状态

- (BOOL)getUploadState {
    BOOL success = YES;
    
    for (FileFragment *fileFragment in operation.fileFragments) {
        if (!fileFragment.fragmentStatus) {
            success = NO;
            break;
        }
    }
    return success;
}

/**********用于管理当前文件的operator********/

#pragma mark - 上传完成后移除本地文件分片数据

- (void)removeFileFragmentData {
    FileManager *manager = [[FileManager alloc] init];
    [manager removeFileOperation];
}

#pragma mark - 上传失败之后修改分片信息

- (void)modifyFileFragmentMassage {
    FileManager *manager = [[FileManager alloc] init];
    [manager storeFileOperation:operation];
    
}

- (NSInteger)perValue {
    if (_perValue == 0) {
        
        _perValue = 100%operation.fileFragments.count==0?100/operation.fileFragments.count:100/operation.fileFragments.count+1;
    }
    return _perValue;
}

#pragma mark - 上传分片数据

//- (void)upload:(NSString *)name filename:(NSString *)filename mimeType:(NSString *)mimeType data:(NSData *)data fileFragment:(FileFragment*)framgent {
//    
//    // 文件上传
//    NSURL *url = [NSURL URLWithString:@"http://172.16.101.164:8030/fastdfsserver/api/fastdfs/upload"];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    request.HTTPMethod = @"POST";
//    
//    // 设置请求体
//    NSMutableData *body = [NSMutableData data];
//    NSString *fragmentId = [NSString stringWithFormat:@"--\"%@\"\r\n", framgent.fragmentId];
//    
//    /***************文件参数***************/
//    // 参数开始的标志(YY 本次上传标识字符串)
//    [body appendData:YYEncode(fragmentId)];
//    // name : 指定参数名(必须跟服务器端保持一致)
//    // filename : 文件名
//    NSString *disposition = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", name, filename];
//    [body appendData:YYEncode(disposition)];
//    NSString *type = [NSString stringWithFormat:@"Content-Type: %@\r\n", mimeType];
//    [body appendData:YYEncode(type)];
//    
//    [body appendData:YYEncode(@"\r\n")];
//    [body appendData:data];
//    [body appendData:YYEncode(@"\r\n")];
//    
//    // YY--\r\n
//    [body appendData:YYEncode(fragmentId)];
//    request.HTTPBody = body;
//    
//    // 设置请求头
//    // 请求体的长度
//    [request setValue:[NSString stringWithFormat:@"%zd", body.length] forHTTPHeaderField:@"Content-Length"];
//    // 声明这个POST请求是个文件上传
//    NSString *strContentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%tu",framgent.fragementOffset];
//    [request setValue:strContentType forHTTPHeaderField:@"Content-Type"];
//    
//    NSURLSession *session = [NSURLSession sharedSession];
//    
//    // 发送请求
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (data) {
//            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//            framgent.fragmentStatus = YES;
//            currentFragment++;
//            
//            if ([self getUploadState]) {//文件全部上传完成
//                NSLog(@"@%%%%%%上传成功-------");
//                
//                if ([self.delegate performSelector:@selector(fileUploadingState:)]) {
//                    [self.delegate fileUploadingState:YES];
//                }
//                
//                [self removeFileFragmentData];
//            } else {//还有文件分片未上传
//                [self uploadingFileFragment];
//            }
//            NSLog(@"%@", dict);
//            
//        } else {
//            
//            NSLog(@"@%%%%%%文件上传失败--------");
//            if ([self.delegate performSelector:@selector(fileUploadingState:)]) {
//                [self.delegate fileUploadingState:NO];
//            }
//            
//            [self modifyFileFragmentMassage];
//        }
//    }];
//    [dataTask resume];
//}
@end
