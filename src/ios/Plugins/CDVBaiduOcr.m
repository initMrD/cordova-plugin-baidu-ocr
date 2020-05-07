//
//  CDVBaiduOcr.m
//  myTestCordova
//
//  Created by mac on 2018/6/4.
//

#import <Cordova/CDV.h>
#import "CDVBaiduOcr.h"
#import <objc/runtime.h>
#import <AipOcrSdk/AipOcrSdk.h>

BOOL hasGotToken = NO;

@implementation CDVBaiduOcr

- (void)init:(CDVInvokedUrlCommand *)command {

    NSMutableDictionary* resultDic = [NSMutableDictionary dictionary];

    //     授权方法1：在此处填写App的Api Key/Secret Key
    //    [[AipOcrService shardService] authWithAK:@"AK" andSK:@"SK"];


    // 授权方法2（更安全）： 下载授权文件，添加至资源
    NSString *licenseFile = [[NSBundle mainBundle] pathForResource:@"aip" ofType:@"license"];
    NSData *licenseFileData = [NSData dataWithContentsOfFile:licenseFile];
    if(!licenseFileData) {
        //[[[UIAlertView alloc] initWithTitle:@"授权失败" message:@"授权文件不存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show];

        resultDic[@"code"] = @(-1);
        resultDic[@"message"] = @"授权文件不存在";
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDic];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    [[AipOcrService shardService] authWithLicenseFileData:licenseFileData];

    //获取token回调
    [[AipOcrService shardService] getTokenSuccessHandler:^(NSString *token) {
        NSLog(@"获取token成功: %@",token);
        hasGotToken = YES;
    } failHandler:^(NSError *error) {
        NSLog(@"获取token失败: %@",error);
        resultDic[@"code"] = @(-1);
        resultDic[@"message"] = @"获取token失败";
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDic];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        hasGotToken = NO;
    }];

}

- (void)scan:(CDVInvokedUrlCommand *)command {

    NSMutableDictionary* resultDic = [NSMutableDictionary dictionary];
    NSDictionary *param = [command argumentAtIndex:0];

    NSMutableString *contentType = nil;
    BOOL nativeEnable = YES;

    //默认为本地质量扫描正面
    CardType cardType = CardTypeLocalIdCardFont;

    //必须初始化
    if(!hasGotToken) {
        resultDic[@"code"] = @(-1);
        resultDic[@"message"] = @"please init ocr";
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDic];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    //如果未找到contentType属性则直接返回错误
    if(param == nil || param[@"contentType"] == nil) {
        resultDic[@"code"] = @(-1);
        resultDic[@"message"] = @"contentType is null";
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsDictionary:resultDic];

        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }

    //获取扫描类型，正面还是反面
    contentType = param[@"contentType"];
    //获取是否使用本地质量控制
    nativeEnable = param[@"nativeEnable"];

    if([contentType isEqualToString:@"IDCardFront"]) {
        if(nativeEnable){
            cardType = CardTypeLocalIdCardFont;
        }else{
            cardType = CardTypeIdCardFont;
        }
        [self takePhotoCard:cardType command:command resultDic:resultDic];
        
    } else if ([contentType isEqualToString:@"IDCardBack"]) {
        if(nativeEnable){
            cardType = CardTypeLocalIdCardBack;
        }else{
            cardType = CardTypeIdCardBack;
        }
        [self takePhotoCard:cardType command:command resultDic:resultDic];
    } else{
        [self takePhotoGeneral:contentType command:command resultDic:resultDic];
    }
    
}


-(void)takePhotoGeneral:(NSMutableString *)contentType
                command:(CDVInvokedUrlCommand *)command
              resultDic:(NSMutableDictionary *) resultDic{
    UIViewController * vc = [AipGeneralVC ViewControllerWithHandler:^(UIImage *image){
        [self scanGeneral:contentType image:image command:command resultDic:resultDic];
    }];
    [self.viewController presentViewController:vc animated:YES completion:nil];
}

- (void)takePhotoCard:(CardType)cardType
    command:(CDVInvokedUrlCommand *)command
    resultDic:(NSMutableDictionary *) resultDic{
    UIViewController * vc =
    [AipCaptureCardVC ViewControllerWithCardType:cardType andImageHandler:^(UIImage *image){
        [self scanId:image command:command];
    }];
    [self.viewController presentViewController:vc animated:YES completion:nil];
}

- (void)scanGeneral:(NSMutableString *)contentType
              image:(UIImage *)image
            command:(CDVInvokedUrlCommand *)command
            resultDic:(NSMutableDictionary*) resultDic{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.viewController dismissViewControllerAnimated:YES completion:nil];
    });
    if([contentType isEqualToString:@"general"]){
        [[AipOcrService shardService] detectTextBasicFromImage:image withOptions:nil successHandler: ^(id result){
            [self doData:result command:command];
        } failHandler:^(NSError *error){
            [self doError:error command:command];
        }];
    } else if([contentType isEqualToString:@"driving"]){
        [[AipOcrService shardService] detectVehicleLicenseFromImage:image withOptions:nil successHandler: ^(id result){
            [self doData:result command:command];
        } failHandler:^(NSError *error){
            NSMutableString *ct = [NSMutableString stringWithFormat:@"%@",@"highGeneral"];;
            [self scanGeneral:ct image:image command:command resultDic:resultDic];
        }];
    } else if([contentType isEqualToString:@"highGeneral"]){
        [[AipOcrService shardService] detectTextAccurateBasicFromImage:image withOptions:nil successHandler: ^(id result){
            [self doData:result command:command];
        } failHandler:^(NSError *error){
            NSMutableString *ct = [NSMutableString stringWithFormat:@"%@",@"general"];;
            [self scanGeneral:ct image:image command:command resultDic:resultDic];
        }];
    }
    
}
- (void)doData:(id) result
       command:(CDVInvokedUrlCommand *)command{
    NSLog(@"%@", result);
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    data[@"words_result"] = result[@"words_result"];
    data[@"words_result_num"] = result[@"words_result_num"];
    data[@"log_id"] = result[@"log_id"];
    NSError * error = nil;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonStr];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(void)doError:(NSError *)error
       command:(CDVInvokedUrlCommand *)command{
    NSLog(@"读取失败：%@",error);
    NSMutableDictionary* resultDic = [NSMutableDictionary dictionary];
    resultDic[@"code"] = @(-1);
    resultDic[@"message"] = @"读取失败";
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:resultDic options:NSJSONWritingPrettyPrinted error:&error];
    NSString * jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:jsonStr];

    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

- (void)scanId:(UIImage *)image
       command:(CDVInvokedUrlCommand *)command{
    
    [[AipOcrService shardService] detectIdCardFrontFromImage:image withOptions:nil successHandler:^(id result){
        NSLog(@"%@", result);
        [self doData:result command:command];

    } failHandler:^(NSError *error){
        [self doError:error command:command];
    }];
}

- (void)destroy:(CDVInvokedUrlCommand *)command {
    return;
}

@end
