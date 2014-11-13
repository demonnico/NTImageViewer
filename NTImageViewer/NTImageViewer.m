//
//  XNMImageDisplayView.m
//  xiaonimei
//
//  Created by Nicholas Tau on 10/29/13.
//  Copyright (c) 2013 Huaban. All rights reserved.
//

#import "NTImageViewer.h"
#import <UIView+Utils.h>
#import <UIImageView+WebCache.h>

#define TargetImageViewTag 1234567
#define DeviceScreenWidth   [UIScreen mainScreen].bounds.size.width
#define DeviceScreenHeight  [UIScreen mainScreen].bounds.size.height

@interface NTImageViewer()
@property (nonatomic,assign) CGRect originalRect;
@property (nonatomic,assign) CGFloat panBeginTop;
@property (nonatomic,copy) viewExitBlock endblock;
@property (nonatomic,strong) UIImageView * imageViewPlaceHolder;
@property (nonatomic,strong) UIWindow * displayWindow;
@property (nonatomic,weak) UIScrollView * scrollView;
@end

@implementation NTImageViewer

static NTImageViewer * _instance;
+(NTImageViewer*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [NTImageViewer new];
    });
    return _instance;
}

-(UIWindow*)displayWindow
{
    if (!_displayWindow) {
        _displayWindow =
        [[UIWindow alloc] initWithFrame:CGRectMake(0, 0, DeviceScreenWidth, DeviceScreenHeight)];
        _displayWindow.windowLevel = UIWindowLevelStatusBar+1;
        _displayWindow.hidden = YES;
        _displayWindow.userInteractionEnabled = YES;
        _displayWindow.backgroundColor = [UIColor blackColor];
        
        UITapGestureRecognizer * singleTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(singleTap:)];
        UITapGestureRecognizer * doubleTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(doubleTap:)];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [_displayWindow addGestureRecognizer:singleTap];
        [_displayWindow addGestureRecognizer:doubleTap];
        
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.numberOfTouchesRequired = 1;
        
        UIPanGestureRecognizer * panGesture =
        [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(panGesture:)];
        [_displayWindow addGestureRecognizer:panGesture];
        panGesture.delegate = self;
        
    }
    return _displayWindow;
}

-(void)displayWithPlaceHolderImageView:(UIImageView*)imageView
{
    [self displayDetailImageWithURLString:nil
                     placeHolderImageView:imageView
                             progressView:nil
                            progressBlock:nil
                         cachedImageBlock:nil
                                 endBlock:nil];
}

-(void)displayDetailImageWithURLString:(NSString*)URL
                  placeHolderImageView:(UIImageView*)imageViewPlaceHolder
                          progressView:(UIView*)progressView
                         progressBlock:(downloadingBlock)progressblock
                      cachedImageBlock:(cachedImageBlock)cachedimageblock
                             endBlock:(viewExitBlock)endBlock
{
    self.imageViewPlaceHolder = imageViewPlaceHolder;
    [UIView animateWithDuration:0.2
                     animations:^{
                         imageViewPlaceHolder.alpha =0;
                     }];
    
    CGSize originalSize = imageViewPlaceHolder.size;
    self.endblock = endBlock;

    UIScrollView * scrollView =
    [[UIScrollView alloc] initWithFrame:CGRectZero];
    scrollView.maximumZoomScale = 2.0;
    scrollView.minimumZoomScale = 1.0;
    scrollView.delegate = self;
    scrollView.clipsToBounds = NO;
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.showsHorizontalScrollIndicator  = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView = scrollView;
    
    CGFloat imageHeight = DeviceScreenWidth*originalSize.height/(CGFloat)originalSize.width;
    scrollView.contentSize = CGSizeMake(DeviceScreenWidth, imageHeight);
    BOOL isOutOfBoundary = imageHeight>DeviceScreenHeight;
    CGFloat scrollViewHeight =
    isOutOfBoundary?DeviceScreenHeight:imageHeight;
    scrollView.size = CGSizeMake(DeviceScreenWidth, scrollViewHeight);
    if (!isOutOfBoundary)
        scrollView.centerY = DeviceScreenHeight/2;

    UIWindow * window = self.displayWindow;
    [window addSubview:scrollView];
    window.hidden = NO;
    
    CGPoint originalPoint = [imageViewPlaceHolder convertPoint:CGPointZero
                                                        toView:scrollView];
    self.originalRect = CGRectMake(originalPoint.x,
                                   originalPoint.y,
                                   originalSize.width,
                                   originalSize.height);
    UIImageView * imageView = [UIImageView new];
    imageView.tag  = TargetImageViewTag;
    imageView.origin = originalPoint;
    imageView.size = originalSize;
    imageView.image =  imageViewPlaceHolder.image;
    [scrollView addSubview:imageView];
    
    NSString * detailImageURL = URL;
    if (cachedimageblock) {
        cachedimageblock(imageView);
    }
    if (progressView)
        [imageView addSubview:progressView];
    
    UIImage * imagePlaceHolder = imageViewPlaceHolder.image;
    if(detailImageURL)
        [imageView setImageWithURL:[NSURL URLWithString:detailImageURL]
                  placeholderImage:imagePlaceHolder
                           options:0
                          progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                              CGFloat progress = receivedSize/(CGFloat)expectedSize;
                              if(progressblock)
                                  progressblock(progress,NO,nil);
                          }
                         completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                             [progressView removeFromSuperview];
                             if(progressblock)
                                 progressblock(1,YES,image);
                         }];

    [UIView animateWithDuration:0.4
                     animations:^{
                         imageView.frame = CGRectMake(0, 0, DeviceScreenWidth, imageHeight);
                     }];
    
}

