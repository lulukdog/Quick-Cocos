//
//  AppStorePay.m
//  xiaochu
//
//  Created by zhaolu on 16/9/9.
//
//

#import "AppStorePay.h"
#import "CatEye.h"

static NSString* productStr = @"1";
static AppStorePay *pay;

@implementation AppStorePay

+ (AppStorePay *)sharedObject
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        pay = [[AppStorePay alloc] init];
    });
    return pay;
}

- (id)init{
    self = [super init];
    if(self){
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    }
    return self;
}

- (void)purchase:(NSString*)product{
    productStr = product;
    if([SKPaymentQueue canMakePayments]){
        [self requestProductData:product];
    }else{
        NSLog(@"不允许程序内付费");
    }
}


//请求商品
- (void)requestProductData:(NSString *)type{
    NSLog(@"-------------请求对应的产品信息----------------");
    NSArray *product = [[NSArray alloc] initWithObjects:type, nil, nil];
    NSSet *nsset = [NSSet setWithArray:product];
    SKProductsRequest *request = [[SKProductsRequest alloc] initWithProductIdentifiers:nsset];
    request.delegate = self;
    [request start];
    [product release];
}

//收到产品返回信息
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSLog(@"--------------收到产品反馈消息---------------------");
    NSArray *product = response.products;
    
    if([product count] == 0){
        NSLog(@"--------------没有商品------------------");
        // recharge fail
        NSString* result = [NSString stringWithFormat:@"fail_%d_%d",[[CatEye sharedInstance]getMoneyCount]*100,1];
        [[CatEye sharedInstance]rechargeBack:[result UTF8String]];
        return;
    }
    
    NSLog(@"productID:%@", response.invalidProductIdentifiers);
    NSLog(@"产品付费数量:%lu",(unsigned long)[product count]);
    
    SKProduct *p = nil;
    for (SKProduct *pro in product) {
        NSLog(@"%@", [pro description]);
        NSLog(@"%@", [pro localizedTitle]);
        NSLog(@"%@", [pro localizedDescription]);
        NSLog(@"%@", [pro price]);
        NSLog(@"%@", [pro productIdentifier]);
        
        if([pro.productIdentifier isEqualToString:productStr]){
            p = pro;
        }
    }
    
    SKPayment *payment = [SKPayment paymentWithProduct:p];
    
    NSLog(@"发送购买请求");
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//请求失败
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"------------------错误-----------------:%@", error);
    //弹窗
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请求失败" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alertView show];
}

- (void)requestDidFinish:(SKRequest *)request{
    NSLog(@"------------反馈信息结束-----------------");
}


//监听购买结果
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    for(SKPaymentTransaction *tran in transaction){
        
        switch (tran.transactionState) {
            case SKPaymentTransactionStatePurchased:
                NSLog(@"交易完成");
                [self completeTransaction:tran];
                
                // recharge success
                NSString* result = [NSString stringWithFormat:@"%d_%d",[[CatEye sharedInstance]getMoneyCount]*100,1];
                [[CatEye sharedInstance]rechargeBack:[result UTF8String]];
                break;
            case SKPaymentTransactionStatePurchasing:
                NSLog(@"商品添加进列表");
                
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"已经购买过商品");
                
                break;
            case SKPaymentTransactionStateFailed:
                NSLog(@"交易失败");
                [self completeTransaction:tran];
                //弹窗
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"交易失败" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
                [alertView show];
                // recharge fail
                NSString* resultFail = [NSString stringWithFormat:@"fail_%d_%d",[[CatEye sharedInstance]getMoneyCount]*100,1];
                [[CatEye sharedInstance]rechargeBack:[resultFail UTF8String]];
                break;
            default:
                break;
        }
    }
}

//交易结束
- (void)completeTransaction:(SKPaymentTransaction *)transaction{
    NSLog(@"交易结束");
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}


- (void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [super dealloc];
}


@end
