module.exports = function (ctx) {
    // make sure android/ios platform is part of build
    //确保在android/ios平台下使用
    if (ctx.opts.platforms.indexOf('android') < 0 && ctx.opts.platforms.indexOf('ios') < 0) {
        return;
    }

    var fs = ctx.requireCordovaModule('fs'),
        path = ctx.requireCordovaModule('path'),
        deferral = ctx.requireCordovaModule('q').defer();

    var platformRoot, assetsRoot, license_from, license_to;
    if (ctx.opts.platforms.indexOf('ios') < 0) {
        console.log("android");
        //android项目根路径
        platformRoot = path.join(ctx.opts.projectRoot, 'platforms/android');
        //android项目的assets目录
        assetsRoot = platformRoot + '/app/src/main/assets';
        //android证书源路径
        license_from = assetsRoot + '/www/assets/android/aip.license';
        //android证书目标路径
        license_to = assetsRoot + '/aip.license';
    } else {
        console.log("ios");
        var xmlFile = path.join(ctx.opts.projectRoot, 'config.xml');
        var configData = fs.readFileSync(xmlFile, 'utf8');
        var nameStart = (configData.indexOf('<name>') + 6);
        var nameEnd = configData.indexOf('</name>');
        var iosProjDir = configData.slice(nameStart, nameEnd);
        //ios项目根路径
        platformRoot = path.join(ctx.opts.projectRoot, 'platforms/ios');
        //ios项目的assets目录
        assetsRoot = platformRoot + '/' + iosProjDir + "/Resources";
        //ios证书源路径
        license_from = platformRoot + '/www/assets/ios/aip.license';
        //ios证书目标路径
        license_to = assetsRoot + '/aip.license';
    }


    //如果证书源存在，则进行文件拷贝
    if (fs.existsSync(platformRoot) && fs.existsSync(license_from)) {
        var readStream = fs.createReadStream(license_from);
        var writeStream = fs.createWriteStream(license_to);

        //拷贝
        readStream.pipe(writeStream);
        console.log('拷贝证书成功' + license_from + "," + license_to);
        deferral.resolve();
    } else {
        if (ctx.opts.platforms.indexOf('android') > 0) {
            console.log('未找到证书文件,请将aip.license证书拷贝到assets/android');
            deferral.reject('未找到证书文件,请将aip.license证书拷贝到assets/android下');
        } else {
            console.log('未找到证书文件,请将aip.license证书拷贝到assets/ios');
            deferral.reject('未找到证书文件,请将aip.license证书拷贝到assets/ios');
        }
    }

    return deferral.promise;
};
