#import "RNNPushAnimation.h"

@implementation RNNPushAnimation

- (instancetype)initWithScreenTransition:(RNNScreenTransition *)screenTransition {
    self = [super init];
    self.screenTransition = screenTransition;
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return self.screenTransition.maxDuration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *toViewController =
        [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];

    [[transitionContext containerView] addSubview:fromView];
    [[transitionContext containerView] addSubview:toView];

    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
      [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];

    [self animateElement:self.screenTransition.topBar
                    view:toViewController.navigationController.navigationBar
             elementName:@"topBar"];
    [self animateElement:(ElementTransitionOptions *)self.screenTransition.content
                    view:toViewController.view
             elementName:@"content"];
    [self animateElement:self.screenTransition.bottomTabs
                    view:toViewController.tabBarController.tabBar
             elementName:@"bottomTabs"];

    [CATransaction commit];
}

- (void)animationWithKeyPath:(NSString *)keyPath
                        from:(id)from
                          to:(id)to
                    duration:(CFTimeInterval)duration
                     forView:(UIView *)view
               animationName:(NSString *)animationName {
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = keyPath;
    animation.fromValue = from;
    animation.toValue = to;
    animation.duration = duration / 1000;
    [view.layer addAnimation:animation forKey:animationName];
}

- (void)animateElement:(ElementTransitionOptions *)element
                  view:(UIView *)view
           elementName:(NSString *)elementName {
    [self animationWithKeyPath:@"position.x"
                          from:@(view.layer.position.x + [element.x.from withDefault:0])
                            to:@(view.layer.position.x + [element.x.to withDefault:0])
                      duration:[element.x.duration withDefault:1]
                       forView:view
                 animationName:@"element.position.x"];
    [self animationWithKeyPath:@"position.y"
                          from:@(view.layer.position.y + [element.y.from withDefault:0])
                            to:@(view.layer.position.y + [element.y.to withDefault:0])
                      duration:[element.y.duration withDefault:1]
                       forView:view
                 animationName:[NSString stringWithFormat:@"%@.position.y", elementName]];
    [self animationWithKeyPath:@"opacity"
                          from:@([element.alpha.from withDefault:1])
                            to:@([element.alpha.to withDefault:1])
                      duration:[element.alpha.duration withDefault:1]
                       forView:view
                 animationName:[NSString stringWithFormat:@"%@.alpha", elementName]];
}

@end
