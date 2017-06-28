//
//  XDSChapterModel.h
//  XDSReader
//
//  Created by dusheng.xu on 2017/6/15.
//  Copyright © 2017年 macos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>
#import "NSString+HTML.h"
#import "XDSReaderGlobleConst.h"
typedef  NS_ENUM(NSInteger,XDSEBookType){
    XDSEBookTypeTxt,
    XDSEBookTypeEpub,
};

/**
 epubs images信息
 */
@interface XDSImageModel : NSObject
@property (nonatomic,strong) NSString *url; //图片链接
@property (nonatomic,assign) CGRect imageRect;  //图片位置
@property (nonatomic,assign) NSInteger position;

@end

@interface XDSChapterModel : NSObject<NSCopying,NSCoding>

@property (nonatomic,copy) NSArray<XDSNoteModel *>*notes;
@property (nonatomic,assign) XDSEBookType bookType;
@property (nonatomic,strong) NSString *content;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,assign) NSInteger pageCount;//章节总页数
@property (nonatomic,readonly) NSArray *pageArray;//存放页面所在的字符串位置，也就是rang.location

//for epub
@property (nonatomic,copy) NSString *chapterpath;
@property (nonatomic,copy) NSString *html;
@property (nonatomic,copy) NSArray *epubContent;
@property (nonatomic,copy) NSArray *epubString;
@property (nonatomic,copy) NSArray *epubframeRef;
@property (nonatomic,copy) NSString *epubImagePath;
@property (nonatomic,copy) NSArray <XDSImageModel *> *imageArray;

- (NSString *)stringOfPage:(NSInteger)index;
- (void)updateFontAndGetNewPageFromOldPage:(NSInteger *)oldPage;
+(id)chapterWithEpub:(NSString *)chapterpath title:(NSString *)title imagePath:(NSString *)path;
-(void)parserEpubToDictionary;
-(void)paginateEpubWithBounds:(CGRect)bounds;

@end
