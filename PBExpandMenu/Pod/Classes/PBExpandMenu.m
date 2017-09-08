//
//  PBExpandMenu.m
//  PBExpandMenu
//
//  Created by nanhujiaju on 2017/9/8.
//  Copyright © 2017年 nanhujiaju. All rights reserved.
//

#import "PBExpandMenu.h"

static const int kItemInitTag = 1001;
static const CGFloat kAngleOffset = M_PI_2 / 2;
static const CGFloat kballLength = 80;
static const float kdamping = 0.3;

@interface PBExpandMenu ()<UICollisionBehaviorDelegate>

@property (nonatomic, assign) CGFloat angle;

@property (nonatomic, assign) NSUInteger count ;
@property (nonatomic, strong) UIImageView *start;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableArray *positions;

// animator and behaviors
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;
@property (nonatomic, strong) NSMutableArray *snaps;

@property (nonatomic, strong) UITapGestureRecognizer *tapOnStart;

@property (nonatomic, strong) id<UIDynamicItem> bumper;
@property (nonatomic, assign) BOOL expanded;

@property (nonatomic, copy) expandEvent block;

@end

@implementation PBExpandMenu

- (instancetype)initWithCenterPoint:(CGPoint)CenterPoint startImage:(UIImage *)startImage submenuImages:(NSArray *)images {
    if (self = [super init]) {
        
        self.bounds = CGRectMake(0, 0, startImage.size.width, startImage.size.height);
        self.center = CenterPoint;
        
        _angle = kAngleOffset;
        _ballLength = kballLength;
        _damping = kdamping;
        
        _images = images;
        _count = self.images.count;
        _start = [[UIImageView alloc] initWithImage:startImage];
        _start.userInteractionEnabled = YES;
        _tapOnStart = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                              action:@selector(startTapped:)];
        [_start addGestureRecognizer:_tapOnStart];
        [self addSubview:_start];
    }
    return self;
}

- (void)commonSetup {
    self.items = [NSMutableArray array];
    self.positions = [NSMutableArray array];
    self.snaps = [NSMutableArray array];
    
    // setup the items
    for (int i = 0; i < self.count; i++) {
        UIImageView *item = [[UIImageView alloc] initWithImage:self.images[i]];
        item.tag = kItemInitTag + i;
        item.userInteractionEnabled = YES;
        [self.superview addSubview:item];
        
        CGPoint position = [self centerForExpandAtIndex:i];
        item.center = self.center;
        [self.positions addObject:[NSValue valueWithCGPoint:position]];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [item addGestureRecognizer:tap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
        [item addGestureRecognizer:pan];
        
        [self.items addObject:item];
    }
    
    [self.superview bringSubviewToFront:self];
    
    // setup animator and behavior
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.superview];
    
    self.collision = [[UICollisionBehavior alloc] initWithItems:self.items];
    self.collision.translatesReferenceBoundsIntoBoundary = YES;
    self.collision.collisionDelegate = self;
    
    for (int i = 0; i < self.count; i++) {
        UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.items[i] snapToPoint:self.center];
        snap.damping = self.damping;
        [self.snaps addObject:snap];
    }
    
    self.itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:self.items];
    self.itemBehavior.allowsRotation = NO;
    self.itemBehavior.elasticity = 1.2;
    self.itemBehavior.density = 0.5;
    self.itemBehavior.angularResistance = 5;
    self.itemBehavior.resistance = 10;
    self.itemBehavior.elasticity = 0.8;
    self.itemBehavior.friction = 0.5;
}

- (void)didMoveToSuperview {
    [self commonSetup];
}

- (void)removeFromSuperview {
    for (int i = 0; i < self.count; i++) {
        [self.items[i] removeFromSuperview];
    }
    
    [super removeFromSuperview];
}

- (CGPoint)centerForExpandAtIndex:(int)index {
    /*
     CGFloat firstAngle = M_PI + (M_PI_2 - self.angle) + index * self.angle;
     CGPoint startPoint = self.center;
     CGFloat x = startPoint.x + cos(firstAngle) * self.ballLength;
     CGFloat y = startPoint.y + sin(firstAngle) * self.ballLength;
     CGPoint position = CGPointMake(x, y);
     return position;
     //*/
    CGPoint startPoint = self.center;
    CGFloat x = startPoint.x;
    CGFloat y = startPoint.y - (index + 1) * self.ballLength * 0.75;
    CGPoint position = CGPointMake(x, y);
    return position;
}

