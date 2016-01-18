# BoltsDemo
###Bolts task的简单使用

```objc
- (BFTask *)taskTest1
{
    BFTaskCompletionSource *taskSource = [BFTaskCompletionSource taskCompletionSource];
    
    [[ZAFNetWorkService shareInstance] requestWithURL:@"http://api.douban.com/v2/movie/top250" params:nil httpMethod:@"get" hasCertificate:NO sucess:^(id responseObject) {
        NSLog(@"1.--->%@", [NSDate date]);
        [taskSource setResult:responseObject];
    } failure:^(NSError *error) {
        [taskSource setError:error];
    }];
    
    return taskSource.task;
}
```
