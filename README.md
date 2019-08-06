# CCNetworkManager
    
## Usage 使用方法

## 1. 无自动缓存(GET与POST请求用法相同)

### 1.1 无缓存

```
[PPNetworkHelper GET:url parameters:nil success:^(id responseObject) {
        //请求成功
    } failure:^(NSError *error) {
        //请求失败
}];
```
### 1.2 无缓存,手动缓存
```
[PPNetworkHelper GET:url parameters:nil success:^(id responseObject) {
    //请求成功
        //手动缓存
    [PPNetworkCache setHttpCache:responseObject URL:url parameters:parameters];
    } failure:^(NSError *error) {
    //请求失败
}];
```
## 2. 自动缓存(GET与POST请求用法相同)
```
[PPNetworkHelper GET:url parameters:nil responseCache:^(id responseCache) {
        //加载缓存数据
    } success:^(id responseObject) {
        //请求成功
    } failure:^(NSError *error) {
        //请求失败
}];
```
## 3.单/多图片上传
```
[PPNetworkHelper uploadImagesWithURL:url
                    	parameters:@{@"参数":@"参数"}
                        	images:@[@"UIImage数组"]
                          name:@"文件对应服务器上的字段"
                      fileNames:@"文件名称数组"
                      imageType:@"图片的类型,png,jpeg" 
                      imageScale:@"图片文件压缩比 范围 (0.f ~ 1.f)"
                      progress:^(NSProgress *progress) {
                          //上传进度
                          NSLog(@"上传进度:%.2f%%",100.0 * progress.completedUnitCount/progress.totalUnitCount);
                      } success:^(id responseObject) {
                         //上传成功
                      } failure:^(NSError *error) {
                        //上传失败
}];
```
## 4.文件上传
```
[PPNetworkHelper uploadFileWithURL:url
                    parameters:@{@"参数":@"参数"}
                          name:@"文件对应服务器上的字段"
                      filePath:@"文件本地的沙盒路径"
                      progress:^(NSProgress *progress) {
                          //上传进度
                          NSLog(@"上传进度:%.2f%%",100.0 * progress.completedUnitCount/progress.totalUnitCount);
                      } success:^(id responseObject) {
                         //上传成功
                      } failure:^(NSError *error) {
                        //上传失败
}];
```
## 5.文件下载
```
NSURLSessionTask *task = [PPNetworkHelper downloadWithURL:url fileDir:@"下载至沙盒中的制定文件夹(默认为Download)" progress:^(NSProgress *progress) {
        //下载进度,如果要配合UI进度条显示,必须在主线程更新UI
        NSLog(@"下载进度:%.2f%%",100.0 * progress.completedUnitCount/progress.totalUnitCount);
    } success:^(NSString *filePath) {
        //下载成功
    } failure:^(NSError *error) {
        //下载失败
}];
    
//暂停下载,暂不支持断点下载
[task suspend];
//开始下载
[task resume];
```
## 6.网络状态监测
```
// 1.实时获取网络状态,通过Block回调实时获取(此方法可多次调用)
[PPNetworkHelper networkStatusWithBlock:^(PPNetworkStatus status) {
   switch (status) {
       case PPNetworkStatusUnknown:          //未知网络
           break;
       case PPNetworkStatusNotReachable:    //无网络
           break;
       case PPNetworkStatusReachableViaWWAN://手机网络
           break;
       case PPNetworkStatusReachableViaWiFi://WIFI
           break;
   }
}];
    
// 2.一次性获取当前网络状态
if (kIsNetwork) {          
   NSLog(@"有网络");
   if (kIsWWANNetwork) {                    
       NSLog(@"手机网络");
   }else if (kIsWiFiNetwork){
       NSLog(@"WiFi网络");
   }
} else {
   NSLog(@"无网络");
}
```
## 7. 网络缓存

### 7.1 自动缓存的逻辑

    1.从本地获取缓存(不管有无数据) --> 2.请求服务器数据 --> 3.更新本地数据

### 7.2 获取缓存总大小
```
NSInteger totalBytes = [PPNetworkCache getAllHttpCacheSize];
NSLog(@"网络缓存大小cache = %.2fMB",totalBytes/1024/1024.f);
```
### 7.3 删除所有缓存

`[PPNetworkCache removeAllHttpCache]`
