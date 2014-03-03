//
//  MultiSector.m
//  FwdCommit
//
//  Created by aram on 1/8/14.
//  Copyright (c) 2014 FwdCommit. All rights reserved.
//

#import "MultiSector.h"

@implementation CircleInfo
@end

@interface MultiSector()
@property(nonatomic, strong)CircleInfo *pathCircle;
@property(nonatomic, strong)CircleInfo *touchCircle;
@property(nonatomic, assign)CGRect sectorRect;
@property(nonatomic, assign)CGPoint previousTouchPoint;
@end

static const double touchCircleRadius = 10.0;

typedef enum Quadrants{
    firstQuadrant = 1,
    secondQuadrant,
    thirdQuadrant,
    fourthQuadrant
}Quadrant;

@implementation MultiSector

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _pathCircleRadius = 60.0;
        _interactionCircleRadius = 10.0;
        _minValue = 0;
        _maxValue = 200;
        _sliderOffset = _maxValue - _minValue;
        
        if(!_pathCircleColor)
            _pathCircleColor = [UIColor whiteColor];
        if(!_interactionCircleColor)
            _interactionCircleColor = [UIColor whiteColor];
        if(!_backGroundColor)
            _backGroundColor = [UIColor grayColor];
    }
    return self;
}

-(CircleInfo*)touchCircle{
    
    if(!_touchCircle){
        _touchCircle = [[CircleInfo alloc]init];
        _touchCircle.center = CGPointMake(self.sectorRect.size.width/2, self.sectorRect.size.height/2 - self.pathCircle.radius);
    }
    return _touchCircle;
}

-(CircleInfo*)pathCircle{
    
    if(!_pathCircle){
        _pathCircle = [[CircleInfo alloc]init];
    }
    return _pathCircle;
}

-(BOOL)point:(CGPoint)point InsideCircle:(CircleInfo*)circle{
    
    if(fabsf(circle.center.x - point.x) <= fabsf(circle.radius*2) && fabsf(circle.center.y - point.y) <= fabsf(circle.radius*2))
        return YES;
    
    return NO;
}

-(Quadrant)pointBelongsToQuadtant:(CGPoint)touchPoint{
    
    CGFloat x = self.pathCircle.center.x;
    CGFloat y = self.pathCircle.center.y;
    
    if (touchPoint.x >= x && touchPoint.y <= y) {
        return firstQuadrant;
    }else if (touchPoint.x >= x && touchPoint.y >= y){
        return secondQuadrant;
    }else if (touchPoint.x <= x && touchPoint.y >= y){
        return thirdQuadrant;
    }else if (touchPoint.x <= x && touchPoint.y <= y){
        return fourthQuadrant;
    }
    return firstQuadrant;
}

