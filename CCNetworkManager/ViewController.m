//
//  ViewController.m
//  CCNetworkManager
//
//  Created by WeiPeng on 16/8/12.
//  Copyright © 2016 WeiPeng. All rights reserved.
//

#import "ViewController.h"
#import "CCNetworkManager.h"
#import "CCHTTPRequest.h"
#import "AFNetworking.h"


#ifdef DEBUG
#define CCLog(...) printf("[%s] %s [第%d行]: %s\n", __TIME__ ,__PRETTY_FUNCTION__ ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define CCLog(...)
#endif

#define CCMaxYOfView(view) CGRectGetMaxY(view.frame)
#define CCMaxXOfView(view) CGRectGetMaxX(view.frame)
#define CCMinYOfView(view) CGRectGetMinY(view.frame)
#define CCMinXOfView(view) CGRectGetMinX(view.frame)

static NSString *const dataUrl = @"http://api.budejie.com/api/api_open.php";
static NSString *const downloadUrl = @"http://wvideo.spriteapp.cn/video/2016/0328/56f8ec01d9bfe_wpd.mp4";

@interface ViewController ()
@property (weak, nonatomic)  UITextView *networkDataView;
@property (weak, nonatomic)  UITextView *cacheDataView;
@property (weak, nonatomic)  UILabel *cacheStatusLabel;
@property (weak, nonatomic)  UISwitch *cacheSwitch;
@property (weak, nonatomic)  UIProgressView *progressView;
@property (weak, nonatomic)  UIButton *downloadButton;

/** 是否开启缓存*/
@property (nonatomic, assign, getter=isCache) BOOL cache;

/** 是否开始下载*/
@property (nonatomic, assign, getter=isDownload) BOOL download;
@end

@implementation ViewController

- (void)setupSubviews{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITextView *networkDataView = [[UITextView alloc] initWithFrame:CGRectMake(20, 100, [UIScreen mainScreen].bounds.size.width - 40, 100)];
    networkDataView.layer.borderWidth = 1.f;
    self.networkDataView = networkDataView;
    [self.view addSubview:networkDataView];
    
    UITextView *cacheDataView = [[UITextView alloc] initWithFrame:CGRectMake(20, CCMaxYOfView(networkDataView) + 20, [UIScreen mainScreen].bounds.size.width - 40, 100)];
    cacheDataView.layer.borderWidth = 1.f;
    self.cacheDataView = cacheDataView;
    [self.view addSubview:cacheDataView];
    
    UILabel *cacheStatusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, CCMaxYOfView(cacheDataView) + 20, 100, 44)];
    cacheStatusLabel.layer.borderWidth = 1.f;
    self.cacheStatusLabel = cacheStatusLabel;
    [self.view addSubview:cacheStatusLabel];
    
    UISwitch *cacheSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CCMaxXOfView(cacheStatusLabel) + 20, CCMinYOfView(cacheStatusLabel), 100, 44)];
    self.cacheSwitch = cacheSwitch;
    [self.view addSubview:cacheSwitch];
    
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(20, CCMaxYOfView(cacheSwitch) + 30, [UIScreen mainScreen].bounds.size.width - 40, 20)];
    self.progressView = progressView;
    [self.view addSubview:progressView];
    
    UIButton *downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(100, CCMaxYOfView(progressView) + 20, 100, 44)];
    [downloadButton addTarget:self action:@selector(downloadButtonDidClicked:) forControlEvents:UIControlEventTouchUpInside];
    downloadButton.backgroundColor = [UIColor blueColor];
    [downloadButton setTitle:@"Download" forState:UIControlStateNormal];
    self.downloadButton = downloadButton;
    [self.view addSubview:downloadButton];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //setup subviews
    [self setupSubviews];
    
    /**
     设置网络请求参数的格式:默认为二进制格式
     PPRequestSerializerJSON(JSON格式),
     PPRequestSerializerHTTP(二进制格式)
     
     设置方式 : [PPNetworkHelper setRequestSerializer:PPRequestSerializerHTTP];
     */
    
    /**
     设置请求头 : [PPNetworkHelper setValue:@"value" forHTTPHeaderField:@"header"];
     */
    
    // 开启日志打印
    [CCNetworkManager openLog];
    
    // 获取网络缓存大小
    double cacheDataSize = [CCNetworkCache getAllHttpCacheSize]/1024.f;
    CCLog(@"网络缓存大小cache = %fKB",cacheDataSize);
    
    // 清理缓存 [PPNetworkCache removeAllHttpCache];
    
    // 实时监测网络状态
    [self monitorNetworkStatus];
    
    /*
     * 获取当前网络状态
     */
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getCurrentNetworkStatus];
    });
    
    [self CCHTTPRequestLayerDemo];
    
}

