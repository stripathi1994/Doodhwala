//
//  CustomSizePresentationController.m
//  TF45
//
//  Created by Rajinder Paul on 29/09/16.
//  Copyright © 2016 Arvind Tiwari. All rights reserved.
//

#import "CustomSizePresentationController.h"

@implementation CustomSizePresentationController

- (CGRect)frameOfPresentedViewInContainerView {
    
   // return CGRectMake(20, self.containerView.bounds.size.height/2 - 100, self.containerView.bounds.size.width - 40, 220);
    
    return self.presentedControllerSize;
}


- (void)presentationTransitionWillBegin {
    // Add a custom dimming view behind the presented view controller's view
    if(self.dimmingView == nil) {
    self.dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
    self.dimmingView.backgroundColor =  [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:0.4];
    
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView:)];
        [self.dimmingView addGestureRecognizer:tapGesture];
        
    [self.containerView insertSubview:self.dimmingView atIndex:0];
        
    //[[self containerView] addSubview:self.dimmingView];
   // [self.dimmingView addSubview:[[self presentedViewController] view]];
//    self.dimmingView.backgroundColor = [UIColor lightGrayColor];
//        self.dimmingView.alpha = 0.5;
    }
    // Use the transition coordinator to set up the animations.
    id <UIViewControllerTransitionCoordinator> transitionCoordinator =
    [[self presentingViewController] transitionCoordinator];
    
    // Fade in the dimming view during the transition.
    [self.dimmingView setAlpha:0.0];
    [transitionCoordinator animateAlongsideTransition:
     ^(id<UIViewControllerTransitionCoordinatorContext> context) {
         [self.dimmingView setAlpha:1.0];
     } completion:nil];
}

-(void) dismissalTransitionWillBegin {
    
    id <UIViewControllerTransitionCoordinator> transitionCoordinator =
    [[self presentingViewController] transitionCoordinator];
    
    // Fade in the dimming view during the transition.
    [transitionCoordinator animateAlongsideTransition:
     ^(id<UIViewControllerTransitionCoordinatorContext> context) {
         [self.dimmingView setAlpha:0.0];
     } completion:nil];

}

-(void) dismissView :(id) sender {

    [self.presentingViewController dismissViewControllerAnimated:true completion:nil];
}

@end