-(CGFloat)updateTouchCircleCenter:(CGPoint)touchPoint{
   
    CGFloat dy = fabsf(self.pathCircle.center.y - touchPoint.y);
    CGFloat dx = fabsf(fabsf(self.pathCircle.center.x - touchPoint.x));
    
    CGFloat angle = degree(atan2f(dy, dx));
//    NSLog(@"Tangent %f", angle);
    CGFloat x = 0.0, y = 0.0;
    CGFloat angleForCircumference = angle;
    
    Quadrant touchedQuadrant = [self pointBelongsToQuadtant:touchPoint];
    
    switch (touchedQuadrant) {
            
        case firstQuadrant:
            
            angleForCircumference = 90 - angleForCircumference;
            if (touchPoint.x > self.previousTouchPoint.x || touchPoint.y > self.previousTouchPoint.y) {
            
                x = self.pathCircle.center.x + cosf(radians(angle)) * self.pathCircle.radius;
                y = self.pathCircle.center.y - sinf(radians(angle)) * self.pathCircle.radius;
            }else if (touchPoint.x < self.previousTouchPoint.x || touchPoint.y < self.previousTouchPoint.y){
                x = self.pathCircle.center.x + cosf(radians(angle)) * self.pathCircle.radius;
                y = self.pathCircle.center.y - sinf(radians(angle)) * self.pathCircle.radius;
            }
            break;
        
        case secondQuadrant:
            
            angleForCircumference = angleForCircumference + 90;
            if (touchPoint.x < self.previousTouchPoint.x || touchPoint.y > self.previousTouchPoint.y) {
                x = self.pathCircle.center.x + cosf(radians(angle)) * self.pathCircle.radius;
                y = self.pathCircle.center.y + sinf(radians(angle)) * self.pathCircle.radius;
            }else if (touchPoint.x > self.previousTouchPoint.x || touchPoint.y < self.previousTouchPoint.y){
                x = self.pathCircle.center.x + cosf(radians(angle)) * self.pathCircle.radius;
                y = self.pathCircle.center.y + sinf(radians(angle)) * self.pathCircle.radius;
            }

            break;
            
        case thirdQuadrant:

            angleForCircumference = angleForCircumference + 180;
            if (touchPoint.x < self.previousTouchPoint.x || touchPoint.y < self.previousTouchPoint.y) {
                x = self.pathCircle.center.x - cosf(radians(angle)) * self.pathCircle.radius;
                y = self.pathCircle.center.y + sinf(radians(angle)) * self.pathCircle.radius;
            }else if (touchPoint.x > self.previousTouchPoint.x || touchPoint.y > self.previousTouchPoint.y){
                x = self.pathCircle.center.x - cosf(radians(angle)) * self.pathCircle.radius;
                y = self.pathCircle.center.y + sinf(radians(angle)) * self.pathCircle.radius;
            }
            
            break;
            
        case fourthQuadrant:
            
            angleForCircumference = angleForCircumference + 270;
            if (touchPoint.x > self.previousTouchPoint.x || touchPoint.y < self.previousTouchPoint.y) {
                x = self.pathCircle.center.x - cosf(radians(angle)) * self.pathCircle.radius;
                y = self.pathCircle.center.y - sinf(radians(angle)) * self.pathCircle.radius;
            }else if (touchPoint.x < self.previousTouchPoint.x || touchPoint.y > self.previousTouchPoint.y){
                x = self.pathCircle.center.x - cosf(radians(angle)) * self.pathCircle.radius;
                y = self.pathCircle.center.y - sinf(radians(angle)) * self.pathCircle.radius;
            }
            
            break;
            
        default:
            break;
    }
    
    self.previousTouchPoint = touchPoint;
    self.touchCircle.center = CGPointMake(x, y);
    return angleForCircumference;
}

#pragma mark - Events manipulator
- (BOOL) beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
    CGPoint touchPoint = [touch locationInView:self];
    NSLog(@"Touch begins");
    
    if([self point:touchPoint InsideCircle:self.touchCircle])
        return YES;
    else
        return NO;
    
}

-(CGFloat)calculateCircleCircumference:(int)sliderValue{

    CGFloat entireCircumference = 2*M_PI*_pathCircleRadius;
    CGFloat actualCircumference = (sliderValue * entireCircumference)/_sliderOffset;
    return actualCircumference;
}


