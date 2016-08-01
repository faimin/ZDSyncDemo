# Blots、PromiseKit简析
####一、Bolts:
`BFTask`原理：
每个`BFTask`自己都维护着一个任务数组，当task执行`continueWithBlock:`后（会生成一个新的`BFTask`），`continueWithBlock:`带的那个block会被加入到任务数组中，每当有结果返回时，会执行`trySetResult:`方法，这个方法中会拿到task它自己维护的那个任务数组，然后取出其中的所有任务block，然后遍历执行。

####二、Promise:
* 1、首先，让我们看看创建Promise的源码

```objc
+ (instancetype)promiseWithResolver:(void (^)(PMKResolver))block {    // (2)
    PMKPromise *this = [self alloc];              // (3)  初始化promise
    this->_promiseQueue = PMKCreatePromiseQueue();
    this->_handlers = [NSMutableArray new];

    @try {
        block(^(id result){                       // (4)  立即开始原始任务（它传过去的参数还是一个`PMKResolver`类型的block，这个block会在PMKRejecter或者PMKFulfiller类型的block执行回调时执行） "void (^PMKResolver)(id)"
            if (PMKGetResult(this))
                return PMKLog(@"PromiseKit: Warning: Promise already resolved");

            PMKResolve(this, result);
        });
    } @catch (id e) {
        // at this point, no pointer to the Promise has been provided
        // to the user, so we can’t have any handlers, so all we need
        // to do is set _result. Technically using PMKSetResult is
        // not needed either, but this seems better safe than sorry.
        PMKSetResult(this, NSErrorFromException(e));
    }

    return this;
}

+ (instancetype)new:(void(^)(PMKFulfiller, PMKRejecter))block {   // (1)
    return [self promiseWithResolver:^(PMKResolver resolve) {
        id rejecter = ^(id error){                    // (5-1) 失败的block
            if (error == nil) {
                error = NSErrorFromNil();
            } else if (IsPromise(error) && [error rejected]) {
                // this is safe, acceptable and (basically) valid
            } else if (!IsError(error)) {
                id userInfo = @{NSLocalizedDescriptionKey: [error description], PMKUnderlyingExceptionKey: error};
                error = [NSError errorWithDomain:PMKErrorDomain code:PMKInvalidUsageError userInfo:userInfo];
            }
            resolve(error);
        };

        id fulfiller = ^(id result){                  // (5-2) 成功的block
            if (IsError(result))
                PMKLog(@"PromiseKit: Warning: PMKFulfiller called with NSError.");
            resolve(result);
        };

        block(fulfiller, rejecter);                   // (5-3) 把成功和失败的block作为参数，执行回调原任务（e.g demo中的网络请求任务）
    }];
}
```
调用`new:`方法时会调用`promiseWithResolver:`方法，在里面进行一些初始化`promise`的工作：创建了一个GCD并发队列和一个数组，并立即回调`new:`后面的那个参数`block`，即：立即执行，生成一个成功（fulfiller）和失败（rejecter）的block，这个block将由用户控制进行回调操作。

----
* 2、下面看一下`then`的源码实现：

```objc
- (PMKPromise *(^)(id))then {      // 1
    // 此处`then`本身就是一个block：（PMKPromise *(^then)(id param)），此方法类似于getter方法
    // 返回一个`(PMKPromise *(^)(id))`类型的block，这个block执行后，返回一个PMKPromise
    // 下面整个都是一个then `block`，当执行then的时候会调用 `self.thenOn(dispatch_get_main_queue(), block)`，返回一个Promise类型的结果
    return ^(id block){
        return self.thenOn(dispatch_get_main_queue(), block);
    };
}

- (PMKResolveOnQueueBlock)thenOn {
    return [self resolved:^(id result) {
        if (IsPromise(result))
            return ((PMKPromise *)result).thenOn;

        if (IsError(result)) return ^(dispatch_queue_t q, id block) {
            return [PMKPromise promiseWithValue:result];
        };

        return ^(dispatch_queue_t q, id block) {

            // HACK we seem to expose some bug in ARC where this block can
            // be an NSStackBlock which then gets deallocated by the time
            // we get around to using it. So we force it to be malloc'd.
            block = [block copy];

            return dispatch_promise_on(q, ^{
                return pmk_safely_call_block(block, result);
            });
        };
    }
    pending:^(id result, PMKPromise *next, dispatch_queue_t q, id block, void (^resolve)(id)) {
        if (IsError(result))
            PMKResolve(next, result);
        else dispatch_async(q, ^{
            resolve(pmk_safely_call_block(block, result));
        });
    }];
}

- (id)resolved:(PMKResolveOnQueueBlock(^)(id result))mkresolvedCallback
       pending:(void(^)(id result, PMKPromise *next, dispatch_queue_t q, id block, void (^resolver)(id)))mkpendingCallback
{
    __block PMKResolveOnQueueBlock callBlock;
    __block id result;
    
    dispatch_sync(_promiseQueue, ^{
        if ((result = _result))
            return;

        callBlock = ^(dispatch_queue_t q, id block) {

            // HACK we seem to expose some bug in ARC where this block can
            // be an NSStackBlock which then gets deallocated by the time
            // we get around to using it. So we force it to be malloc'd.
            block = [block copy];

            __block PMKPromise *next = nil;

            dispatch_barrier_sync(_promiseQueue, ^{
                if ((result = _result))
                    return;

                __block PMKPromiseFulfiller resolver;
                next = [PMKPromise new:^(PMKPromiseFulfiller fulfill, PMKPromiseRejecter reject) {
                    resolver = ^(id o){
                        if (IsError(o)) reject(o); else fulfill(o);
                    };
                }];
                [_handlers addObject:^(id value){
                    mkpendingCallback(value, next, q, block, resolver);
                }];
            });
            
            // next can still be `nil` if the promise was resolved after
            // 1) `-thenOn` read it and decided which block to return; and
            // 2) the call to the block.

            return next ?: mkresolvedCallback(result)(q, block);
        };
    });

    // We could just always return the above block, but then every caller would
    // trigger a barrier_sync on the promise queue. Instead, if we know that the
    // promise is resolved (since that makes it immutable), we can return a simpler
    // block that doesn't use a barrier in those cases.

    return callBlock ?: mkresolvedCallback(result);
}
```




