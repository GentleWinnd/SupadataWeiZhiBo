//
//  HistoryRecoderViewController.m
//  WeiZhiBo
//
//  Created by SUPADATA on 2017/6/22.
//  Copyright © 2017年 YH. All rights reserved.
//

#import "HistoryRecoderViewController.h"
#import "HistoryRecoderTableViewCell.h"
#import "SaveDataManager.h"
#import "FileUploader.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

@interface HistoryRecoderViewController ()<UITableViewDelegate, UITableViewDataSource, FileUploaderDelegate>
@property (strong, nonatomic) IBOutlet UITableView *recoderTab;
@property (strong, nonatomic) IBOutlet UILabel *noDataLable;
@property (strong, nonatomic) MPMoviePlayerViewController *playerVC;
@property (strong, nonatomic) FileUploader *uploader;
@end

static NSString *cellId = @"cellIdentifiler";

@implementation HistoryRecoderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initData];
    [self initTableView];

}

- (void)initData {
   
    if (_historyRecoderArr.count>0) {
        self.noDataLable.hidden = YES;
    } else {
        self.noDataLable.hidden = NO;
    }
    
}

- (void)setHistoryRecoderArr:(NSMutableArray *)historyRecoderArr {

    if (historyRecoderArr) {
        _historyRecoderArr = historyRecoderArr;
    }
}

- (void)initTableView {

    self.recoderTab.delegate = self;
    self.recoderTab.dataSource = self;
    self.recoderTab.rowHeight = UITableViewAutomaticDimension;
    self.recoderTab.estimatedRowHeight = 55;
    [self.recoderTab registerNib:[UINib nibWithNibName:@"HistoryRecoderTableViewCell" bundle:nil] forCellReuseIdentifier:cellId];

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  _historyRecoderArr.count;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 55;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    HistoryRecoderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    NSString *videoPath = self.historyRecoderArr[indexPath.row];
    NSString *videoId;
    if (videoPath.length>0) {
        NSString *videoName = [videoPath componentsSeparatedByString:@"/"].lastObject;
        if (videoName.length>0) {
            videoId = [videoName componentsSeparatedByString:@"."].firstObject;
        } else {
            [Progress progressShowcontent:@"视频资源获取失败" currView:self.view];
        }
    } else {
        [Progress progressShowcontent:@"视频资源获取失败了" currView:self.view];
    }

    NSString *titleStr = [[SaveDataManager shareSaveRecoder] getRecoderTitleWithVideoId:videoId];
    BOOL uploadState = [[SaveDataManager shareSaveRecoder] getRecoderUploadStateWithVideoId:videoId];
    
    cell.dotBtn.selected = uploadState;
    cell.uploadBtn.selected = uploadState;
    cell.titleLabel.text = titleStr;
    cell.classLabel.attributedText = [self getVideoClassesWithVideoId:videoId withLabelWidth:CGRectGetWidth(cell.classLabel.frame)];
    cell.cellBtnAction = ^(BOOL remove) {
        if ( remove ) {//视频删除
            [self removeHistoryRecoder:self.historyRecoderArr[indexPath.row]];
            
        } else {//视频上传
            [self uploadVideo:videoPath];
        }
    };
    
    [self logVideoSize:videoPath];
    
    return cell;
}

#pragma mark - 上传视频

- (void)uploadVideo:(NSString *) filePath {
//    _uploader = [FileUploader shareFileUploader];
//    _uploader.delegate = self;
//    [_uploader uploadFileAtPath:filePath];
   
//    NSDictionary *paramater =@{@"resourceId":@"32010020170815150513130106xpz6q2",
//                               @"uploadType":@"vodFile,short1",
//                               @"prefix":@"20170815150513173"};
     NSString *url = @"http://apk.139jy.cn:8006/short?resourceId=32010020170816104844475106h6zw3s&uploadType=vodFile,short1&prefix=20170816104844515";
    NSData *data = [NSData dataWithContentsOfFile:filePath];
//    [WZBNetServiceAPI postUploadFileWithURL:url paramater:nil fileData:data nameOfData:@"video" nameOfFile:@"test" mimeOfType:@"video/mp4" progress:^(NSProgress *uploadProgress) {
//        NSLog(@"upload-progress===%@",[uploadProgress description]);
//    } sucess:^(id responseObject) {
//        NSLog(@"_________uploaded success______/n %@",responseObject);
//    } failure:^(NSError *error) {
//        NSLog(@"_________uploaded filad______ /n  %@",[error description]);
//        
//    }];
    [self upload:url filename:@"video" mimeType:@"video/mp4" data:data];
}


