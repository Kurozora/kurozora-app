//
//  AXStateButton.m
//  AXStateButton
//
//  Created by Alex Hill on 8/18/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

#import "AXStateButton.h"

static NSString *_Nonnull AXStateButtonTintColorKey            = @"AXStateButtonTintColor";
static NSString *_Nonnull AXStateButtonBackgroundColorKey      = @"AXStateButtonBackgroundColor";
static NSString *_Nonnull AXStateButtonAlphaKey                = @"AXStateButtonAlpha";
static NSString *_Nonnull AXStateButtonTitleAlphaKey           = @"AXStateButtonTitleAlpha";
static NSString *_Nonnull AXStateButtonImageAlphaKey           = @"AXStateButtonImageAlpha";
static NSString *_Nonnull AXStateButtonCornerRadiusKey         = @"AXStateButtonCornerRadius";
static NSString *_Nonnull AXStateButtonBorderColorKey          = @"AXStateButtonBorderColor";
static NSString *_Nonnull AXStateButtonBorderWidthKey          = @"AXStateButtonBorderWidth";
static NSString *_Nonnull AXStateButtonTransformRotationXKey   = @"AXStateButtonTransformRotationX";
static NSString *_Nonnull AXStateButtonTransformRotationYKey   = @"AXStateButtonTransformRotationY";
static NSString *_Nonnull AXStateButtonTransformRotationZKey   = @"AXStateButtonTransformRotationZ";
static NSString *_Nonnull AXStateButtonTransformScaleKey       = @"AXStateButtonTransformScale";
static NSString *_Nonnull AXStateButtonShadowColorKey          = @"AXStateButtonShadowColor";
static NSString *_Nonnull AXStateButtonShadowOpacityKey        = @"AXStateButtonShadowOpacity";
static NSString *_Nonnull AXStateButtonShadowOffsetKey         = @"AXStateButtonShadowOffset";
static NSString *_Nonnull AXStateButtonShadowRadiusKey         = @"AXStateButtonShadowRadius";
static NSString *_Nonnull AXStateButtonShadowPathKey           = @"AXStateButtonShadowPath";

static NSString *_Nonnull AXAnimationDictionaryKey    = @"AXAnimationDictionary";
static NSString *_Nonnull AXStateBlockKey             = @"AXStateBlock";

static NSString *_Nonnull AXAnimationDictionaryAnimationKey               = @"AXAnimation";
static NSString *_Nonnull AXAnimationDictionaryAnimationLayerKeyPathKey   = @"AXAnimationLayerKeyPath";

static NSString *_Nonnull AXAnimationDefaultLayerKeyPath = @"layer";

typedef NSDictionary<NSString *, id> * AXAnimationDictionary;
typedef NSMutableDictionary<NSString *, NSArray<CAAnimation *> *> * AXAnimationKeyPathDictionary;
typedef void(^AXStateBlock)(void);

@interface AXStateButton ()

@property (nonnull) NSDictionary<NSString *, NSMutableDictionary<NSNumber *, id> *> *stateDictionary;

@end

@implementation AXStateButton

#pragma mark - Initialization
+ (instancetype)button {
    return [super buttonWithType:UIButtonTypeCustom];
}

+ (instancetype)buttonWithType:(UIButtonType)buttonType {
    [NSException raise:@"AXUnsupportedFactoryMethodException" format:@"Use +[AXStateButton button] instead."];
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self commonInit];
    }
    
    return self;
}

