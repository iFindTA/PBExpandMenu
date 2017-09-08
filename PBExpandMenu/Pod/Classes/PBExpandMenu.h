//
//  PBExpandMenu.h
//  PBExpandMenu
//
//  Created by nanhujiaju on 2017/9/8.
//  Copyright © 2017年 nanhujiaju. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 enpand menu touch event
 
 @param idx item
 */
typedef void(^expandEvent)(int idx);

@interface PBExpandMenu : UIView

/**
 init method for expand menu
 
 @param CenterPoint for menu
 @param startImage background image for menu
 @param images items image
 @return instance
 */
- (instancetype)initWithCenterPoint:(CGPoint)CenterPoint
                         startImage:(UIImage *)startImage
                      submenuImages:(NSArray *)images;


/**
 Damping coefficient
 */
@property (nonatomic, assign) CGFloat damping;

/**
 ball circle radius
 */
@property (nonatomic, assign) CGFloat ballLength;

/**
 handle expand touch event
 
 @param block the event
 */
- (void)handleExpandMenuEventWithCompletion:(expandEvent)block;

/**
 reset state for initial state
 */
- (void)resetExpandMenu2InitialState;

@end
