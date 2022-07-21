//
//  ZDTableViewController.m
//  BoltsDemo
//
//  Created by Zero.D.Saber on 16/1/22.
//  Copyright © 2016年 ZD. All rights reserved.
//

#import "ZDTableViewController.h"
#import "ZDCommon.h"

static CGFloat const SectionHeight = 28.0;
static NSString *const CellReuseIdentifier = @"UITableViewCell";

@interface ZDTableViewController ()
@property (nonatomic, assign) CGFloat recordContentOffsetY;
@property (nonatomic, strong) NSArray<NSDictionary<NSString *, NSString *> *> *dataSource;
@end

@implementation ZDTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置此属性防止一进界面tableview视图就滑动的问题（那时contentOffsetY = -64）
    self.edgesForExtendedLayout = UIRectEdgeNone;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setup];
}

- (void)setup {
    [self setupUI];
    [self setupData];
}

- (void)setupUI {
    
}

- (void)setupData {
    // @{ className : description }
    self.dataSource = @[
        @{ @"BoltsDemo" : @"BoltsDemo" },
        @{ @"PromiseKitDemo" : @"PromiseKitDemo" },
        @{ @"PromisesObjCDemo" : @"PromisesObjCDemo" },
        @{ @"RACDemo" : @"RACDemo" },
        @{ @"GCDGroupDemo" : @"GCDGroupDemo" },
        @{ @"OperationDemo" : @"OperationDemo" },
        @{ @"OperationQueue" : @"OperationQueue" },
        @{ @"SemaphoreDemo" : @"SemaphoreDemo" },
        @{ @"PthreadJoinDemo" : @"PthreadJoinDemo" },
        @{ @"DispatchBlockDemo" : @"DispatchBlockDemo"},
        //@{ @"GCDSourceDataAddDemo" : @"GCDSourceDataAddDemo" },
        @{ @"ConditionLockDemo" : @"ConditionLockDemo"},
    ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Delegate

// 让section跟随滑动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
#if 1
    // 上拉为正数，下拉为负数
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    if (contentOffsetY > 0) {
        CGFloat padding = MIN(contentOffsetY, SectionHeight);
        self.tableView.contentInset = UIEdgeInsetsMake(-padding, 0, 0, 0);
        if (contentOffsetY > self.recordContentOffsetY) {   // 上拉
            
        }
        else {                                              // 下拉
            
        }
    }
    self.recordContentOffsetY = contentOffsetY;
    
#else
    
    if (contentOffsetY <= SectionHeight && contentOffsetY >= 0) {
        scrollView.contentInset = UIEdgeInsetsMake(-contentOffsetY, 0, 0, 0);
    }
    else if (contentOffsetY >= SectionHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-SectionHeight, 0, 0, 0);
    }
#endif
}

//- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
//    self.navigationController.navigationBar.hidden = velocity.y > 0;
//}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellReuseIdentifier];
    }
    cell.textLabel.textColor = ZD_RandomColor();
    cell.textLabel.text = self.dataSource[indexPath.row].allValues.firstObject;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *className = self.dataSource[indexPath.row].allKeys.firstObject;
    Class aClass = NSClassFromString(className);
    if (!aClass) return;
    [self.navigationController pushViewController:[aClass new] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