-(CGPoint)calculateInteractionCircleCenterPointFromSliderValue:(int)sliderValue{

    //1. Calculate circumference from slider offset
    CGFloat actualCircumference = [self calculateCircleCircumference:sliderValue];

    //2. Calculate angle to move interaction circle
    CGFloat offsetAngle = actualCircumference/_pathCircleRadius;
    offsetAngle = degree(offsetAngle);
    NSLog(@"offset angle %f", offsetAngle);
    
    //3. Calculate x, y point for given angle
    CGFloat calculatedAngle = 0.0;

    CGFloat dx = 0.0, dy = 0.0;

    CGFloat x = 0, y = 0;
    if(offsetAngle > 0 && offsetAngle <= 90){
        
        calculatedAngle = 90.0 - calculatedAngle;
        dx = cosf(radians(calculatedAngle)) * _pathCircleRadius;
        dy = sinf(radians(calculatedAngle)) * _pathCircleRadius;
        NSLog(@"dx = %f  dy = %f", dx, dy);

        x = self.pathCircle.center.x + dx;
        y = self.pathCircle.center.y - dy;
    }
    if(offsetAngle > 90.0 && offsetAngle <= 180.0){
        
        calculatedAngle = offsetAngle - 90.0;
        dx = cosf(radians(calculatedAngle)) * _pathCircleRadius;
        dy = sinf(radians(calculatedAngle)) * _pathCircleRadius;
        NSLog(@"dx = %f  dy = %f", dx, dy);

        x = self.pathCircle.center.x + dx;
        y = self.pathCircle.center.y + dy;
    }
    if(offsetAngle > 180.0 && offsetAngle <= 270.0){

        calculatedAngle = 270.0 - offsetAngle;
        dx = cosf(radians(calculatedAngle)) * _pathCircleRadius;
        dy = sinf(radians(calculatedAngle)) * _pathCircleRadius;
        NSLog(@"dx = %f  dy = %f", dx, dy);

        x = self.pathCircle.center.x - dx;
        y = self.pathCircle.center.y + dy;
    }
    if(offsetAngle > 270.0 && offsetAngle <= 360.0){

        calculatedAngle = offsetAngle - 270.0;
        dx = cosf(radians(calculatedAngle)) * _pathCircleRadius;
        dy = sinf(radians(calculatedAngle)) * _pathCircleRadius;
        NSLog(@"dx = %f  dy = %f", dx, dy);

        x = self.pathCircle.center.x - dx;
        y = self.pathCircle.center.y - dy;
    }
    NSLog(@"X = %f  Y = %f", x, y);
    return CGPointMake(x, y);
}


- (BOOL) continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    
    NSLog(@"Touch continous");
    CGPoint touchPoint = [touch locationInView:self];
    CGFloat circumferenceAngle = [self updateTouchCircleCenter:touchPoint];

    //Circumference of circle 2PI*Radius
    CGFloat actualCircumference = radians(circumferenceAngle)*_pathCircleRadius;
//    NSLog(@"ACTUAL CIRCUMFERENCE %f", actualCircumference);
    CGFloat entireCircumference = 2*M_PI*_pathCircleRadius;
    
    CGFloat percent = (ceilf((actualCircumference/entireCircumference)*_sliderOffset));
//    NSLog(@"%f out of %d", percent, _sliderOffset);
    [self calculateInteractionCircleCenterPointFromSliderValue:(int)percent];
    [self setNeedsDisplay];
    
    return YES;
}

- (void) endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    NSLog(@"Touch ends");
}

static inline double radians (double degrees) { return degrees * M_PI/180; }
static inline double degree  (double radian)  { return radian * 180/M_PI;}

 #pragma mark - Drawing
- (void)drawRect:(CGRect)rect{

    self.sectorRect = rect;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    
    //Stroke path for circle
    CGColorSpaceRef outerPathColorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat outerPathComponents[] = {232.0/255.0, 233.0/255.0, 235.0/255.0, 1.0};
    CGColorRef outerPathColor = CGColorCreate(outerPathColorspace, outerPathComponents);
    
    //Draw intraction circle
    CGContextSetStrokeColorWithColor(context, outerPathColor);
    CGContextAddArc(context, rect.size.width/2, rect.size.height/2, _pathCircleRadius, radians(0.0), radians(360.0), 1);
    CGContextStrokePath(context);
   
    
    //Save the information of pathCircle
    CGFloat x = rect.size.width/2;
    CGFloat y = rect.size.height/2;
    self.pathCircle.center = CGPointMake(x, y);
    self.pathCircle.radius = 60;
    
    //Release
    CGColorSpaceRelease(outerPathColorspace);
    CGColorRelease(outerPathColor);
    
    //Stroke path for circle
    CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    CGFloat components[] = {0.0/255.0, 208.0/255.0, 28.0/255.0, 1.0};
    CGColorRef color = CGColorCreate(colorspace, components);
    
    //Draw intraction circle
    CGContextSetFillColor(context, components);
    CGContextAddArc(context, self.touchCircle.center.x, self.touchCircle.center.y, touchCircleRadius, radians(0.0), radians(360.0), 1);
    CGContextFillPath(context);
    
    //Save the information of pathCircle
    self.touchCircle.radius = touchCircleRadius;
 
    //Release
    CGColorSpaceRelease(colorspace);
    CGColorRelease(color);
}

@end
