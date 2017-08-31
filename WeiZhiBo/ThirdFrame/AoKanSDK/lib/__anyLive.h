#ifndef __LIBANYLIVE_H__

#import <VideoToolbox/VideoToolbox.h>
#import <CoreData/CoreData.h>
#import <CoreMedia/CMSampleBuffer.h>

#define UPLOAD_STATUS_CONNECTED 	 1
#define UPLOAD_STATUS_UNKNOW		-1
#define UPLOAD_STATUS_INNERERR   	-2
#define UPLOAD_STATUS_DISCONNECT 	-3

#define RTPENCAP_INCLUDED

#ifdef __cplusplus
extern "C" {
#endif

int getVersion();

//
// TRACE funcs
//
void openTrace(NSString * addr, int trace_grade);
void closeTrace();

void printTrace(NSString * info);

//
//
//
int anylive_setopt(int opt, int param, NSString * str, void * ptr);
int anylive_getopt(int opt, int param, NSString * str, void * ptr);

//
// encoder funcs
//
void * create_video_encoder(int width,
                            int height,
                            int frames,
                            int keyframes,
                            int bitrate,
                            unsigned int printmask);
void release_video_encoder(void * enc);
    
void video_encode(void * enc, CMSampleBufferRef sampleBuffer);

void * create_audio_encoder(int samplerate, 
							int channels, 
							int bitrate,
							unsigned int printmask);
void release_audio_encoder(void * enc);

void audio_encode(void * enc, CMSampleBufferRef sampleBuffer);

//
// upload funcs
//
void * create_uploader(NSString * addr, NSString * chann, NSString * upldpwd, bool open_queue);
void release_uploader(void * uploader);

void video_attach_uploader(void * enc, void * uploader);
void audio_attach_uploader(void * enc, void * uploader);

struct upload_info_s
{
	int status;//上传状态
	int speed;//上传速率
	int overflow;//溢出率
};
void uploader_info(void * uploader, struct upload_info_s * s);

//
// add @ 2016/09/18
//
struct upload_info_ex
{
	struct upload_info_s s;
	
	int buffer;//上传延迟
};

void uploader_info_ex(void * uploader, void * p);

#ifdef __cplusplus
}
#endif

#endif