- (void)commonInit {
    self.animateControlStateChanges = YES;
    self.controlStateAnimationDuration = 0.2;
    self.controlStateAnimationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    self.adjustsImageWhenHighlighted = NO;
    self.adjustsImageWhenDisabled = NO;
    
    NSArray<NSString *> *keys = @[ AXStateButtonTintColorKey,
                                   AXStateButtonBackgroundColorKey,
                                   AXStateButtonAlphaKey,
                                   AXStateButtonTitleAlphaKey,
                                   AXStateButtonImageAlphaKey,
                                   AXStateButtonCornerRadiusKey,
                                   AXStateButtonBorderColorKey,
                                   AXStateButtonBorderWidthKey,
                                   AXStateButtonTransformRotationXKey,
                                   AXStateButtonTransformRotationYKey,
                                   AXStateButtonTransformRotationZKey,
                                   AXStateButtonTransformScaleKey,
                                   AXStateButtonShadowColorKey,
                                   AXStateButtonShadowOpacityKey,
                                   AXStateButtonShadowOffsetKey,
                                   AXStateButtonShadowRadiusKey ];
    
    NSMutableDictionary<NSString *, NSMutableDictionary<NSNumber *, id> *> *stateDictionary = [NSMutableDictionary dictionary];
    for (NSString *key in keys) {
        stateDictionary[key] = [NSMutableDictionary dictionary];
    }
    
    self.stateDictionary = [stateDictionary copy];
}

- (void)willMoveToWindow:(UIWindow *)newWindow {
    [super willMoveToWindow:newWindow];
    
    if (newWindow) {
        [self updateButtonStateWithoutAnimation];
    }
}

#pragma mark - Control state updates
- (void)setSelected:(BOOL)selected {
    BOOL updateButtonState = (self.isSelected != selected);
    
    [super setSelected:selected];
    
    if (updateButtonState) {
        [self updateButtonState];
    }
}

- (void)setHighlighted:(BOOL)highlighted {
    BOOL updateButtonState = (self.isHighlighted != highlighted);
    
    [super setHighlighted:highlighted];
    
    if (updateButtonState) {
        [self updateButtonState];
    }
}

- (void)setEnabled:(BOOL)enabled {
    BOOL updateButtonState = (self.isEnabled != enabled);
    
    [super setEnabled:enabled];

    if (updateButtonState) {
        [self updateButtonState];
    }
}

- (void)updateButtonStateWithoutAnimation {
    BOOL animateControlStateChanges = self.animateControlStateChanges;
    self.animateControlStateChanges = NO;
    [self updateButtonState];
    self.animateControlStateChanges = animateControlStateChanges;
}

- (void)updateButtonState {
    NSArray<NSDictionary<NSString *, id> *> *stateChanges = [self stateChangesForCurrentState];
    AXAnimationKeyPathDictionary animationsDictionary = [NSMutableDictionary dictionary];
    NSMutableArray<AXStateBlock> *stateBlocks = [NSMutableArray array];
    
    for (NSDictionary<NSString *, id> *stateChange in stateChanges) {
        AXAnimationDictionary animationDictionary = stateChange[AXAnimationDictionaryKey];
        if (animationDictionary) {
            CAAnimation *animation = animationDictionary[AXAnimationDictionaryAnimationKey];
            if (!animation) {
                continue;
            }
            
            NSString *keyPath = animationDictionary[AXAnimationDictionaryAnimationLayerKeyPathKey] ?: AXAnimationDefaultLayerKeyPath;
            if (!animationsDictionary[keyPath]) {
                animationsDictionary[keyPath] = [NSArray array];
            }
            
            NSMutableArray<CAAnimation *> *animations = [animationsDictionary[keyPath] mutableCopy];
            [animations addObject:animation];
            animationsDictionary[keyPath] = [animations copy];
        }
        
        AXStateBlock stateBlock = stateChange[AXStateBlockKey];
        if (stateBlock) {
            [stateBlocks addObject:stateBlock];
        }
    }
    
    for (NSString *keyPath in [animationsDictionary allKeys]) {
        NSArray<CAAnimation *> *animations = animationsDictionary[keyPath];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.duration = self.controlStateAnimationDuration;
        group.timingFunction = self.controlStateAnimationTimingFunction;
        group.animations = animations;
        
        [[self valueForKeyPath:keyPath] addAnimation:group forKey:@"AXGroupAnim"];
    }
    
    for (AXStateBlock stateBlock in stateBlocks) {
        stateBlock();
    }
}

