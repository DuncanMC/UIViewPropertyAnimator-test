##UIViewPropertyAnimator test

This project demonstrates the new `UIViewPropertyAnimator` class that was added to iOS 10.

A `UIViewPropertyAnimator` allows you to easily create UIView-based animations that can be paused, reversed, and scrubbed back and forth. 

It used to be that you had to use low-level `CAAnimation` objects in order to do these things.

A `UIViewPropertyAnimator` objet takes a block of animations, very much like the older `animate(withDuration:animations:)` family of `UIView` class methods. However, a `UIViewPropertyAnimator` can be used to run mulitiple animation blocks.

In this project I create a `UIViewPropertyAnimator` without providing an animation block, and then add animations when they are triggered in the UI.

The app has a slider that both tracks the progress of the animation from 0.0 (not yet started) to 1.0 (animation complete) and also allows the user to scrub the animation back and forth.

There is built-in support for scrubbing an animation by setting the `fractionComplete` property on the animator. There is NOT an automatic mechanism to observe the animation progress, however. Instead, I created a timer that runs while the animation runs, fetches teh value of the animator's `fractionComplete` property, and uses it to update the slider.

You can reverse a `UIViewPropertyAnimator` animation by setting its `isReversed` property, but there are some quirks. If you change the `isReversed` property of a running animator from false to true, the animate reverses, but you can't set the `isReversed` property from true to false while the animation is running and have it switch direction from reverse to forward "live". You have to first pause the animation, switch the `isReversed` flag, and then restart the animation. (To use an automotive analogy, you can switch from forward to reverse while moving, but you have to come to a comlete stop before you can switch from reverse back into drive.)
