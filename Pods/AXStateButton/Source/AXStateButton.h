//
//  AXStateButton.h
//  AXStateButton
//
//  Created by Alex Hill on 8/18/17.
//  Copyright © 2017 Alex Hill. All rights reserved.
//

@import UIKit;

NS_SWIFT_NAME(StateButton)
@interface AXStateButton : UIButton

+ (nullable instancetype)button;

/**
 Whether or not to animate the control state transitions. Defaults to `YES`.
 */
@property BOOL animateControlStateChanges;

/**
 The duration of the transition animation. Defaults to `0.2`.
 */
@property NSTimeInterval controlStateAnimationDuration;

/**
 The timing function used during the transition animation. 
 Defaults to `-[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]`.
 */
@property (nonnull) CAMediaTimingFunction *controlStateAnimationTimingFunction;

/**
 Change the button's tint color based on its state.

 @param tintColor The desired tint color.
 @param controlState The button's control state.
 */
- (void)setTintColor:(nullable UIColor *)tintColor forState:(UIControlState)controlState;

/**
 Retrieve the button's tint color for a state.

 @param controlState The button's control state.
 @return The button's tint color.
 */
- (nullable UIColor *)tintColorForState:(UIControlState)controlState;

/**
 Change the button's background color based on its state.
 
 @param backgroundColor The desired background color.
 @param controlState The button's control state.
 */
- (void)setBackgroundColor:(nullable UIColor *)backgroundColor forState:(UIControlState)controlState;

/**
 Retrieve the button's background color for a state.
 
 @param controlState The button's control state.
 @return The button's background color.
 */
- (nullable UIColor *)backgroundColorForState:(UIControlState)controlState;

/**
 Change the button's alpha based on its state.
 
 @param alpha The desired alpha.
 @param controlState The button's control state.
 */
- (void)setAlpha:(CGFloat)alpha forState:(UIControlState)controlState;

/**
 Change the button title's alpha based on its state.
 
 @param alpha The desired alpha.
 @param controlState The button's control state.
 */
- (void)setTitleAlpha:(CGFloat)alpha forState:(UIControlState)controlState;

/**
 Retrieve the button title's alpha for a state.
 
 @param controlState The button's control state.
 @return The button title's alpha.
 */
- (CGFloat)titleAlphaForState:(UIControlState)controlState;

/**
 Change the button image's alpha based on its state.
 
 @param alpha The desired alpha.
 @param controlState The button's control state.
 */
- (void)setImageAlpha:(CGFloat)alpha forState:(UIControlState)controlState;

/**
 Retrieve the button image's alpha for a state.
 
 @param controlState The button's control state.
 @return The button image's alpha.
 */
- (CGFloat)imageAlphaForState:(UIControlState)controlState;

/**
 Retrieve the button's alpha for a state.
 
 @param controlState The button's control state.
 @return The button's alpha.
 */
- (CGFloat)alphaForState:(UIControlState)controlState;

/**
 Change the button's layer's corner radius based on its state.
 
 @param cornerRadius The desired cornerRadius.
 @param controlState The button's control state.
 */
- (void)setCornerRadius:(CGFloat)cornerRadius forState:(UIControlState)controlState;

/**
 Retrieve the button's layer's corner radius for a state.
 
 @param controlState The button's control state.
 @return The button's corner radius.
 */
- (CGFloat)cornerRadiusForState:(UIControlState)controlState;

/**
 Change the button's border color based on its state.
 
 @param borderColor The desired border color.
 @param controlState The button's control state.
 */
- (void)setBorderColor:(nullable UIColor *)borderColor forState:(UIControlState)controlState;

/**
 Retrieve the button's border color for a state.
 
 @param controlState The button's control state.
 @return The button's border color.
 */
- (nullable UIColor *)borderColorForState:(UIControlState)controlState;

/**
 Change the button's border width based on its state.
 
 @param borderWidth The desired border width.
 @param controlState The button's control state.
 */
- (void)setBorderWidth:(CGFloat)borderWidth forState:(UIControlState)controlState;

/**
 Retrieve the button's border width for a state.
 
 @param controlState The button's control state.
 @return The button's border width.
 */