#pragma mark - Control states
- (void)setTintColor:(UIColor *)tintColor forState:(UIControlState)controlState {
    if (tintColor) {
        self.stateDictionary[AXStateButtonTintColorKey][@(controlState)] = tintColor;
    } else {
        [self.stateDictionary[AXStateButtonTintColorKey] removeObjectForKey:@(controlState)];
    }
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (UIColor *)tintColorForState:(UIControlState)controlState {
    return self.stateDictionary[AXStateButtonTintColorKey][@(controlState)];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor forState:(UIControlState)controlState {
    if (backgroundColor) {
        self.stateDictionary[AXStateButtonBackgroundColorKey][@(controlState)] = backgroundColor;
    } else {
        [self.stateDictionary[AXStateButtonBackgroundColorKey] removeObjectForKey:@(controlState)];
    }
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (UIColor *)backgroundColorForState:(UIControlState)controlState {
    return self.stateDictionary[AXStateButtonBackgroundColorKey][@(controlState)];
}

- (void)setAlpha:(CGFloat)alpha forState:(UIControlState)controlState {
    self.stateDictionary[AXStateButtonAlphaKey][@(controlState)] = @(alpha);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)alphaForState:(UIControlState)controlState {
    return [self.stateDictionary[AXStateButtonAlphaKey][@(controlState)] floatValue];
}

- (void)setTitleAlpha:(CGFloat)alpha forState:(UIControlState)controlState {
    self.stateDictionary[AXStateButtonTitleAlphaKey][@(controlState)] = @(alpha);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)titleAlphaForState:(UIControlState)controlState {
    return [self.stateDictionary[AXStateButtonTitleAlphaKey][@(controlState)] floatValue];
}

- (void)setImageAlpha:(CGFloat)alpha forState:(UIControlState)controlState {
    self.stateDictionary[AXStateButtonImageAlphaKey][@(controlState)] = @(alpha);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)imageAlphaForState:(UIControlState)controlState {
    return [self.stateDictionary[AXStateButtonImageAlphaKey][@(controlState)] floatValue];
}

- (void)setCornerRadius:(CGFloat)cornerRadius forState:(UIControlState)controlState {
    self.stateDictionary[AXStateButtonCornerRadiusKey][@(controlState)] = @(cornerRadius);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)cornerRadiusForState:(UIControlState)controlState {
    return [self.stateDictionary[AXStateButtonCornerRadiusKey][@(controlState)] floatValue];
}

- (void)setBorderColor:(UIColor *)borderColor forState:(UIControlState)controlState {
    if (borderColor) {
        self.stateDictionary[AXStateButtonBorderColorKey][@(controlState)] = borderColor;
    } else {
        [self.stateDictionary[AXStateButtonBorderColorKey] removeObjectForKey:@(controlState)];
    }
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (UIColor *)borderColorForState:(UIControlState)controlState {
    return self.stateDictionary[AXStateButtonBorderColorKey][@(controlState)];
}

- (void)setBorderWidth:(CGFloat)borderWidth forState:(UIControlState)controlState {
    self.stateDictionary[AXStateButtonBorderWidthKey][@(controlState)] = @(borderWidth);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)borderWidthForState:(UIControlState)controlState {
    return [self.stateDictionary[AXStateButtonBorderWidthKey][@(controlState)] floatValue];
}

- (void)setTransformRotationX:(CGFloat)radians forState:(UIControlState)controlState {
    self.stateDictionary[AXStateButtonTransformRotationXKey][@(controlState)] = @(radians);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)transformRotationXForState:(UIControlState)controlState {
    return [self.stateDictionary[AXStateButtonTransformRotationXKey][@(controlState)] floatValue];
}

- (void)setTransformRotationY:(CGFloat)radians forState:(UIControlState)controlState {
    self.stateDictionary[AXStateButtonTransformRotationYKey][@(controlState)] = @(radians);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)transformRotationYForState:(UIControlState)controlState {
    return [self.stateDictionary[AXStateButtonTransformRotationYKey][@(controlState)] floatValue];
}

- (void)setTransformRotationZ:(CGFloat)radians forState:(UIControlState)controlState {
    self.stateDictionary[AXStateButtonTransformRotationZKey][@(controlState)] = @(radians);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)transformRotationZForState:(UIControlState)controlState {
    return [self.stateDictionary[AXStateButtonTransformRotationZKey][@(controlState)] floatValue];
}

- (void)setTransformScale:(CGFloat)scale forState:(UIControlState)controlState {
    self.stateDictionary[AXStateButtonTransformScaleKey][@(controlState)] = @(scale);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)transformScaleForState:(UIControlState)controlState {
    return [self.stateDictionary[AXStateButtonTransformScaleKey][@(controlState)] floatValue];
}

- (void)setShadowColor:(UIColor *)shadowColor forState:(UIControlState)controlState {
    if (shadowColor) {
        self.stateDictionary[AXStateButtonShadowColorKey][@(controlState)] = shadowColor;
    } else {
        [self.stateDictionary[AXStateButtonShadowColorKey] removeObjectForKey:@(controlState)];
    }
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (UIColor *)shadowColorForState:(UIControlState)controlState {
    return self.stateDictionary[AXStateButtonShadowColorKey][@(controlState)];
}

- (void)setShadowOpacity:(CGFloat)shadowOpacity forState:(UIControlState)controlState {
    self.stateDictionary[AXStateButtonShadowOpacityKey][@(controlState)] = @(shadowOpacity);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)shadowOpacityForState:(UIControlState)controlState {
    return [self.stateDictionary[AXStateButtonShadowOpacityKey][@(controlState)] floatValue];
}

- (void)setShadowOffset:(CGSize)shadowOffset forState:(UIControlState)controlState {
    self.stateDictionary[AXStateButtonShadowOffsetKey][@(controlState)] = [NSValue valueWithCGSize:shadowOffset];
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGSize)shadowOffsetForState:(UIControlState)controlState {
    return [(NSValue *)self.stateDictionary[AXStateButtonShadowOffsetKey][@(controlState)] CGSizeValue];
}

- (void)setShadowRadius:(CGFloat)shadowRadius forState:(UIControlState)controlState {
    self.stateDictionary[AXStateButtonShadowRadiusKey][@(controlState)] = @(shadowRadius);
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (CGFloat)shadowRadiusForState:(UIControlState)controlState {
    return [self.stateDictionary[AXStateButtonShadowRadiusKey][@(controlState)] floatValue];
}

- (void)setShadowPath:(UIBezierPath *)shadowPath forState:(UIControlState)controlState {
    if (shadowPath) {
        self.stateDictionary[AXStateButtonShadowPathKey][@(controlState)] = shadowPath;
    } else {
        [self.stateDictionary[AXStateButtonShadowPathKey] removeObjectForKey:@(controlState)];
    }
    
    if (self.window) {
        [self updateButtonStateWithoutAnimation];
    }
}

- (UIBezierPath *)shadowPathForState:(UIControlState)controlState {
    return self.stateDictionary[AXStateButtonShadowPathKey][@(controlState)];
}

#pragma mark - Factory methods
- (NSArray<NSDictionary<NSString *, id> *> *)stateChangesForCurrentState {
    UIControlState currentState = self.state;
    
    NSMutableArray<NSDictionary<NSString *, id> *> *stateChangesDictionary = [NSMutableArray array];
    
    [self.stateDictionary enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull propertyKey,
                                                              NSMutableDictionary<NSNumber *,id> * _Nonnull stateDictionary,
                                                              BOOL * _Nonnull stop) {
        
        UIControlState state = currentState;
        id value = stateDictionary[@(state)];
        if (!value) {
            if (state == UIControlStateNormal) {
                return;
            }
            
            // default to normal
            state = UIControlStateNormal;
            value = stateDictionary[@(state)];
            if (!value) {
                return;
            }
        }
        
        NSDictionary<NSString *, id> *changes = nil;
        
        if (propertyKey == AXStateButtonTintColorKey) {
            changes = [self tintColorStateChangesForState:state];
        } else if (propertyKey == AXStateButtonBackgroundColorKey) {
            changes = [self backgroundColorStateChangesForState:state];
        } else if (propertyKey == AXStateButtonAlphaKey) {
            changes = [self alphaStateChangesForState:state];
        } else if (propertyKey == AXStateButtonTitleAlphaKey) {
            changes = [self titleAlphaStateChangesForState:state];
        } else if (propertyKey == AXStateButtonImageAlphaKey) {
            changes = [self imageAlphaStateChangesForState:state];
        } else if (propertyKey == AXStateButtonCornerRadiusKey) {
            changes = [self cornerRadiusStateChangesForState:state];
        } else if (propertyKey == AXStateButtonBorderColorKey) {
            changes = [self borderColorStateChangesForState:state];
        } else if (propertyKey == AXStateButtonBorderWidthKey) {
            changes = [self borderWidthStateChangesForState:state];
        } else if (propertyKey == AXStateButtonTransformRotationXKey) {
            changes = [self transformRotationXStateChangesForState:state];
        } else if (propertyKey == AXStateButtonTransformRotationYKey) {
            changes = [self transformRotationYStateChangesForState:state];
        } else if (propertyKey == AXStateButtonTransformRotationZKey) {
            changes = [self transformRotationZStateChangesForState:state];
        } else if (propertyKey == AXStateButtonTransformScaleKey) {
            changes = [self transformScaleStateChangesForState:state];
        } else if (propertyKey == AXStateButtonShadowColorKey) {
            changes = [self shadowColorStateChangesForState:state];
        } else if (propertyKey == AXStateButtonShadowOpacityKey) {
            changes = [self shadowOpacityStateChangesForState:state];
        } else if (propertyKey == AXStateButtonShadowOffsetKey) {
            changes = [self shadowOffsetStateChangesForState:state];
        } else if (propertyKey == AXStateButtonShadowRadiusKey) {
            changes = [self shadowOffsetStateChangesForState:state];
        } else if (propertyKey == AXStateButtonShadowPathKey) {
            changes = [self shadowPathStateChangesForState:state];
        }
        
        if (changes) {
            [stateChangesDictionary addObject:changes];
        }
    }];
    
    return [stateChangesDictionary copy];
}

- (NSDictionary<NSString *, id> *)tintColorStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    AXStateBlock block = ^() {
        weakSelf.tintColor = [weakSelf tintColorForState:controlState];
    };
    
    return @{ AXStateBlockKey: block };
}

- (NSDictionary<NSString *, id> *)backgroundColorStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *backgroundColorKeyPath = @"backgroundColor";
        CGColorRef fromValue = (__bridge CGColorRef)([self.layer.presentationLayer valueForKeyPath:backgroundColorKeyPath]);
        CGColorRef toValue = [self backgroundColorForState:controlState].CGColor;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:backgroundColorKeyPath];
        animation.fromValue = (__bridge id _Nullable)fromValue;
        animation.toValue = (__bridge id _Nullable)toValue;
        
        AXStateBlock block = ^() {
            weakSelf.layer.backgroundColor = toValue;
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            weakSelf.layer.backgroundColor = [weakSelf backgroundColorForState:controlState].CGColor;
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)alphaStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *opacityKeyPath = @"opacity";
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:opacityKeyPath] floatValue];
        CGFloat toValue = [self alphaForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:opacityKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AXStateBlock block = ^() {
            weakSelf.layer.opacity = toValue;
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            weakSelf.layer.opacity = [weakSelf alphaForState:controlState];
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)titleAlphaStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *opacityKeyPath = @"opacity";
        CGFloat fromValue = [[self.titleLabel.layer.presentationLayer valueForKeyPath:opacityKeyPath] floatValue];
        CGFloat toValue = [self titleAlphaForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:opacityKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AXStateBlock block = ^() {
            weakSelf.titleLabel.layer.opacity = toValue;
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation,
                                              AXAnimationDictionaryAnimationLayerKeyPathKey: @"titleLabel.layer" },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            weakSelf.titleLabel.layer.opacity = [weakSelf titleAlphaForState:controlState];
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)imageAlphaStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *opacityKeyPath = @"opacity";
        CGFloat fromValue = [[self.imageView.layer.presentationLayer valueForKeyPath:opacityKeyPath] floatValue];
        CGFloat toValue = [self imageAlphaForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:opacityKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AXStateBlock block = ^() {
            weakSelf.imageView.layer.opacity = toValue;
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation,
                                              AXAnimationDictionaryAnimationLayerKeyPathKey: @"imageView.layer" },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            weakSelf.imageView.layer.opacity = [weakSelf imageAlphaForState:controlState];
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)cornerRadiusStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *cornerRadiusKeyPath = @"cornerRadius";
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:cornerRadiusKeyPath] floatValue];
        CGFloat toValue = [self cornerRadiusForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:cornerRadiusKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AXStateBlock block = ^() {
            weakSelf.layer.cornerRadius = toValue;
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            weakSelf.layer.cornerRadius = [weakSelf cornerRadiusForState:controlState];
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)borderColorStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *borderColorKeyPath = @"borderColor";
        CGColorRef fromValue = (__bridge CGColorRef)([self.layer.presentationLayer valueForKeyPath:borderColorKeyPath]);
        CGColorRef toValue = [self borderColorForState:controlState].CGColor;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:borderColorKeyPath];
        animation.fromValue = (__bridge id _Nullable)(fromValue);
        animation.toValue = (__bridge id _Nullable)(toValue);
        
        AXStateBlock block = ^() {
            weakSelf.layer.borderColor = toValue;
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            weakSelf.layer.borderColor = [weakSelf borderColorForState:controlState].CGColor;
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)borderWidthStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *borderWidthKeyPath = @"borderWidth";
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:borderWidthKeyPath] floatValue];
        CGFloat toValue = [self borderWidthForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:borderWidthKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AXStateBlock block = ^() {
            weakSelf.layer.borderWidth = toValue;
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            weakSelf.layer.borderWidth = [weakSelf borderWidthForState:controlState];
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)transformRotationXStateChangesForState:(UIControlState)controlState {
    NSString *xRotationKeyPath = @"transform.rotation.x";
    
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:xRotationKeyPath] floatValue];
        CGFloat toValue = [self transformRotationXForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:xRotationKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AXStateBlock block = ^() {
            [weakSelf.layer setValue:@(toValue) forKeyPath:xRotationKeyPath];
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            [weakSelf.layer setValue:@([weakSelf transformRotationXForState:controlState]) forKeyPath:xRotationKeyPath];
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)transformRotationYStateChangesForState:(UIControlState)controlState {
    NSString *yRotationKeyPath = @"transform.rotation.y";
    
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:yRotationKeyPath] floatValue];
        CGFloat toValue = [self transformRotationYForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:yRotationKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AXStateBlock block = ^() {
            [weakSelf.layer setValue:@(toValue) forKeyPath:yRotationKeyPath];
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            [weakSelf.layer setValue:@([weakSelf transformRotationYForState:controlState]) forKeyPath:yRotationKeyPath];
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)transformRotationZStateChangesForState:(UIControlState)controlState {
    NSString *zRotationKeyPath = @"transform.rotation.z";
    
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:zRotationKeyPath] floatValue];
        CGFloat toValue = [self transformRotationZForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:zRotationKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AXStateBlock block = ^() {
            [weakSelf.layer setValue:@(toValue) forKeyPath:zRotationKeyPath];
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            [weakSelf.layer setValue:@([weakSelf transformRotationZForState:controlState]) forKeyPath:zRotationKeyPath];
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)transformScaleStateChangesForState:(UIControlState)controlState {
    NSString *scaleKeyPath = @"transform.scale";
    
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:scaleKeyPath] floatValue];
        CGFloat toValue = [self transformScaleForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:scaleKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AXStateBlock block = ^() {
            [weakSelf.layer setValue:@(toValue) forKeyPath:scaleKeyPath];
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            [weakSelf.layer setValue:@([weakSelf transformScaleForState:controlState]) forKeyPath:scaleKeyPath];
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)shadowColorStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *shadowColorKeyPath = @"shadowColor";
        CGColorRef fromValue = (__bridge CGColorRef)([self.layer.presentationLayer valueForKeyPath:shadowColorKeyPath]);
        CGColorRef toValue = [self shadowColorForState:controlState].CGColor;
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:shadowColorKeyPath];
        animation.fromValue = (__bridge id _Nullable)fromValue;
        animation.toValue = (__bridge id _Nullable)toValue;
        
        AXStateBlock block = ^() {
            weakSelf.layer.shadowColor = toValue;
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            weakSelf.layer.shadowColor = [weakSelf shadowColorForState:controlState].CGColor;
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)shadowOpacityStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *shadowOpacityKeyPath = @"shadowOpacity";
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:shadowOpacityKeyPath] floatValue];
        CGFloat toValue = [self shadowOpacityForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:shadowOpacityKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AXStateBlock block = ^() {
            weakSelf.layer.shadowOpacity = toValue;
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            weakSelf.layer.shadowOpacity = [weakSelf shadowOpacityForState:controlState];
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)shadowOffsetStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *shadowOffsetKeyPath = @"shadowOffset";
        CGSize fromValue = [[self.layer.presentationLayer valueForKeyPath:shadowOffsetKeyPath] CGSizeValue];
        CGSize toValue = [self shadowOffsetForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:shadowOffsetKeyPath];
        animation.fromValue = [NSValue valueWithCGSize:fromValue];
        animation.toValue = [NSValue valueWithCGSize:toValue];
        
        AXStateBlock block = ^() {
            weakSelf.layer.shadowOffset = toValue;
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            weakSelf.layer.shadowOffset = [weakSelf shadowOffsetForState:controlState];
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)shadowRadiusStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *shadowRadiusKeyPath = @"shadowRadius";
        CGFloat fromValue = [[self.layer.presentationLayer valueForKeyPath:shadowRadiusKeyPath] floatValue];
        CGFloat toValue = [self shadowRadiusForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:shadowRadiusKeyPath];
        animation.fromValue = @(fromValue);
        animation.toValue = @(toValue);
        
        AXStateBlock block = ^() {
            weakSelf.layer.shadowRadius = toValue;
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            weakSelf.layer.shadowRadius = [weakSelf shadowRadiusForState:controlState];
        };
        
        return @{ AXStateBlockKey: block };
    }
}

- (NSDictionary<NSString *, id> *)shadowPathStateChangesForState:(UIControlState)controlState {
    __weak typeof(self) weakSelf = self;
    
    if (self.animateControlStateChanges) {
        NSString *shadowPathKeyPath = @"shadowPath";
        UIBezierPath *fromValue = [self.layer.presentationLayer valueForKeyPath:shadowPathKeyPath];
        UIBezierPath *toValue = [self shadowPathForState:controlState];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:shadowPathKeyPath];
        animation.fromValue = fromValue;
        animation.toValue = toValue;
        
        AXStateBlock block = ^() {
            weakSelf.layer.shadowPath = toValue.CGPath;
        };
        
        return @{
                 AXAnimationDictionaryKey: @{ AXAnimationDictionaryAnimationKey: animation },
                 AXStateBlockKey: block
                 };
    } else {
        AXStateBlock block = ^() {
            weakSelf.layer.shadowPath = [weakSelf shadowPathForState:controlState].CGPath;
        };
        
        return @{ AXStateBlockKey: block };
    }
}

@end
