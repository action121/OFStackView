//
//  NSString+Oxygen.m
//  Oxygen
//
//  Created by 黄 时欣 on 13-3-12.
//  Copyright (c) 2013年 zhang cheng. All rights reserved.
//

#import "NSString+Oxygen.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (Oxygen)

+ (BOOL)isStringEmpty:(NSString *)str
{
    if(str && ![str isEqual:[NSNull null]] && ![str isEqualToString:@""]){
        return NO;
    }else{
        return YES;
    }
}

+ (BOOL)isStringEmptyOrBlank:(NSString *)str
{
    if([NSString isStringEmpty:str] || [@"" isEqualToString:[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]){
        return YES;
    }else{
        return NO;
    }
}


/*正则表达式匹配*/
-(BOOL)matchRegExp:(NSString *)regex{
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [phoneTest evaluateWithObject:self];
}
/*手机号码验证*/
-(BOOL)validateMobile{
    //手机号以第一位是1，第二位“3-8” 加上 9个数字
    return [self matchRegExp:@"^[1][3-8]\\d{9}"];
}
/*车牌号验证*/
-(BOOL)validateLicensePlateNo{
    return [self matchRegExp:@"^[\u4e00-\u9fa5]{1}[A-Za-z]{1}[A-Za-z_0-9]{5}$"];
}
/*Email地址验证*/
-(BOOL)validateEmail{
    return [self matchRegExp:@"\\w+([-+\\.]\\w+)*@\\w+([-\\.]\\w+)*\\.\\w+([-\\.]\\w+)*"];
}
/*URL地址验证*/
-(BOOL)validateURL{
    return [self matchRegExp:@"[a-zA-z]+://[^\\s]*"];
}
/*邮政编码验证*/
-(BOOL)validateZipCode{
    return [self matchRegExp:@"[1-9]\\d{5}(?!\\d)"];
}
/*帐号是否合法(字母开头，允许5-16字节，允许字母数字下划线)*/
-(BOOL)validateAccountNo{
    return [self matchRegExp:@"^[a-zA-Z][a-zA-Z0-9_]{4,15}$"];
}
/*国内电话号码验证*/
-(BOOL)validatePhoneNo{
    return [self matchRegExp:@"\\d{3}-\\d{8}|\\d{4}-\\d{7}"];
}
/*腾讯QQ号验证(腾讯QQ号从10000开始)*/
-(BOOL)validateTencentQQ{
    return [self matchRegExp:@"[1-9][0-9]{4,}"];
}
/*身份证验证*/
-(BOOL)validateIDCard{
    return [self matchRegExp:@"^[1-9]\\d{7}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])\\d{3}$"] || [self matchRegExp:@"^[1-9]\\d{5}[1-9]\\d{3}((0\\d)|(1[0-2]))(([0|1|2]\\d)|3[0-1])(\\d{4}|\\d{3}(\\d|X|x))$"];
}
/*ip地址验证*/
-(BOOL)validateIPAddress{
    return [self matchRegExp:@"\\d+\\.\\d+\\.\\d+\\.\\d+"];
}
/*n位英文字母组成的字符串*/
-(BOOL)validateLetter:(int)n{
    NSString *regex = n <= 0?@"^[A-Za-z]+$":[NSString stringWithFormat:@"^[A-Za-z]{%d}$",n];
    return [self matchRegExp:regex];
}
/*n位大写英文字母组成的字符串*/
-(BOOL)validateUppercaseLetter:(int)n{
    NSString *regex = n <= 0?@"^[A-Z]+$":[NSString stringWithFormat:@"^[A-Z]{%d}$",n];
    return [self matchRegExp:regex];
}
/*n位小写英文字母组成的字符串*/
-(BOOL)validateLowercaseLetter:(int)n{
    NSString *regex = n <= 0?@"^[a-z]+$":[NSString stringWithFormat:@"^[a-z]{%d}$",n];
    return [self matchRegExp:regex];
}
/*密码验证（以字母开头，长度在6-18之间，只能包含字符、数字和下划线）*/
-(BOOL)validatePassword{
    return [self matchRegExp:@"^[a-zA-Z]w{5,17}$"];
}

/*VIN验证*/
-(BOOL)validateVIN{
    return [self matchRegExp:@"^[A-Za-z0-9]{17}"];
}

/*String 转 NSDate*/
-(NSDate *) stringDateWithFormat:(NSString *) format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = format;
    return [formatter dateFromString:self];
}

-(NSString *)md5Encrypt
{
    const char *cStr = [self UTF8String];
    unsigned char result[32];
    CC_MD5( cStr, strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

- (NSString *)URLEncodedString
{
    NSString *result = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)self,
                                            NULL,
                                            CFSTR("!*'();:@&amp;=+$,/?%#[] "),
                                            kCFStringEncodingUTF8));
    return result;
}

- (NSString*)URLDecodedString
{
    NSString *result = (NSString *)
    CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                            (CFStringRef)self,
                                                            CFSTR(""),
                                                            kCFStringEncodingUTF8));
    return result;
}

//java的urlencode，可能不对+号编码
- (NSString *)URLDecodedJavaString
{
    NSString *temp = [self stringByReplacingOccurrencesOfString:@"+" withString:@"%20"];
    NSString *result = (NSString *)
    CFBridgingRelease(CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault,
                                                            (CFStringRef)temp,
                                                            CFSTR(""),
                                                            kCFStringEncodingUTF8));
    return result;
}


//计算文字显示区域实际大小
-(CGSize)boundingRectWithSize:(CGSize)constraintSize font:(UIFont*)font{
    CGRect textBounds = CGRectZero;
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        textBounds = [self boundingRectWithSize:constraintSize
                                             options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                          attributes:@{NSFontAttributeName:font}
                                             context:nil];
    }else {
        textBounds.size = [self sizeWithFont:font
                                constrainedToSize:constraintSize
                                    lineBreakMode:NSLineBreakByWordWrapping];
    }
    return textBounds.size;

}
@end