-(BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIScrollView * scrollView= self.scrollView;
    CGPoint velocity = [panGestureRecognizer velocityInView:scrollView];
    NSInteger contentHeight = (NSInteger)scrollView.contentSize.height;
    if (velocity.y<0) {//向上推
        if (scrollView.contentOffset.y+scrollView.height-contentHeight<0) {
            return NO;
        }
        UIImageView * imageView = (UIImageView*)[scrollView viewWithTag:TargetImageViewTag];
        self.panBeginTop = imageView.top;
        return YES;
    }else{//向下拉
        if (scrollView.contentOffset.y>0) {
            return NO;
        }
        UIImageView * imageView = (UIImageView*)[scrollView viewWithTag:TargetImageViewTag];
        self.panBeginTop = imageView.top;
        return YES;
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

-(UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView viewWithTag:TargetImageViewTag];
}

#define MAX_DISTANCE 500.0
-(void)panGesture:(UIPanGestureRecognizer*)panGesture
{
    UIWindow * displayWindow = self.displayWindow;
    UIScrollView * scrollView = self.scrollView;
    UIImageView * imageView = (UIImageView*)[scrollView viewWithTag:TargetImageViewTag];
    CGPoint point = [panGesture translationInView:scrollView];
    CGPoint velocity = [panGesture velocityInView:scrollView];
    CGFloat percent = abs(point.y)/MAX_DISTANCE;
    UIColor * backgroundColor = [displayWindow.backgroundColor colorWithAlphaComponent:1-percent];
    displayWindow.backgroundColor= backgroundColor;
    imageView.top+=velocity.y*0.005;
    switch (panGesture.state) {
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        {
            if (percent>0.25) {
                [self leaveStageWithRole:scrollView];
            }else
                [UIView animateWithDuration:0.3
                                 animations:^{
                                     displayWindow.backgroundColor =
                                     [displayWindow.backgroundColor colorWithAlphaComponent:1.0];
                                     imageView.top = self.panBeginTop;
                                 }];
            break;
        }
        default:
            break;
    }
    
}

-(void)leaveStageWithRole:(UIView*)view
{
    __weak __typeof(&*self)weakSelf = self;
    UIWindow * displayWindow = self.displayWindow;
    UIScrollView * scrollView = (UIScrollView*)view;
    UIImageView * imageView  = (UIImageView*)[scrollView viewWithTag:TargetImageViewTag];
    UIImageView * imageViewPlaceHolder = self.imageViewPlaceHolder;
    imageView.image = imageViewPlaceHolder.image;
    [scrollView setZoomScale:1 animated:YES];
    if(imageView.height<DeviceScreenHeight*2)
        [scrollView setContentOffset:CGPointZero animated:YES];
    [UIView animateWithDuration:0.4
                     animations:^{
                         imageView.frame = weakSelf.originalRect;
                         displayWindow.backgroundColor =
                         [UIColor colorWithHue:0 saturation:0 brightness:0 alpha:0];
                     } completion:^(BOOL finished) {
                         
                         imageViewPlaceHolder.alpha = scrollView.alpha;
                         [UIView animateWithDuration:0.3
                                          animations:^{
                                              imageViewPlaceHolder.alpha = 1;
                                              [NTImageViewer sharedInstance].displayWindow.hidden = YES;
                                              displayWindow.backgroundColor = [UIColor blackColor];
                                          }];
                         [scrollView removeFromSuperview];
                         if (weakSelf.endblock) {
                             weakSelf.endblock(scrollView.alpha);
                         }
                     }];
}

-(void)singleTap:(UITapGestureRecognizer*)gesture
{
    [self leaveStageWithRole:self.scrollView];
}

-(void)doubleTap:(UITapGestureRecognizer*)gesture
{
    UIScrollView * scrollView = self.scrollView;
    if (scrollView.zoomScale>1) {
        [scrollView setZoomScale:1.0
                        animated:YES];
    }else{
        [scrollView setZoomScale:2.0
                        animated:YES];
    }
}
@end
