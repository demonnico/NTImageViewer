//
//  XNMImageDisplayView.h
//  xiaonimei
//
//  Created by Nicholas Tau on 10/29/13.
//  Copyright (c) 2013 Huaban. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^viewExitBlock)(CGFloat exitPointAlpha);
typedef void (^cachedImageBlock)(UIImageView * previewImageView);
typedef void (^downloadingBlock)(CGFloat progress,BOOL finished,UIImage * image);
@interface NTImageViewer : NSObject
<UIScrollViewDelegate,UIGestureRecognizerDelegate>

+(NTImageViewer*)sharedInstance;

/**
 *  display image with placeholder imageview
 *
 *  @param imageView placeholader imageview
 */
-(void)displayWithPlaceHolderImageView:(UIImageView*)imageView;
/**
 *  display detail image.
 *
 *  @param URL                  Request detail image URL
 *  @param imageViewPlaceHolder imageView which display current image
 *  @param progressView         if u wanna set a indicator, that's it.
 *  @param progressblock        to update your indicator
 *  @param cachedimageblock     before request by URL, we'll check cached image at first.
 *  @param exitBlock            if u wanna do something after animation end, set it.
 */
-(void)displayDetailImageWithURLString:(NSString*)URL
                  placeHolderImageView:(UIImageView*)imageViewPlaceHolder
                          progressView:(UIView*)progressView
                         progressBlock:(downloadingBlock)progressblock
                      cachedImageBlock:(cachedImageBlock)cachedimageblock
                              endBlock:(viewExitBlock)endBlock;

@end
