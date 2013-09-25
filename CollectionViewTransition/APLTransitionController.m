/*
     File: APLTransitionController.m
 Abstract: 
 
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 
 Copyright © 2013 Apple Inc. All rights reserved.
 WWDC 2013 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 EA1002
 5/3/2013
 */

#import "APLTransitionController.h"


@interface APLTransitionController ()

@property (nonatomic) UICollectionViewTransitionLayout* transitionLayout;
@property (nonatomic) id <UIViewControllerContextTransitioning> context;
@property (nonatomic) CGFloat initialPinchDistance;

@end


@implementation APLTransitionController 

-(instancetype)initWithCollectionView:(UICollectionView*)collectionView
{
    self = [super init];
    if (self) {
        UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinch:)];
        [collectionView addGestureRecognizer:pinchGesture];
        self.collectionView = collectionView;
    }
    return self;
}


-(void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
}


-(NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 1.0;
}


- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    self.context = transitionContext;
    UICollectionViewController* fromCollectionViewController = (UICollectionViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UICollectionViewController* toCollectionViewController   = (UICollectionViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    self.transitionLayout = [fromCollectionViewController.collectionView startInteractiveTransitionToCollectionViewLayout:toCollectionViewController.collectionViewLayout completion:^(BOOL didFinish, BOOL didComplete) {
        [_context.containerView addSubview:toCollectionViewController.view];
        [_context completeTransition:didComplete];

        if (didComplete)
            self.collectionView.delegate = toCollectionViewController;
        else 
            self.collectionView.delegate = fromCollectionViewController;
        self.transitionLayout = nil;
        self.context = nil;
        self.hasActiveInteraction = FALSE;
    }];
}


-(void)updateWithProgress:(CGFloat)progress
{
    if (_context==nil)
    {
        return;
    }
    
    if ((progress != self.transitionLayout.transitionProgress)) {
        [self.transitionLayout setTransitionProgress:progress];
        [self.transitionLayout invalidateLayout];
        [_context updateInteractiveTransition:progress];
    }
}


-(void)endInteractionWithSuccess:(BOOL)success
{
    if (_context==nil)
    {
        self.hasActiveInteraction = FALSE;
        return;
    }
    if ((self.transitionLayout.transitionProgress > 0.5) && success)
    {
        [self.collectionView finishInteractiveTransition];
        [_context finishInteractiveTransition];
    }
    else
    {
        [self.collectionView cancelInteractiveTransition];
        [_context cancelInteractiveTransition];
    }
}


-(void)handlePinch:(UIPinchGestureRecognizer*)sender
{
    if (sender.state == UIGestureRecognizerStateEnded)
    {
        [self endInteractionWithSuccess:TRUE];
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateCancelled)
    {
        [self endInteractionWithSuccess:FALSE];
        return;
    }

    if (sender.numberOfTouches < 2)
    {
        return;
    }
    CGPoint point1 = [sender locationOfTouch:0 inView:sender.view];
    CGPoint point2 = [sender locationOfTouch:1 inView:sender.view];
    CGFloat distance = sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y));
    CGPoint point = [sender locationInView:sender.view];
    
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        if (self.hasActiveInteraction)
        {
            return;
        }
        self.initialPinchDistance = distance;
        self.hasActiveInteraction = TRUE;
        [self.delegate interactionBeganAtPoint:point];
        return;
    }
    if (!self.hasActiveInteraction)
    {
        return;
    }
    
    if (sender.state == UIGestureRecognizerStateChanged)
    {
        CGFloat distanceDelta = distance - self.initialPinchDistance;
        if (self.navigationOperation == UINavigationControllerOperationPop)
        {
            distanceDelta = -distanceDelta;
        }
        CGFloat dimension = sqrt(self.collectionView.bounds.size.width*self.collectionView.bounds.size.width + self.collectionView.bounds.size.height*self.collectionView.bounds.size.height);
        CGFloat progress = MAX(MIN((distanceDelta / dimension), 1.0), 0.0);
        [self updateWithProgress:progress];
        return;
    }
}


@end
