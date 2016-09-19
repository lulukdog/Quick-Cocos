//
//  AppStorePay.h
//  xiaochu
//
//  Created by zhaolu on 16/9/9.
//
//

#ifndef AppStorePay_h
#define AppStorePay_h

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface AppStorePay : NSObject<SKPaymentTransactionObserver,SKProductsRequestDelegate>

+ (AppStorePay *)sharedObject;

- (void)purchase:(NSString*)product;


@end
#endif /* AppStorePay_h */
