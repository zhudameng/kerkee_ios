//
//  KCImageSetter.m
//  kerkee
//
//  Created by zihong on 15/8/25.
//  Copyright (c) 2015年 zihong. All rights reserved.
//



#import <Foundation/Foundation.h>
#import "KCWebImageSetter.h"
#import "KCBaseDefine.h"
#import "KCCacheKit.h"
#import "KCWebViewProxy.h"
#import "KCUtilURL.h"
#import "KCTaskQueue.h"
#import "KCLog.h"

@interface KCWebImageSetter ()
{
    KCImagePreCache* m_imageCacheManager;
    
}
@end

@implementation KCWebImageSetter


-(id)init
{
    if (self = [super init])
    {
        if (!m_imageCacheManager)
        {
            m_imageCacheManager = [[KCImagePreCache alloc]init];
            [m_imageCacheManager setIsUseLastPathComponentForKey:YES];
            [m_imageCacheManager openFileCache:YES];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [m_imageCacheManager flushMemory];
    KCRelease(m_imageCacheManager);
    m_imageCacheManager = nil;
    
    KCDealloc(super);
}



-(void) handleImage:(KCWebImageSetterTask*)aTask
{
   
    
    NSURL *url = aTask.url;
    
    if ([KCUtilURL isImageUrl:url])
    {
        __block KCImagePreCache* cache = m_imageCacheManager;
        [KCWebViewProxy handleRequestsWithHost:url.host path:url.path handler:^(NSURLRequest *req, KCWebViewResponse *res)
         {
             __block KCWebViewResponse* webviewResponse = res;
             BACKGROUND_BEGIN
             [cache prepareImage:url keepMemoryCache:NO usingBlock:^(UIImage *image, NSString *path, BOOL isFromCached)
              {
                  if (image)
                      [webviewResponse respondWithImage:image];
              }];
             BACKGROUND_COMMIT
             
         }];
    }
}



@end