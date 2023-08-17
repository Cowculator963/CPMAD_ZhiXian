import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

// A custom animation class that provides a fade-in effect with translation
class FadeAnimation extends StatelessWidget {
  final double delay;  // Delay before the animation starts
  final Widget child;  // The widget to apply the animation to

  FadeAnimation(this.delay, this.child);

  @override
  Widget build(BuildContext context) {
    // Define the animation tween for opacity and translation
    // tween is 'in-betweeen' , in this context is between this and this
    final tween = MultiTrackTween([
      Track("opacity")
          .add(Duration(milliseconds: 500), Tween(begin: 0.0, end: 1.0)),  // Opacity transition from 0.0 to 1.0 over 500 milliseconds
      Track("translateY").add(
          Duration(milliseconds: 500), Tween(begin: -30.0, end: 0.0),  // Y-axis translation from -30.0 to 0.0 over 500 milliseconds
          curve: Curves.easeOut)  // Easing curve for the translation
    ]);

    // Wrap the animation using ControlledAnimation
    return ControlledAnimation(
      delay: Duration(milliseconds: (500 * delay).round()),  // Apply the delay to the animation start time
      duration: tween.duration,  // Set the duration of the animation
      tween: tween,  // Pass the defined tween to the animation
      child: child,  // The widget to be animated
      builderWithChild: (context, child, animation) => Opacity(
        opacity: animation["opacity"],  // Apply the opacity value from the animation
        child: Transform.translate(
            offset: Offset(0, animation["translateY"]),  // Apply the Y-axis translation value from the animation
            child: child),  // The animated child widget
      ),
    );
  }
}
