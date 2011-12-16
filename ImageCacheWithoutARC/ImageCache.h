//
//  ImageCache.h
//  ImageCache
//
//  Created by 荒井 良太 on 11/12/14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ImageCacheCompletionBlock)(UIImage *image);
typedef void (^ImageCacheErrorBlock)(NSError *error);

@interface ImageCache : NSObject {
  NSCache *_cacheOnMemory;
}



+ (ImageCache *)sharedCache;

- (NSString *)directoryToSave;
- (NSString *)filenameForKey:(NSString *)key;
- (NSString *)filepathForKey:(NSString *)key;

- (UIImage *)imageForKey:(NSString *)key;
- (void)setImage:(UIImage *)image forKey:(NSString *)key;

- (void)imageAsyncForURL:(NSURL *)url 
              completionBlock:(ImageCacheCompletionBlock)completionBlock 
                 failureBlock:(ImageCacheErrorBlock)failureBlock;
- (void)_performImageAsyncWithParams:(NSDictionary *)params;
- (void)setImage:(UIImage *)image forURL:(NSURL *)url;

@end
