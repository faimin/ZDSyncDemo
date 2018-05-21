//
//  GCDSourceDataAddDemo.m
//  ZDSyncDemo
//
//  Created by Zero.D.Saber on 2018/5/19.
//  Copyright © 2018年 ZD. All rights reserved.
//

#import "GCDSourceDataAddDemo.h"
#import "ZDCommon.h"

@interface GCDSourceDataAddDemo ()
@property (nonatomic, strong) dispatch_source_t source;
@property (nonatomic, strong) NSMutableArray *allDatas;
@end

@implementation GCDSourceDataAddDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = ZD_RandomColor();
    
    [self setup];
}

- (void)setup {
    [self setupSource];
    [self setupData];
}

- (void)setupSource {
    dispatch_queue_t onQueue = dispatch_queue_create("soureQueue", dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT, QOS_CLASS_UTILITY, 0));
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_DATA_ADD, 0, 0, onQueue);
    dispatch_source_set_event_handler(_source, ^{
        NSLog(@"完毕");
        NSLog(@"结果： %@", self.allDatas);
    });
}

- (void)setupData {
    [self request];
}

- (void)request {
    [[ZAFNetWorkService shareInstance] requestWithURL:MovieAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
        [self.allDatas addObject:responseObject];
        dispatch_source_merge_data(self.source, 1);
    } failure: ^(NSError *error) {
        dispatch_source_merge_data(self.source, 1);
    }];
    
    [[ZAFNetWorkService shareInstance] requestWithURL:WeatherAPI params:nil httpMethod:@"get" hasCertificate:NO sucess: ^(id responseObject) {
        [self.allDatas addObject:responseObject];
        dispatch_source_merge_data(self.source, 1);
    } failure: ^(NSError *error) {
        dispatch_source_merge_data(self.source, 1);
    }];
}

#pragma mark -

- (NSMutableArray *)allDatas {
    if (!_allDatas) {
        _allDatas = @[].mutableCopy;
    }
    return _allDatas;
}

#pragma mark -

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
