//
//  NSHTTPQuery.h
//  wework
//
//  Created by minisj.net on 2021/2/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface NSDictionary (HttpParam)

-(NSString*)httpQueryString;

-(NSString*)httpFormString;

-(NSData*)httpFormData;

@end

NS_ASSUME_NONNULL_END
