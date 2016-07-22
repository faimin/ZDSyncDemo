# Blots、PromiseKit简析
####1、Bolts:
`BFTask`原理：
每个`BFTask`自己都维护着一个任务数组，当task执行`continueWithBlock:`后（会生成一个新的`BFTask`），`continueWithBlock:`带的那个block会被加入到任务数组中，每当有结果返回时，会执行`trySetResult:`方法，这个方法中会拿到task它自己维护的那个任务数组，然后取出其中的所有任务block，然后遍历执行。

####2、Promise:
下面看一下`then`的源码实现：

```
- (PMKPromise *(^)(id))then {
    // 此处`then`本身就是一个block：（PMKPromise *(^then)(id param)），此方法类似于getter方法
    // 返回一个`(PMKPromise *(^)(id))`类型的block，这个block执行后，返回一个PMKPromise
    // 下面整个都是一个then `block`，当执行then的时候会调用 `self.thenOn(dispatch_get_main_queue(), block)`
    return ^(id block){
        return self.thenOn(dispatch_get_main_queue(), block);
    };
}
```