- (void)upload:(NSString *)name filename:(NSString *)filename mimeType:(NSString *)mimeType data:(NSData *)fileData {

    /** * post的上传文件，不同于普通的数据上传， * 普通上传，只是将数据转换成二进制放置在请求体中，进行上传，有响应体得到结果。 * post上传，当上传文件是， 请求体中会多一部分东西， Content——Type，这是在请求体中必须要书写的，而且必须要书写正确，不能有一个标点符号的错误。负责就会请求不上去，或者出现请求的错误（无名的问题等） * 其中在post 请求体中加入的格式有{1、边界 2、参数 3、换行 4、具体数据 5、换行 6、边界 7、换行 8、对象 9、结束符} */

    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:@"http://apk.139jy.cn:8006/short?resourceId=32010020170816104844475106h6zw3s&uploadType=vodFile,short1&prefix=20170816104844515"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 设置请求头数据 。 boundary：边界
    [request setValue:@"multipart/form-data; boundary=----WebKitFormBoundaryftnnT7s3iF7wV5q6" forHTTPHeaderField:@"Content-Type"];
    // 给请求头加入固定格式数据
    NSMutableData *data = [NSMutableData data];
    /****************文件参数相关设置*********************/
    // 设置边界 注：必须和请求头数据设置的边界 一样， 前面多两个“-”；（字符串 转 data 数据）
//    [data appendData:[@"------WebKitFormBoundaryftnnT7s3iF7wV5q6" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    // 设置传入数据的基本属性， 包括有 传入方式 data ，传入的类型（名称） ，传入的文件名， 。
//    [data appendData:[@"Content-Disposition: form-data; name=\"mp4\"; filename=\"video\"" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    // 设置 内容的类型 “文件类型/扩展名” MIME中的
    [data appendData:[@"Content-Type: mp4" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // 加入数据内容
    [data appendData:fileData];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    // 设置边界
//    [data appendData:[@"------WebKitFormBoundaryftnnT7s3iF7wV5q6" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    /******************非文件参数相关设置**********************/
//    // 设置传入的类型（名称）
//    [data appendData:[@"Content-Disposition: form-data; name=\"username\"" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    // 传入的名称username = lxl
//    [data appendData:[@"lxl" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//    // 退出边界
//    [data appendData:[@"------WebKitFormBoundaryftnnT7s3iF7wV5q6--" dataUsingEncoding:NSUTF8StringEncoding]];
//    [data appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    
    request.HTTPBody = data;
    request.HTTPMethod = @"POST";
    NSURLSessionUploadTask *task = [session uploadTaskWithRequest:request fromData:data completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        if (!error) {
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            NSLog(@"%@", dict);

        } else {

            NSLog(@"@%%%%%%文件上传失败--------");
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



- (void)fileUploadingState:(BOOL)state fileName:(NSString *)fileName{//fileuploaderdelegate function
    
    if (fileName.length>0) {//修改文件上传的额状态
        NSString *videoName = [fileName componentsSeparatedByString:@"/"].lastObject;
        if (videoName.length>0) {
            NSString *videoId = [videoName componentsSeparatedByString:@"."].firstObject;
            [[SaveDataManager shareSaveRecoder] saveRecoderUploadState:state withVideoId:videoId];
        } else {
            [Progress progressShowcontent:@"视频保存失败了" currView:self.view];
        }
    } else {
        [Progress progressShowcontent:@"视频保存失败了" currView:self.view];
    }
}


- (void)logVideoSize:(NSString *)url {
    NSData *video = [NSData dataWithContentsOfFile:url];
    NSInteger MSize = video.length/(1024*1024);
    NSLog(@"------=======%@",[NSNumber numberWithInteger:MSize]);
    
}

- (NSMutableAttributedString *)getVideoClassesWithVideoId:(NSString *)videoId withLabelWidth:(CGFloat)width {

    NSArray *classArr = [NSArray arrayWithArray:[[SaveDataManager shareSaveRecoder] getVideoClassesWithVideoId:videoId]];
    NSString *titleStr = @"";
    
    if (classArr.count > 0) {
        for (NSDictionary *classDic in classArr) {
            titleStr = [NSString stringWithFormat:@"%@ %@",titleStr ,classDic[@"className"]];
        }
    }
    
    CGFloat lineSpace = 7;
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:titleStr];
    
    if ([self calculateRowWidth:titleStr]<width) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = lineSpace;
        [attributeString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, titleStr.length)];
        [attributeString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:NSMakeRange(0, titleStr.length)];
    }
    
    return attributeString;

}

- (CGFloat)calculateRowWidth:(NSString *)string {
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:11]};  //指定字号
    CGRect rect = [string boundingRectWithSize:CGSizeMake(0, 15)/*计算宽度时要确定高度*/ options:NSStringDrawingUsesLineFragmentOrigin |
                   NSStringDrawingUsesFontLeading attributes:dic context:nil];
    
    return rect.size.width;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    [self playVideo:self.historyRecoderArr[indexPath.row]];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)backBtnAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)playVideo:(NSString *) videoUrl {
    
    if (videoUrl.length > 0) {
        self.playerVC = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:videoUrl]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[self.playerVC moviePlayer]];
        [[self.playerVC moviePlayer] prepareToPlay];
        
        [self presentMoviePlayerViewControllerAnimated:self.playerVC];
        [[self.playerVC moviePlayer] play];
    }
}

//当点击Done按键或者播放完毕时调用此函数
- (void) playVideoFinished:(NSNotification *)theNotification {
    MPMoviePlayerController *player = [theNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [self.playerVC dismissMoviePlayerViewControllerAnimated];
    self.playerVC = nil;
}

- (void)removeHistoryRecoder:(NSString *)recoderPath {
    NSError *error;
    NSFileManager *filerManager = [NSFileManager defaultManager];
    if ([filerManager fileExistsAtPath:recoderPath]) {
        BOOL result = [filerManager removeItemAtPath:recoderPath error:&error];
        if (result) {
            NSLog(@"_______视频删除成功————————");
            [self.historyRecoderArr removeObject:recoderPath];
            [[SaveDataManager shareSaveRecoder] removeRecoderVideoWithVideoId:@""];
            [self.recoderTab reloadData];
        } else {
            [Progress progressShowcontent:@"删除失败了" currView:self.view];
        }
    }
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