- (void)expandSubmenu {
    for (int i = 0; i < self.count; i++) {
        [self snapToPostionsWithIndex:i];
    }
    
    self.expanded = YES;
}

- (void)shrinkSubmenu {
    [self.animator removeBehavior:self.collision];
    
    for (int i = 0; i < self.count; i++) {
        [self snapToStartWithIndex:i];
    }
    
    self.expanded = NO;
}

- (void)panned:(UIPanGestureRecognizer *)gesture {
    UIView *touchedView = gesture.view;
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.animator removeBehavior:self.itemBehavior];
        [self.animator removeBehavior:self.collision];
        [self removeSnapBehaviors];
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        touchedView.center = [gesture locationInView:self.superview];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        self.bumper = touchedView;
        [self.animator addBehavior:self.collision];
        NSUInteger index = [self.items indexOfObject:touchedView];
        
        if (index != NSNotFound) {
            [self snapToPostionsWithIndex:index];
        }
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior endedContactForItem:(id<UIDynamicItem>)item1 withItem:(id<UIDynamicItem>)item2 {
    [self.animator addBehavior:self.itemBehavior];
    
    if (item1 != self.bumper) {
        NSUInteger index = (int)[self.items indexOfObject:item1];
        if (index != NSNotFound) {
            [self snapToPostionsWithIndex:index];
        }
    }
    
    if (item2 != self.bumper) {
        NSUInteger index = (int)[self.items indexOfObject:item2];
        if (index != NSNotFound) {
            [self snapToPostionsWithIndex:index];
        }
    }
}

- (void)snapToStartWithIndex:(NSUInteger)index {
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.items[index] snapToPoint:self.center];
    snap.damping = self.damping;
    UISnapBehavior *snapToRemove = self.snaps[index];
    self.snaps[index] = snap;
    [self.animator removeBehavior:snapToRemove];
    [self.animator addBehavior:snap];
}

- (void)snapToPostionsWithIndex:(NSUInteger)index {
    id positionValue = self.positions[index];
    CGPoint position = [positionValue CGPointValue];
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.items[index] snapToPoint:position];
    snap.damping = self.damping;
    UISnapBehavior *snapToRemove = self.snaps[index];
    self.snaps[index] = snap;
    [self.animator removeBehavior:snapToRemove];
    [self.animator addBehavior:snap];
}

- (void)removeSnapBehaviors {
    [self.snaps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self.animator removeBehavior:obj];
    }];
}

- (void)rotateExpandBall:(BOOL)r {
    CGAffineTransform trans = CGAffineTransformIdentity;
    if (r) {
        trans = CGAffineTransformMakeRotation(M_PI_2 * 0.5);
    }
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.6 options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationCurveEaseInOut animations:^{
        self.start.transform = trans;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark --- touch event ---

- (void)handleExpandMenuEventWithCompletion:(expandEvent)block {
    self.block = [block copy];
}

- (void)tapped:(UITapGestureRecognizer *)gesture {
    int tag = (int)gesture.view.tag;
    tag -= kItemInitTag;
    if (self.block) {
        self.block(tag);
    }
    [self rotateExpandBall:!self.expanded];
    [self shrinkSubmenu];
}

- (void)startTapped:(UITapGestureRecognizer *)gesture {
    [self.animator removeBehavior:self.collision];
    [self.animator removeBehavior:self.itemBehavior];
    [self removeSnapBehaviors];
    
    [self rotateExpandBall:!self.expanded];
    if (self.expanded) {
        [self shrinkSubmenu];
    } else {
        [self expandSubmenu];
    }
}

- (void)resetExpandMenu2InitialState {
    if (!self.expanded) {
        return;
    }
    [self.animator removeBehavior:self.collision];
    [self.animator removeBehavior:self.itemBehavior];
    [self removeSnapBehaviors];
    
    [self rotateExpandBall:!self.expanded];
    [self shrinkSubmenu];
}

@end
