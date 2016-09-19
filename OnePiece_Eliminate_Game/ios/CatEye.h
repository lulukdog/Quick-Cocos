//
//  CatEye.h
//  海贼消消乐
//
//  Created by zhaolu on 16/9/13.
//
//

#ifndef CatEye_h
#define CatEye_h

@interface CatEye : NSObject
{
    int handlerId;
    int count;
}
@property (nonatomic, retain) UIActivityIndicatorView *waitView;

- (id) init;
+ (CatEye*) sharedInstance;

+ (NSString*)eye_getElapsedTime:(NSDictionary*)dict;
+ (void) eye_pay:(NSDictionary*)dict;
+ (void) eye_saveUserData:(NSDictionary*)dict;

- (void) rechargeBack:(const char*)result;
- (void) setHandlerId:(int)_id;
- (void) setMoneyCount:(int)_count;
- (int) getMoneyCount;

@end

#endif /* CatEye_h */
