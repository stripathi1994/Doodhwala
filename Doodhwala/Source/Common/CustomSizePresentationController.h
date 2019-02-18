//
//  CustomSizePresentationController.h
//  TF45
//
//  Created by Rajinder Paul on 29/09/16.
//  Copyright © 2016 Arvind Tiwari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSizePresentationController : UIPresentationController

@property (nonatomic) UIView* dimmingView;

@property (nonatomic) CGRect presentedControllerSize;


@end
