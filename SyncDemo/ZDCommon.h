//
//  ZDCommon.h
//  ZDSyncDemo
//
//  Created by 符现超 on 16/1/28.
//  Copyright © 2016年 ZD. All rights reserved.
//

#ifndef ZDCommon_h
#define ZDCommon_h

#import "ZAFNetWorkService.h"

static inline NSArray *images(){
    return @[@"http://img3.douban.com/img/celebrity/small/17525.jpg",
             @"http://img3.douban.com/img/celebrity/small/34642.jpg",
             @"http://img5.douban.com/img/celebrity/small/5837.jpg",@"http://img3.douban.com/img/celebrity/small/230.jpg",
              @"http://img3.douban.com/view/movie_poster_cover/ipst/public/p480747492.jpg",
              @"http://img3.douban.com/img/celebrity/small/8833.jpg",
              @"http://img3.douban.com/img/celebrity/small/2274.jpg",
              @"http://img3.douban.com/img/celebrity/small/104.jpg",
              @"http://img5.douban.com/img/celebrity/small/47146.jpg"
    ];
}

#define MovieAPI    @"http://api.douban.com/v2/movie/top250"
#define WeatherAPI  @"http://www.weather.com.cn/data/cityinfo/101010100.html"

#endif /* ZDCommon_h */


#define zd_weakify(_objc) __weak __typeof(&*_objc)weak##_objc = _objc;
#define zd_strongify(_objc) __strong __typeof(&*weak##_objc)_objc = weak##_objc;






















