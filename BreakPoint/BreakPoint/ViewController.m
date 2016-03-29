//
//  ViewController.m
//  BreakPoint
//
//  Created by llbt on 16/3/29.
//  Copyright © 2016年 llbt. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLSessionDownloadDelegate>
{
    NSURLSessionDownloadTask * _task;
    NSData * _data;
    NSURLSession * _session;
    NSURLRequest * _request;
    UIProgressView * _pro;
    UIImageView * _imageView;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];

}

- (void)createUI {
    
    _imageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    _imageView.backgroundColor = [UIColor yellowColor];
    _imageView.center=self.view.center;
    [self.view addSubview:_imageView];
    
    _pro=[[UIProgressView alloc] initWithFrame:CGRectMake(_imageView.frame.origin.x, _imageView.frame.origin.y+350, 300, 40)];
    [self.view addSubview:_pro];
    
    UIButton * button=[[UIButton alloc] initWithFrame:CGRectMake(50, _imageView.frame.origin.y+400+20, 50, 40)];
    button.backgroundColor=[UIColor blueColor];
    [button setTitle:@"开始" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(ddLoad) forControlEvents:UIControlEventTouchUpInside];
    button.layer.borderWidth=1;
    button.layer.borderColor=[UIColor blueColor].CGColor;
    button.layer.cornerRadius=5;
    [self.view addSubview:button];
    
    UIButton * button1=[[UIButton alloc] initWithFrame:CGRectMake(140, _imageView.frame.origin.y+400+20, 50, 40)];
    button1.backgroundColor=[UIColor blueColor];
    [button1 setTitle:@"暂停" forState:UIControlStateNormal];
    [button1 addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    button1.layer.borderWidth=1;
    button1.layer.borderColor=[UIColor blueColor].CGColor;
    button1.layer.cornerRadius=5;
    [self.view addSubview:button1];
    
    UIButton * button2=[[UIButton alloc] initWithFrame:CGRectMake(230, _imageView.frame.origin.y+400+20, 50, 40)];
    button2.backgroundColor=[UIColor blueColor];
    [button2 setTitle:@"恢复" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(resume) forControlEvents:UIControlEventTouchUpInside];
    button2.layer.borderWidth=1;
    button2.layer.borderColor=[UIColor blueColor].CGColor;
    button2.layer.cornerRadius=5;
    [self.view addSubview:button2];
}

/**
 *  开始下载
 */
- (void) ddLoad{
    NSURLSessionConfiguration * config=[NSURLSessionConfiguration defaultSessionConfiguration];
    _session=[NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    
    NSURL *url=[NSURL URLWithString:@"http://image.baidu.com/search/down?tn=download&word=download&ie=utf8&fr=detail&url=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F140714%2F234975-140G4155Z571.jpg&thumburl=http%3A%2F%2Fimg1.imgtn.bdimg.com%2Fit%2Fu%3D3342737063%2C3964532796%26fm%3D21%26gp%3D0.jpg"];
    _request=[NSURLRequest requestWithURL:url];
    _task= [_session downloadTaskWithRequest:_request];
    NSLog(@"开始加载");
    [_task resume];
}

/**
 *  设置暂停
 */
- (void) pause{
    //暂停
    NSLog(@"暂停下载");
    [_task cancelByProducingResumeData:^(NSData *resumeData) {
        _data=resumeData;
    }];
    _task=nil;
}
/**
 *  继续下载
 */
- (void) resume{
    //恢复
    NSLog(@"恢复下载");
    if(!_data){
        NSURL *url=[NSURL URLWithString:@"http://image.baidu.com/search/down?tn=download&word=download&ie=utf8&fr=detail&url=http%3A%2F%2Fimg.taopic.com%2Fuploads%2Fallimg%2F140714%2F234975-140G4155Z571.jpg&thumburl=http%3A%2F%2Fimg1.imgtn.bdimg.com%2Fit%2Fu%3D3342737063%2C3964532796%26fm%3D21%26gp%3D0.jpg"];
        _request=[NSURLRequest requestWithURL:url];
        _task=[_session downloadTaskWithRequest:_request];
    }else{
        _task=[_session downloadTaskWithResumeData:_data];
    }
    [_task resume];
}


#pragma mark - delegate

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSLog(@"下载完成");
    //拿到caches文件夹的路径
    NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)lastObject];
    
    //拿到caches文件夹和文件名
    NSString *file = [caches stringByAppendingPathComponent:downloadTask.response.suggestedFilename];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    //移动下载好的文件到指定的文件夹
    [manager moveItemAtPath:location.path toPath:file error:nil];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _imageView.image = [UIImage imageWithContentsOfFile:file];

        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:nil message:@"下载完成" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    }) ;
    
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    CGFloat progress = (totalBytesWritten*1.0) / totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        _pro.progress=progress;
        
    }) ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
