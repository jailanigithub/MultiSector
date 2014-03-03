//
//  MultiSector.h
//  FwdCommit
//
//  Created by aram on 1/8/14.
//  Copyright (c) 2014 FwdCommit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiSector : UIControl

@property(nonatomic, assign)CGFloat pathCircleRadius;
@property(nonatomic, assign)CGFloat interactionCircleRadius;
@property(nonatomic, assign)int minValue, maxValue, sliderOffset;
@property(nonatomic, strong)UIColor *interactionCircleColor, *pathCircleColor, *backGroundColor;
@end

@interface CircleInfo : NSObject
@property(nonatomic, assign)CGPoint center;
@property(nonatomic, assign)double radius;

@end