//
//  ZLViewController.m
//  ZLAutoLayout
//
//  Created by richiezhl on 09/26/2021.
//  Copyright (c) 2021 richiezhl. All rights reserved.
//

#import "ZLViewController.h"
#import <ZLAutoLayout/ZLAutoLayout.h>

@interface ZLViewController ()

@end

@implementation ZLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UIView *view1 = [[UIView alloc] init];
    view1.backgroundColor = [UIColor redColor];
    [self.view addSubview:view1];
    
    ZLConstraint *a = view1.zla.left.equalTo(self.view.zla.left).constant(20).install();
    ZLConstraint *b = view1.zla.top.equalTo(self.view).withSafeArea(YES).install();
    
    ZLConstraint *c = view1.zla.width.equalTo(self.view.zla.width).multiplier(0.5).constant(-100).install();
    ZLConstraint *d = view1.zla.height.equalTo(@40).install();
    d.uninstall();
    d = view1.zla.bottom.equalTo(self.view.zla.bottom).constant(-50).withSafeArea(YES).install();
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        a.constant(100);
        [UIView animateWithDuration:0.3 animations:^{
            [self.view layoutIfNeeded];
        }];
    });
    NSLog(@"%@\n%@\n%@\n%@\n", a, b, c, d);
    
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor = [UIColor greenColor];
    [self.view addSubview:view2];
    
    view2.zla.left.equalTo(view1.zla.right).constant(20).install();
    view2.zla.top.equalTo(view1).install();
    view2.zla.width.equalTo(@100).install();
    view2.zla.height.equalTo(view2.zla.width).multiplier(0.5).constant(100).install();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
