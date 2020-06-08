# Cordova Plugin BaiduOcr
================================

Cross-platform BaiduOcr for Cordova / PhoneGap.

Follows the [Cordova Plugin spec](https://cordova.apache.org/docs/en/latest/plugin_ref/spec.html), so that it works with [Plugman](https://github.com/apache/cordova-plugman).

## Installation

It is also possible to install via repo url directly ( unstable )

    cordova plugin add https://github.com/initMrD/cordova-plugin-baidu-ocr

注意：

1、首先需要到Baidu上注册并且申请并下载aip.license授权文件，具体操作查看：https://ai.baidu.com/docs#/OCR-Android-SDK/top

2、然后将android的aip.license拷贝到www/assets/android下面。

3、IOS将授权文件添加至XCode工程（配置为资源并拷贝，Target -> Build Phases -> Copy Bundle Resource 中添加该文件）

注意：官方说的是拷贝到android的app/src/main/assets下面，不用担心，此插件使用了hook钩子做文件拷贝，可以放心使用。


### Supported Platforms

- Android
- iOS


### Cordova Build Usage


### Using the plugin ###

A full example could be:

初始化（init）：
```js
    cordova.plugins.BaiduOcr.init(
        ()=>{
            console.log('init ok');
        },
        (error)=>{
            console.log(error)
        })
```
扫描身份证（scan id card）:
```js
    //默认使用的是本地质量控制，如果想使用拍照扫描的方式，可以修改参数为
    //nativeEnable:false,nativeEnableManual:false
    cordova.plugins.BaiduOcr.scan(
        {
            contentType:"IDCardBack",
            nativeEnable:true,
            nativeEnableManual:true
        },
        (result)=>{
            console.log(JSON.stringify(result));
        },
        (error)=>{
            console.log(error)
        });
```
通用文字:
```js
    //默认使用的是本地质量控制，如果想使用拍照扫描的方式，可以修改参数为
    //nativeEnable:false,nativeEnableManual:false
    cordova.plugins.BaiduOcr.scan(
        {
            contentType:"general",
            nativeEnable:true,
            nativeEnableManual:true
        },
        (result)=>{
            console.log(JSON.stringify(result));
        },
        (error)=>{
            console.log(error)
        });
```
行驶证:
```js
    //默认使用的是本地质量控制，如果想使用拍照扫描的方式，可以修改参数为
    //nativeEnable:false,nativeEnableManual:false
    cordova.plugins.BaiduOcr.scan(
        {
            contentType:"driving",
            nativeEnable:true,
            nativeEnableManual:true
        },
        (result)=>{
            console.log(JSON.stringify(result));
        },
        (error)=>{
            console.log(error)
        });
```
销毁本地控制模型（destroy）：
```js
    cordova.plugins.BaiduOcr.destroy(
        ()=>{
            console.log('destroy ok');
        },
        (error)=>{
            console.log(error)
        });
```
### ionic-native

install：

    npm i @initmrd/baidu-ocr --save

app.module.ts:
```
    import {BaiduOcr} from "@initmrd/baidu-ocr";
    @NgModule({
        providers: [
            BaiduOcr
        ]
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
            this.baiduOcr.init(
                () => {
                    console.log('init ok');
                },
            (error: any) => {
                console.log('init error');
                console.log(error);
            });
        }
        
        doDestroy() {
            this.baiduOcr.destroy()
                .then((result)=>{
                    
                })
                .catch((error)=>{
                    
                });
        }
        
        this.baiduOcr.scan(
            {
                contentType: 'IDCardBack',//IDCardBack/driving/general/
                nativeEnable: false,
                nativeEnableManual: false
            },
            (result: any) => {
                console.log(result);
                console.log(JSON.parse(result));
            },
            (error: any) => {
                console.log(error);
            }
        );
        
    }
```
