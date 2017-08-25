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
#import "UserData.h"

#import "NotificationManager.h"
#import "VideoUploader.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

@interface HistoryRecoderViewController ()<UITableViewDelegate, UITableViewDataSource, FileUploaderDelegate>{
    BOOL uploading;
}
@property (strong, nonatomic) IBOutlet UITableView *recoderTab;
@property (strong, nonatomic) IBOutlet UILabel *noDataLable;
@property (strong, nonatomic) IBOutlet UIView *noDataView;

@property (strong, nonatomic) MPMoviePlayerViewController *playerVC;
@property (strong, nonatomic) FileUploader *uploader;
@property (strong, nonatomic) dispatch_queue_t queue;

@property (strong, nonatomic) NSMutableArray *uploadingArr;

@end

static NSString *cellId = @"cellIdentifiler";

@implementation HistoryRecoderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initData];
    [self initTableView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appEnterBack) name:@"enterBack" object:nil];

}

- (void)appEnterBack {//app进入后台通知
    if (uploading) {
        NSString *alerStr = [NSString stringWithFormat:@"您有%ld短视频正在后台上传",_uploadingArr.count];
        [NotificationManager registerLocalNotificationAlertBody:alerStr description:@""];
    }
}


- (void)initData {
   
    _queue = dispatch_queue_create("com.lysongzi.concurrent", DISPATCH_QUEUE_CONCURRENT);
    _uploadingArr = [NSMutableArray arrayWithCapacity:5];
    
    if (_historyRecoderArr.count>0) {
        self.noDataView.hidden = YES;
    } else {
        self.noDataView.hidden = NO;
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
    NSArray *selClassArr = [[SaveDataManager shareSaveRecoder] getVideoClassesWithVideoId:videoId];
    
    cell.dotBtn.selected = uploadState;
    cell.uploadBtn.selected = uploadState;
    cell.titleLabel.text = titleStr;
    cell.classLabel.attributedText = [self getVideoClassesWithVideoId:videoId withLabelWidth:CGRectGetWidth(cell.classLabel.frame)];
    @WeakObj(cell)
    cell.cellBtnAction = ^(BOOL remove) {
        if ( remove ) {//视频删除
            [self removeHistoryRecoder:self.historyRecoderArr[indexPath.row]];
            
        } else {//视频上传
            if ( cellWeak.uploadBtn.selected) {
                return ;
            }
            
            [self getUploadShortVideoUrlWithClasses:selClassArr videoPath:videoPath playTitle:titleStr inCell:cellWeak];
        }
    };
    
    [self logVideoSize:videoPath];
    
    return cell;
}


#pragma mark - 上传视频

- (void)uploadVideo:(NSString *)url videoPath:(NSString *) filePath withCell:(HistoryRecoderTableViewCell *)cell {
//    _uploader = [FileUploader shareFileUploader];
//    _uploader.delegate = self;
//    [_uploader uploadFileAtPath:filePath];
    
    
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    NSString *fileStr = [filePath lastPathComponent];
    cell.uploadRate.hidden = NO;

    [WZBNetServiceAPI postUploadFileWithURL:url paramater:nil fileData:data nameOfData:@"test" nameOfFile:fileStr mimeOfType:@"video/mp4" progress:^(NSProgress *uploadProgress) {
        uploading = YES;
        NSString *rateStr = [NSString stringWithFormat:@"%.0f %%",uploadProgress.fractionCompleted*100];
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.uploadRate.text = rateStr;
        });
        NSLog(@"upload-progress===%@",[uploadProgress description]);
    } sucess:^(id responseObject) {
//        NSLog(@"_________uploaded success______/n %@",responseObject);
        uploading = NO;
        cell.uploadRate.hidden = YES;
        cell.uploadBtn.selected = YES;
        cell.dotBtn.selected = YES;
        [self fileUploadingState:YES fileName:filePath];
        NSArray *uploadArr = [_uploadingArr mutableCopy];
        for (NSDictionary *videoInfo in uploadArr) {
            if ([videoInfo[VIDEO_PATH] isEqualToString:filePath]) {
                [self uploadVideoUploadState:videoInfo[VIDEO_ID]];
                [_uploadingArr removeObject:videoInfo];
                break;
            }
        }
        
    } failure:^(NSError *error) {
        uploading = NO;
//        NSLog(@"_________uploaded filad______ /n  %@",[error description]);
        cell.uploadRate.hidden = YES;
        [self fileUploadingState:NO fileName:filePath];
    }];
//    [self upload:url filename:@"video" mimeType:@"video/mp4" data:data filePath:filePath];
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


- (void)getUploadShortVideoUrlWithClasses:(NSArray *)selClassArr videoPath:(NSString *)videopath playTitle:(NSString *)playTitle inCell:(HistoryRecoderTableViewCell *)cell {
    NSDictionary *videoInfo = @{VIDEO_PATH:videopath,
                              UPLOAD_STATE:[NSNumber numberWithBool:NO]};
    BOOL uploadState = [[VideoUploader shareUploader] uploadingOfVideo:videoInfo];
    if (uploadState) {
        
        [VideoUploader shareUploader].uploadProgress = ^ (NSProgress *progress, NSDictionary *videoInfo) {
            uploading = YES;
            NSString *rateStr = [NSString stringWithFormat:@"%.0f %%",progress.fractionCompleted*100];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.uploadRate.text = rateStr;
            });
        };
        
        [VideoUploader shareUploader].uploadResult = ^ (BOOL result, NSDictionary *videoInfo){
            uploading = NO;
            cell.uploadRate.hidden = YES;
            cell.uploadBtn.selected = YES;
            cell.dotBtn.selected = YES;
            [self fileUploadingState:result fileName:videopath];
        };
        
    }
    
}

