//
//  XDSReadPageViewController.h
//  XDSReader
//
//  Created by dusheng.xu on 2017/6/16.
//  Copyright © 2017年 macos. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XDSReadPageViewController : UIViewController

@property (nonatomic,strong) NSURL *resourceURL;
@property (nonatomic,strong) XDSBookModel *bookModel;

@end
