# Cordova Plugin BaiduOcr

## 安装

1、首先需要到Baidu上注册并且申请并下载aip.license授权文件，具体操作查看：https://ai.baidu.com/docs#/OCR-Android-SDK/top

2、然后将android和ios的aip.license分别拷贝到src/assets/android和src/assets/android下面。

注意：官方说的是拷贝到android的app/src/main/assets下面，不用担心，此插件使用了hook钩子做文件拷贝，可以放心使用。


### 支持平台

- Android
- iOS

### 在Ionic上使用

install：
```
    npm i @initmrd/baidu-ocr --save
```
```
    cordova plugin add https://github.com/initMrD/cordova-plugin-baidu-ocr
```

app.module.ts:
```
    import {BaiduOcr} from "@initmrd/baidu-ocr";
    @NgModule({
        ...
        providers: [
            BaiduOcr
        ]
        ...
    })
    export class AppModule {}
```
view.page.ts:
```
    import {BaiduOcr} from "@initmrd/baidu-ocr";
    @IonicPage()
    @Component({
        selector: 'view-page',
        templateUrl: 'view-page.html'
    })
    export class ViewPage {
        constructor(private baiduOcr: BaiduOcr) {}
        
        doInit() {
            this.baiduOcr.init()
                .then((result)=>{
                    
                })
                .catch((error)=>{
                    
                });
        }
        
        doDestroy() {
            this.baiduOcr.destroy()
                .then((result)=>{
                    
                })
                .catch((error)=>{
                    
                });
        }
        
        doScan() {
            this.baiduOcr.scanId({
                    contentType: 'IDCardFront', // IDCardBack|driving|general
                    nativeEnable: true, 
                    nativeEnableManual: true})
                .then((result)=>{
                    
                })
                .catch((error)=>{
                    
                });
        }
        
    }
```
