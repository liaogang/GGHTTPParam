//
//  NSHTTPQuery.m
//  wework
//
//  Created by minisj.net on 2021/2/2.
//

#import "NSHTTPParam.h"


NSString * AFPercentEscapedStringFromString2(NSString *string) {
    static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
    static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";

    NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
    [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];

    // FIXME: https://github.com/AFNetworking/AFNetworking/pull/3028
    // return [string stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];

    static NSUInteger const batchSize = 50;

    NSUInteger index = 0;
    NSMutableString *escaped = @"".mutableCopy;

    while (index < string.length) {
        NSUInteger length = MIN(string.length - index, batchSize);
        NSRange range = NSMakeRange(index, length);

        // To avoid breaking up character sequences such as 👴🏻👮🏽
        range = [string rangeOfComposedCharacterSequencesForRange:range];

        NSString *substring = [string substringWithRange:range];
        NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
        [escaped appendString:encoded];

        index += range.length;
    }

    return escaped;
}


@implementation NSData (HttpParam)

-(NSString*)urlsafeBase64EncodedString
{
    NSString *str = [self base64EncodedStringWithOptions:0];
    
    str = [str stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    str = [str stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    
    return str;
}


/*
 test
 7B226578 706F7375 7265223A 5B5D2C22 6D657472 69637322 3A7B2265 78706964 5F63223A 74727565 2C226664 69645F63 223A7472 75652C22 72635F63 223A7472 75657D7D
 
 %7B%22%65%78%70%6F%73%75%72%65%22%3A%5B%5D%2C%22%6D%65%74%72%69%63%73%22%3A%7B%22%65%78%70%69%64%5F%63%22%3A%74%72%75%65%2C%22%66%64%69%64%5F%63%22%3A%74%72%75%65%2C%22%72%63%5F%63%22%3A%74%72%75%65%7D%7D
 */
-(NSString*)URLEncodedString
{
    unsigned char *p = (unsigned char *)self.bytes;
    NSUInteger len = self.length;
    
    NSMutableString *s = [NSMutableString stringWithCapacity: 3 * len];
    
    while (len) {
        [s appendFormat:@"%%%02X", p[0]];
        ++p;
        --len;
    }
    
    return s;
}

@end


@implementation NSDictionary (HttpParam)

-(NSString*)httpQueryString
{
    NSMutableArray<NSURLQueryItem *> *queryItems = [NSMutableArray arrayWithCapacity: self.count];
    
    for (NSString* key in self) {
        id value = self[key];

        if ([value isKindOfClass:[NSData class]]) {
            value = [(NSData*)value urlsafeBase64EncodedString];
        }
        else if ([value isKindOfClass:[NSNumber class]]) {
            value = [(NSNumber*)value stringValue];
        }
        else if ([value isKindOfClass:[NSString class]]) {
        }
        else{
            NSLog(@"error 67");
        }

        [queryItems addObject: [NSURLQueryItem queryItemWithName:AFPercentEscapedStringFromString2(key)
                                                           value:AFPercentEscapedStringFromString2(value)]];
    }

    NSURLComponents *urlComponents = [NSURLComponents new];
    urlComponents.queryItems = queryItems;
    return urlComponents.query;
}

-(NSString*)httpFormString
{
    NSMutableArray *collect = [NSMutableArray arrayWithCapacity: self.count];
    
    for (NSString *key in self) {
        id value = self[key];
        
        [collect addObject: [NSString stringWithFormat:@"%@=%@",
                             AFPercentEscapedStringFromString2(key),
                             AFPercentEscapedStringFromString2(value)]];
    }
    
    return [collect componentsJoinedByString:@"&"];
}

-(NSData*)httpFormData
{
    return [[self httpFormString] dataUsingEncoding:NSUTF8StringEncoding];
}
@end





