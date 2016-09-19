//
//  CatEye.mm
//  xiaochu
//
//  Created by zhaolu on 16/9/8.
//
//
#import "cocos2d.h"
#import "CCLuaEngine.h"
#import "CCLuaBridge.h"
#import "JSONKit.h"

#import "AppStorePay.h"
#import "CatEye.h"

using namespace cocos2d;

@implementation CatEye
@synthesize waitView = _waitView;

static CatEye* catEyeInstance = nil;

- (id)init
{
    self = [super init];
    if(!self)
    {
        return nil;
    }
    CGRect rect = [UIScreen mainScreen].applicationFrame; //获取屏幕大小
    _waitView = [[UIActivityIndicatorView alloc] initWithFrame:rect];//定义图标大小，此处为32x32
    [self.waitView setCenter:CGPointMake(rect.size.width/2,rect.size.height/2)];//根据屏幕大小获取中心点
    [self.waitView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];//设置图标风格，采用灰色的，其他还有白色设置
    [self.waitView setBackgroundColor:[ UIColor colorWithWhite: 0.0 alpha: 0.5 ]];
    if ([[UIDevice currentDevice] systemVersion].floatValue<=4.4) {
        [self.waitView setBounds:CGRectMake(0, 0, 50, 50)];
    }
    //[self.view addSubview:waitView];//添加该waitView
    return self;
}

+ (CatEye*) sharedInstance{
    if (!catEyeInstance) {
        catEyeInstance = [[CatEye alloc]init];
    }
    return catEyeInstance;
}

+ (NSString*)eye_getElapsedTime:(NSDictionary*)dict {
    NSTimeInterval timeInterval = [[NSProcessInfo processInfo] systemUptime];
    NSString *timeStr = [NSString stringWithFormat:@"%.1f",timeInterval];
    return timeStr;
}

+ (void) eye_pay:(NSDictionary*)dict{
    [[CatEye sharedInstance]setHandlerId:((int)[[dict objectForKey:@"callFunc"] intValue])];
    [[CatEye sharedInstance]setMoneyCount:((int)[[dict objectForKey:@"moneyCount"] intValue])];
    NSString* productId = [dict objectForKey:@"productId"];
    [[AppStorePay sharedObject]purchase:productId];
    
    [[CatEye sharedInstance]setWaiting:true];
}

+ (void) eye_saveUserData:(NSDictionary*)dict{
    NSString* jsonStr = [dict objectForKey:@"_jsonStr"];
    
    NSLog(@"eye_saveUserData %@",jsonStr);
    //组装jsonStr
    NSMutableDictionary* postDict = [NSMutableDictionary dictionary];
    NSDictionary* jsonDict = [[jsonStr dataUsingEncoding:NSUTF8StringEncoding]objectFromJSONData];
    
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    NSString* phoneModel = [[UIDevice currentDevice] model];
    NSDictionary *headDict = @{@"unique_field": @{
                                       @"gid":@"1", // 游戏id
                                       @"uid":@"1", // 玩家id
                                       @"imei":idfv,
                                       @"dept":@"1", // 渠道号，AppStore 1，
                                       @"os":phoneVersion, // 系统版本
                                       @"sys_version":phoneModel, // 手机型号
                                       @"apk_version":@"1.0.0", // 应用版本
                                       @"sign":@"1_maoyanshijue"} // md5校验
                               };
    
    [postDict addEntriesFromDictionary:jsonDict];
    [postDict addEntriesFromDictionary:headDict];
    
    //1.创建会话对象
    NSURLSession *session = [NSURLSession sharedSession];
    
    //2.根据会话对象创建task
    NSURL *url = [NSURL URLWithString:@"http://43.240.244.65:8085/gm_data/data.htm"];
    
    //3.创建可变的请求对象
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    //4.修改请求方法为POST
    request.HTTPMethod = @"POST";
    // 设置请求头
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    //5.设置请求体
    NSData *data = [NSJSONSerialization dataWithJSONObject:postDict options:NSJSONWritingPrettyPrinted error:nil];
    request.HTTPBody = data;//[@"username=520it&pwd=520it&type=JSON" dataUsingEncoding:NSUTF8StringEncoding];
    
    //6.根据会话对象创建一个Task(发送请求）
    /*
     第一个参数：请求对象
     第二个参数：completionHandler回调（请求完成【成功|失败】的回调）
     data：响应体信息（期望的数据）
     response：响应头信息，主要是对服务器端的描述
     error：错误信息，如果请求失败，则error有值
     */
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {}];
    
    //7.执行任务
    [dataTask resume];
}

- (void) rechargeBack:(const char*)result{
    LuaBridge::pushLuaFunctionById(handlerId);
    
    cocos2d::LuaValue payResultStr = cocos2d::LuaValue::stringValue(result);
    cocos2d::LuaBridge::getStack()->pushLuaValue(payResultStr);
    cocos2d::LuaBridge::getStack()->executeFunction(1);

    LuaBridge::releaseLuaFunctionById(handlerId);
    [[CatEye sharedInstance]setWaiting:false];
}

-(void) setWaiting:(BOOL) isWait
{
    if(self.waitView)
    {
        if(isWait == YES)
        {
            [[[UIApplication sharedApplication] keyWindow] addSubview:self.waitView];
            [self.waitView startAnimating];
        }
        else
        {
            [self.waitView stopAnimating];
            [self.waitView removeFromSuperview];
        }
    }
}

- (void) setHandlerId:(int)_id{
    if (handlerId) {
        LuaBridge::releaseLuaFunctionById(handlerId);
        handlerId = 0;
    }
    handlerId = _id;
}

- (void) setMoneyCount:(int)_count{
    count = _count;
}
- (int) getMoneyCount{
    return count;
}

@end