- (CGFloat)borderWidthForState:(UIControlState)controlState;

/**
 Change the button's transform.rotation.x based on its state.
 
 @param radians The desired angle in radians.
 @param controlState The button's control state.
 */
- (void)setTransformRotationX:(CGFloat)radians forState:(UIControlState)controlState;

/**
 Retrieve the button's transform.rotation.x for a state.
 
 @param controlState The button's control state.
 @return The button's rotation.x.
 */
- (CGFloat)transformRotationXForState:(UIControlState)controlState;

/**
 Change the button's transform.rotation.y based on its state.
 
 @param radians The desired angle in radians.
 @param controlState The button's control state.
 */
- (void)setTransformRotationY:(CGFloat)radians forState:(UIControlState)controlState;

/**
 Retrieve the button's transform.rotation.y for a state.
 
 @param controlState The button's control state.
 @return The button's rotation.y.
 */
- (CGFloat)transformRotationYForState:(UIControlState)controlState;

/**
 Change the button's transform.rotation.z based on its state.

 @param radians The desired angle in radians.
 @param controlState The button's control state.
 */
- (void)setTransformRotationZ:(CGFloat)radians forState:(UIControlState)controlState;

/**
 Retrieve the button's transform.rotation.z for a state.

 @param controlState The button's control state.
 @return The button's rotation.z.
 */
- (CGFloat)transformRotationZForState:(UIControlState)controlState;

/**
 Change the button's transform.scale based on its state.
 
 @param scale The desired scale.
 @param controlState The button's control state.
 */
- (void)setTransformScale:(CGFloat)scale forState:(UIControlState)controlState;

/**
 Retrieve the button's transform.scale for a state.
 
 @param controlState The button's control state.
 @return The button's transform.scale.
 */
- (CGFloat)transformScaleForState:(UIControlState)controlState;

/**
 Change the button's shadow color based on its state.

 @param shadowColor The desired shadow color.
 @param controlState The button's control state.
 */
- (void)setShadowColor:(nullable UIColor *)shadowColor forState:(UIControlState)controlState;

/**
 Retrieve the button's shadow color for a state.

 @param controlState The button's control state.
 @return The button's shadow color.
 */
- (nullable UIColor *)shadowColorForState:(UIControlState)controlState;

/**
 Change the button's shadow color based on its state.

 @param shadowOpacity The desired shadow opacity.
 @param controlState The button's control state.
 */
- (void)setShadowOpacity:(CGFloat)shadowOpacity forState:(UIControlState)controlState;

/**
 Retrieve the button's shadow opacity for a state.
 
 @param controlState The button's control state.
 @return The button's shadow opacity.
 */
- (CGFloat)shadowOpacityForState:(UIControlState)controlState;

/**
 Change the button's shadow offset based on its state.

 @param shadowOffset The desired shadow offset.
 @param controlState The button's control state.
 */
- (void)setShadowOffset:(CGSize)shadowOffset forState:(UIControlState)controlState;

/**
 Retrieve the button's shadow offset for a state.
 
 @param controlState The button's control state.
 @return The button's shadow offset.
 */
- (CGSize)shadowOffsetForState:(UIControlState)controlState;

/**
 Change the button's shadow radius based on its state.
 
 @param shadowRadius The desired shadow radius.
 @param controlState The button's control state.
 */
- (void)setShadowRadius:(CGFloat)shadowRadius forState:(UIControlState)controlState;

/**
 Retrieve the button's shadow radius for a state.
 
 @param controlState The button's control state.
 @return The button's shadow radius.
 */
- (CGFloat)shadowRadiusForState:(UIControlState)controlState;

/**
 Change the button's shadow path based on its state.
 
 @param shadowPath The desired shadow path.
 @param controlState The button's control state.
 */
- (void)setShadowPath:(nullable UIBezierPath *)shadowPath forState:(UIControlState)controlState;

/**
 Retrieve the button's shadow path for a state.
 
 @param controlState The button's control state.
 @return The button's shadow path.
 */
- (nullable UIBezierPath *)shadowPathForState:(UIControlState)controlState;

@end
