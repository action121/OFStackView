//
//  ViewController.m
//  MultiTablesViewDemo
//
//  Created by 吴晓明 on 15/7/8.
//  Copyright (c) 2015年 吴晓明. All rights reserved.
//

#import "ViewController.h"
#import "CarInfoSelectViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *resultLabel;
- (IBAction)gotoSelectorPage:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)gotoSelectorPage:(id)sender {
    __weak typeof(self) weakSelf = self;
    CarInfoSelectViewController* carInfoVC = [[CarInfoSelectViewController alloc] init];
    __weak typeof(carInfoVC) weakCarInfoVC = carInfoVC;
    carInfoVC.finishHandler = ^{
        
        weakSelf.resultLabel.text = [NSString stringWithFormat:@"车辆品牌:%@,车辆型号:%@,车排量：%@",weakCarInfoVC.currentSelectedBrandItem.itemDescription,weakCarInfoVC.currentSelectedModelItem.itemDescription,weakCarInfoVC.currentSelectedDisplacementItem.itemDescription];
    };
    [self.navigationController pushViewController:carInfoVC animated:YES];
}
@end
