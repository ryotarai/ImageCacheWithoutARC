//
//  ImageCache.m
//  ImageCache
//
//  Created by 荒井 良太 on 11/12/14.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "ImageCache.h"
#import <CommonCrypto/CommonDigest.h>

#import "ASIHTTPRequest.h"


@implementation ImageCache

static ImageCache *_sharedCache;

- (id)init {
  self = [super init];
  if (self) {
    _cacheOnMemory = [[NSCache alloc] init];
  }
  return self;
}


+ (ImageCache *)sharedCache {
  if (!_sharedCache) {
    _sharedCache = [[ImageCache alloc] init];
  }
  return _sharedCache;
}

//==============================================================================
#pragma mark - Path

- (NSString *)directoryToSave {
  static NSString *_directoryToSave;
  
  if (!_directoryToSave) {
    
    NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [dirs objectAtIndex:0];
    
    _directoryToSave = [[NSString alloc] initWithFormat:@"%@/.cached_images", documentDir];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:_directoryToSave]) {
      NSError *error;
      if (![[NSFileManager defaultManager] createDirectoryAtPath:_directoryToSave 
                                     withIntermediateDirectories:YES
                                                      attributes:nil
                                                           error:&error]) {
        NSLog(@"Directory Create Error: %@", [error description]);
      }
    }
    
    
  }
  
  return _directoryToSave;
}

- (NSString *)filenameForKey:(NSString *)key {
  // MD5でハッシュ化
  const char *cStr = [key UTF8String];
  unsigned char result[16];
  CC_MD5( cStr, strlen(cStr), result ); // This is the md5 call
  return [NSString stringWithFormat:
          @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
          result[0], result[1], result[2], result[3], 
          result[4], result[5], result[6], result[7],
          result[8], result[9], result[10], result[11],
          result[12], result[13], result[14], result[15]
          ];

}

- (NSString *)filepathForKey:(NSString *)key {
  NSString *dir = [self directoryToSave];
  NSString *filename = [self filenameForKey:key];
  return [NSString stringWithFormat:@"%@/%@",
          dir,
          filename];
}

//==============================================================================
#pragma mark - Image Setter and Getter

- (UIImage *)imageForKey:(NSString *)key {
  UIImage *image = [_cacheOnMemory objectForKey:key];
  
  if (!image) {
    NSString *path = [self filepathForKey:key];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
      image = [UIImage imageWithContentsOfFile:path];
      [_cacheOnMemory setObject:image forKey:key];
    }
  }

  return image;
}


- (void)setImage:(UIImage *)image forKey:(NSString *)key {
  NSData *data = UIImagePNGRepresentation(image);
  NSString *path = [self filepathForKey:key];
  
  [data writeToFile:path atomically:NO];
}

//==============================================================================
#pragma mark - Setter and Getter For URL

- (void)imageAsyncForURL:(NSURL *)url 
              completionBlock:(ImageCacheCompletionBlock)completionBlock 
                 failureBlock:(ImageCacheErrorBlock)failureBlock {
  
  NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
                          url, @"url", 
                          Block_copy(completionBlock), @"completionBlock", 
                          Block_copy(failureBlock), @"failureBlock", 
                          nil];
  
  [NSThread detachNewThreadSelector:@selector(_performImageAsyncWithParams:)
                           toTarget:self 
                         withObject:params];
  
}

- (void)_performImageAsyncWithParams:(NSDictionary *)params {
  NSURL *url = [params objectForKey:@"url"];
  ImageCacheCompletionBlock completionBlock = [params objectForKey:@"completionBlock"];
  ImageCacheErrorBlock failureBlock = [params objectForKey:@"failureBlock"];
  
  UIImage *image = [self imageForKey:[url absoluteString]];
  
  if (image) {
    completionBlock(image);
    
  } else {
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
    [request setCompletionBlock:^{
      NSData *data = [request responseData];
      UIImage *image = [UIImage imageWithData:data];
      
      [self setImage:image forURL:url];
      completionBlock(image);
    }];
    
    [request setFailedBlock:^{
      failureBlock(nil);
    }];
    
    [request startAsynchronous];
  }
}

- (void)setImage:(UIImage *)image forURL:(NSURL *)url {
  [self setImage:image forKey:[url absoluteString]];
}

@end
