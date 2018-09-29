# AXStateButton
AXStateButton is a simple UIButton subclass that offers state-based button customization akin to that of Apple's. The idea is  nothing fancy, but can be used as the building blocks to create something a bit more complex. All it takes to get started is:

```objc
AXStateButton *button = [AXStateButton button];

// some arbitrary customizations
[button setCornerRadius:0.0f forState:UIControlStateNormal];
[button setCornerRadius:6.0f forState:UIControlStateSelected];
[button setCornerRadius:6.0f forState:UIControlStateHighlighted | UIControlStateSelected];

[button setTransformRotationZ:0 forState:UIControlStateNormal];
[button setTransformRotationZ:M_PI_4 forState:UIControlStateSelected];

// customize the rest of your button...

[self.view addSubview:button];
```

### "Well, what properties are state-configurable?"
* Tint color
* Background color
* Alpha
* Title alpha
* Image alpha
* Corner radius
* Border color
* Border width
* Transform rotation (x, y, z)
* Transform scale
* Shadow color
* Shadow opacity
* Shadow offset
* Shadow radius
* Shadow path

#### Todo?
* Custom view for state

### Other useful things
You can also adjust the animation duration of your state transitions:
```objc
button.controlStateAnimationDuration = 0.1;
```

On top of that, you can change the timing function used when animating control state changes:
```objc
button.controlStateAnimationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
```

Or, you can disable animations all together:
```objc
button.animateControlStateChanges = NO;
```

For convenience, it's possible to access your set values:
```objc
CGFloat cornerRadius = [button cornerRadiusForState:UIControlStateHighlighted | UIControlStateSelected];
// great success!
```

### Contributions
If you see a bug, you are welcome to open a Github issue and I will attempt to get to it as soon as I can. Of course, you are _also_ welcome to fork the repo and create a pull request with your changes. I'd be happy to look them over!