- (void)CCHTTPRequestLayerDemo
{
    // 登陆
    [CCHTTPRequest getLoginWithParameters:@"参数" success:^(id response) {
        
    } failure:^(NSError *error) {
        
    }];
    
    // 退出
    [CCHTTPRequest getExitWithParameters:@"参数" success:^(id response) {
        
    } failure:^(NSError *error) {
        
    }];
}

#pragma  mark - 获取数据请求示例 GET请求自动缓存与无缓存
- (void)getData:(BOOL)isOn url:(NSString *)url
{
    
    NSDictionary *para = @{ @"a":@"list", @"c":@"data",@"client":@"iphone",@"page":@"0",@"per":@"10", @"type":@"29"};
    // 自动缓存
    if(isOn)
    {
        self.cacheStatusLabel.text = @"缓存打开";
        self.cacheSwitch.on = YES;
        [CCNetworkManager GET:url parameters:para responseCache:^(id responseCache) {
            // 1.先加载缓存数据
            self.cacheDataView.text = [self jsonToString:responseCache];
            
        } success:^(id responseObject) {
            // 2.再请求网络数据
            self.networkDataView.text = [self jsonToString:responseObject];
        } failure:^(NSError *error) {
            
        }];
        
    }
    // 无缓存
    else
    {
        self.cacheStatusLabel.text = @"缓存关闭";
        self.cacheSwitch.on = NO;
        self.cacheDataView.text = @"";
        
        [CCNetworkManager GET:url parameters:para success:^(id responseObject) {
            self.networkDataView.text = [self jsonToString:responseObject];
        } failure:^(NSError *error) {
            
        }];
        
    }
    
}

#pragma mark - 实时监测网络状态
- (void)monitorNetworkStatus
{
    // 网络状态改变一次, networkStatusWithBlock就会响应一次
    [CCNetworkManager networkStatusWithBlock:^(CCNetworkStatusType networkStatus) {
        
        switch (networkStatus) {
                // 未知网络
            case CCNetworkStatusUnknown:
                // 无网络
            case CCNetworkStatusNotReachable:
                self.networkDataView.text = @"没有网络";
                [self getData:YES url:dataUrl];
                CCLog(@"无网络,加载缓存数据");
                break;
                // 手机网络
            case CCNetworkStatusReachableViaWWAN:
                // 无线网络
            case CCNetworkStatusReachableViaWiFi:
                [self getData:[[NSUserDefaults standardUserDefaults] boolForKey:@"isOn"] url:dataUrl];
                CCLog(@"有网络,请求网络数据");
                break;
        }
        
    }];
    
}

#pragma mark - 获取当前最新网络状态
- (void)getCurrentNetworkStatus
{
    if (kIsNetwork) {
        CCLog(@"有网络");
        if (kIsWWANNetwork) {
            CCLog(@"手机网络");
        }else if (kIsWiFiNetwork){
            CCLog(@"WiFi网络");
        }
    } else {
        CCLog(@"无网络");
    }

}

#pragma mark - 下载
- (void)downloadButtonDidClicked:(UIButton *)sender{
    static NSURLSessionTask *task = nil;
    
    if (!self.isDownload) {
        self.download = YES;
        [self.downloadButton setTitle:@"Cancel Download" forState:UIControlStateNormal];
        
        task = [CCNetworkManager downloadWithURL:downloadUrl fileDir:@"Download" progress:^(NSProgress *progress) {
            CGFloat status = 100.f * progress.completedUnitCount / progress.totalUnitCount;
            self.progressView.progress = status / 100.f;
            
            CCLog(@"Downloading: %.2f%%,,%@", status, [NSThread currentThread]);
        } success:^(NSString *filePath) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Download completed!"
                                                                                     message:[NSString stringWithFormat:@"file path:%@", filePath] preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alertController animated:YES completion:^{
                
            }];
            
            
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([action.title containsString:@"OK"]) {
                    [self dismissViewControllerAnimated:alertController completion:^{
                        
                    }];
                }
                
            }];
            
            [alertController addAction:confirmAction];
            
            
            [self.downloadButton setTitle:@"Download" forState:UIControlStateNormal];
            CCLog(@"filepath = %@", filePath);
            
        } failure:^(NSError *error) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Download Failed!"
                                                                                     message:[NSString stringWithFormat:@"ERROR:%@", error] preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if ([action.title containsString:@"OK"]) {
                    [self dismissViewControllerAnimated:alertController completion:^{
                        
                    }];
                }
                
            }];
            
            [alertController addAction:confirmAction];
            [self presentViewController:alertController animated:YES completion:^{
                
            }];
            CCLog(@"ERROR:%@", error);
        }];
    } else {
        self.download = NO;
        [task suspend];
        self.progressView.progress = 0;
        [self.downloadButton setTitle:@"Download" forState:UIControlStateNormal];
    }
}

/**
 *  json转字符串
 */
- (NSString *)jsonToString:(NSDictionary *)dic
{
    if(!dic){
        return nil;
    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

@end