- (void)uploadVideoWithClasses:(NSArray *)selClassArr videoPath:(NSString *)videopath playTitle:(NSString *)playTitle inCell:(HistoryRecoderTableViewCell *)cell {
    NSString *classIdStr = @"";
    for (NSDictionary *classInfo in selClassArr) {
        if (classIdStr.length == 0) {
            classIdStr = [NSString stringWithFormat:@"%@",classInfo[@"classId"]];
            
        } else {
            classIdStr = [NSString stringWithFormat:@"%@,%@",classIdStr, classInfo[@"classId"]];
        }
    }

    NSDictionary *videoInfo = @{VIDEO_PATH:videopath,
                                UPLOAD_STATE:[NSNumber numberWithBool:NO]};
    BOOL uploadState = [[VideoUploader shareUploader] uploadingOfVideo:videoInfo];
    NSDictionary *parameter = @{@"userId":[UserData getUser].userID,
                                @"classIdList":classIdStr,
                                @"schoolId":self.schoolId,
                                @"vodName":playTitle,
                                @"vodDesc":@"录播小视频"};
    
    [[VideoUploader shareUploader] getUploadShortVideoUrlWithParamater:parameter withVideoInfo:videoInfo];
    
    if (!uploadState) {
        
        [VideoUploader shareUploader].uploadProgress = ^ (NSProgress *progress, NSDictionary *videoInfo) {
            uploading = YES;
            NSString *rateStr = [NSString stringWithFormat:@"%.0f %%",progress.fractionCompleted*100];
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.uploadRate.text = rateStr;
            });
        };
        
        [VideoUploader shareUploader].uploadResult = ^ (BOOL result, NSDictionary *videoInfo){
            uploading = NO;
            cell.uploadRate.hidden = YES;
            cell.uploadBtn.selected = YES;
            cell.dotBtn.selected = YES;
            [self fileUploadingState:result fileName:videopath];
        };
    }

}


- (void)getUploadShortVideoUrlWithClasses:(NSArray *)selClassArr videoPath:(NSString *)videopath playTitle:(NSString *)playTitle inCell:(HistoryRecoderTableViewCell *)cell{//获取视频的上传路径
    NSString *classIdStr = @"";
    for (NSDictionary *classInfo in selClassArr) {
        if (classIdStr.length == 0) {
            classIdStr = [NSString stringWithFormat:@"%@",classInfo[@"classId"]];

        } else {
            classIdStr = [NSString stringWithFormat:@"%@,%@",classIdStr, classInfo[@"classId"]];
        }
    }
    
    if (_uploadingArr.count == 5) {
        [Progress progressShowcontent:@"同时最多只能上传五个视频" currView:self.view];
        return;
    }
    
    dispatch_async(_queue, ^{
        NSDictionary *parameter = @{@"userId":[UserData getUser].userID,
                                    @"classIdList":classIdStr,
                                    @"schoolId":self.schoolId,
                                    @"vodName":playTitle,
                                    @"vodDesc":@"录播小视频"};
        
        [WZBNetServiceAPI getShortVideoUplaodPathWithParameters:parameter success:^(id reponseObject) {
            if ([reponseObject[@"status"] integerValue] == 1) {
                NSString *videoId = [NSString safeString:reponseObject[@"data"][@"vodId"]];
                NSString *url = [NSString safeString:reponseObject[@"data"][@"uploadUrl"]];

                if (url.length>0) {
                    [_uploadingArr addObject:@{VIDEO_ID:videoId,
                                               VIDEO_PATH:videopath,
                                               UPLOAD_URL:url,
                                               UPLOAD_STATE:[NSNumber numberWithBool:NO]}];

                    [self uploadVideo:url videoPath:videopath withCell:cell];
                } else {
                    [Progress progressShowcontent:@"视频上传失败，请稍后重试" currView:self.view];
                }
            } else {
                [Progress progressShowcontent:reponseObject[@"message"] currView:self.view];
            }
            
        } failure:^(NSError *error) {
            [KTMErrorHint showNetError:error inView:self.view];
            
        }];
 
    });
}

- (void)uploadVideoUploadState:(NSString *)videoId {//上传视频上传的状态
    
    NSDictionary *parameter = @{@"userId":[UserData getUser].userID,
                                @"vodId":videoId};
    [WZBNetServiceAPI getUploadVideoUpStateWithParameters:parameter success:^(id reponseObject) {
        
        if ([reponseObject[@"status"] integerValue]) {
            [Progress progressShowcontent:@"上传成功" currView:self.view];
        } else {
            
            [Progress progressShowcontent:reponseObject[@"message"] currView:self.view];
        }
    } failure:^(NSError *error) {
        [KTMErrorHint showNetError:error inView:self.view];
        
    }];
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
//            NSLog(@"_______视频删除成功————————");
            [Progress progressShowcontent:@"删除成功" currView:self.view];
            [self.historyRecoderArr removeObject:recoderPath];
            NSString *videoName = [recoderPath componentsSeparatedByString:@"/"].lastObject;
            if (videoName.length>0) {
                NSString *videoTag = [videoName componentsSeparatedByString:@"."].firstObject;
                [[SaveDataManager shareSaveRecoder] removeRecoderVideoWithVideoId:videoTag];
            }

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
