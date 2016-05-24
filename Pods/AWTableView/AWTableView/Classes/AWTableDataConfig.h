//
//  AWTableDataConfig.h
//  BayLe
//
//  Created by tangwei1 on 15/11/25.
//  Copyright © 2015年 tangwei1. All rights reserved.
//

#ifndef AWTableDataConfig_h
#define AWTableDataConfig_h

/** 配置表视图中每个cell或collectionCell的数据 */
@protocol AWTableDataConfig <NSObject>

- (void)configData:(id)data;

@end

#endif /* AWTableDataConfig_h */



