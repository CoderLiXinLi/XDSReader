//
//  XDSChapterModel.m
//  XDSReader
//
//  Created by dusheng.xu on 06/07/2017.
//  Copyright © 2017 macos. All rights reserved.
//

#import "XDSChapterModel.h"
#import "NSAttributedString+Encoding.h"
@interface XDSChapterModel ()

@property (nonatomic, copy) NSAttributedString *chapterAttributeContent;//全章的富文本
@property (nonatomic, copy) NSString *chapterContent;//全章的纯文本
@property (nonatomic, copy) NSArray *pageAttributeStrings;//每一页的富文本
@property (nonatomic, copy) NSArray *pageStrings;//每一页的普通文本
@property (nonatomic, copy) NSArray *pageLocations;//每一页在章节中的位置
@property (nonatomic, assign) NSInteger pageCount;//章节总页数

@property (nonatomic,copy) NSArray<XDSNoteModel *>*notes;
@property (nonatomic,copy) NSArray<XDSMarkModel *>*marks;


@property (assign, nonatomic) CGRect showBounds;
@end
@implementation XDSChapterModel

NSString *const kXDSChapterModelChapterNameEncodeKey = @"chapterName";
NSString *const kXDSChapterModelChapterSrcEncodeKey = @"chapterSrc";
NSString *const kXDSChapterModelOriginContentEncodeKey = @"originContent";
NSString *const kXDSChapterModelNotesPathEncodeKey = @"notes";
NSString *const kXDSChapterModelMarksEncodeKey = @"marks";


-(void)paginateEpubWithBounds:(CGRect)bounds{
    @autoreleasepool {
//        bounds.size.height = bounds.size.height - 20;
        self.showBounds = bounds;
        // Load HTML data
        NSAttributedString *chapterAttributeContent = [self attributedStringForSnippet];
        chapterAttributeContent = [self addLineForNotes:chapterAttributeContent];
        
        NSMutableArray *pageAttributeStrings = [NSMutableArray arrayWithCapacity:0];//每一页的富文本
        NSMutableArray *pageStrings = [NSMutableArray arrayWithCapacity:0];//每一页的普通文本
        NSMutableArray *pageLocations = [NSMutableArray arrayWithCapacity:0];//每一页在章节中的位置
        
        DTCoreTextLayouter *layouter = [[DTCoreTextLayouter alloc] initWithAttributedString:chapterAttributeContent];
        NSRange visibleStringRang;
        DTCoreTextLayoutFrame *visibleframe;
        NSInteger rangeOffset = 0;
        do {
            @autoreleasepool {
                visibleframe = [layouter layoutFrameWithRect:bounds range:NSMakeRange(rangeOffset, 0)];
                visibleStringRang = [visibleframe visibleStringRange];
                NSAttributedString *subAttStr = [chapterAttributeContent attributedSubstringFromRange:NSMakeRange(visibleStringRang.location, visibleStringRang.length)];
                
                NSMutableAttributedString *mutableAttStr = [[NSMutableAttributedString alloc] initWithAttributedString:subAttStr];
                [pageAttributeStrings addObject:mutableAttStr];

                [pageStrings addObject:subAttStr.string];
                [pageLocations addObject:@(visibleStringRang.location)];
                rangeOffset += visibleStringRang.length;

            }
            
        } while (visibleStringRang.location + visibleStringRang.length < chapterAttributeContent.string.length);
        
        visibleframe = nil;
        layouter = nil;
        
        self.chapterAttributeContent = chapterAttributeContent;
        self.chapterContent = chapterAttributeContent.string;
        self.pageAttributeStrings = pageAttributeStrings;
        self.pageStrings = pageStrings;
        self.pageLocations = pageLocations;
        self.pageCount = self.pageLocations.count;
        
    }
}

//TODO:add underline for notes 为笔记添加下划虚线
- (NSAttributedString *)addLineForNotes:(NSAttributedString *)chapterAttributeContent{
    NSMutableAttributedString * mAttribute = [[NSMutableAttributedString alloc] initWithAttributedString:chapterAttributeContent];

    for (XDSNoteModel *noteModel in _notes) {
        NSRange range = NSMakeRange(noteModel.locationInChapterContent, noteModel.content.length);
        NSMutableDictionary *attibutes = [NSMutableDictionary dictionary];
        //虚线
        //[attibutes setObject:@(NSUnderlinePatternDot|NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
        [attibutes setObject:@(NSUnderlinePatternSolid|NSUnderlineStyleSingle) forKey:NSUnderlineStyleAttributeName];
        [attibutes setObject:[UIColor redColor] forKey:NSUnderlineColorAttributeName];
        
        [attibutes setObject:[noteModel getNoteURL] forKey:NSLinkAttributeName];
        
        [mAttribute addAttributes:attibutes range:range];
    }
    
    return mAttribute;
}

- (NSAttributedString *)attributedStringForSnippet{
    NSLog(@"====%@", self.chapterName);

    NSString *html = @"";
    NSString *readmePath = @"";
    if (self.chapterSrc.length) {
        //load epub
        NSString *OEBPSUrl = CURRENT_BOOK_MODEL.bookBasicInfo.OEBPSUrl;
        OEBPSUrl = [APP_SANDBOX_DOCUMENT_PATH stringByAppendingString:OEBPSUrl];
        NSString *fileName = [NSString stringWithFormat:@"%@/%@", OEBPSUrl, self.chapterSrc];
        //    // Load HTML data
        readmePath = fileName;
        html = [NSString stringWithContentsOfFile:readmePath encoding:NSUTF8StringEncoding error:NULL];
        html = [html stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
        html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@"</p><p>"];
        NSString *imagePath = [@"img src=\"" stringByAppendingString:OEBPSUrl];
        html = [html stringByReplacingOccurrencesOfString:@"img src=\".." withString:imagePath];
        html = [html stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
    }else if (self.originContent.length) {
        //load txt content
        html = self.originContent;
        html = [@"<p>" stringByAppendingString:html];
        html = [html stringByReplacingOccurrencesOfString:@"\r" withString:@"\n"];
        html = [html stringByReplacingOccurrencesOfString:@"\n" withString:@"</p><p>"];
        html = [html stringByAppendingString:@"</p>"];
        html = [html stringByReplacingOccurrencesOfString:@"<p></p>" withString:@""];
    }
    NSData *data = [html dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create attributed string from HTML
    
    // example for setting a willFlushCallback, that gets called before elements are written to the generated attributed string
    void (^callBackBlock)(DTHTMLElement *element) = ^(DTHTMLElement *element) {
        
        // the block is being called for an entire paragraph, so we check the individual elements
        
        for (DTHTMLElement *oneChildElement in element.childNodes) {
            // if an element is larger than twice the font size put it in it's own block
            if (oneChildElement.displayStyle == DTHTMLElementDisplayStyleInline && oneChildElement.textAttachment.displaySize.height > 2.0 * oneChildElement.fontDescriptor.pointSize)
            {
                oneChildElement.displayStyle = DTHTMLElementDisplayStyleBlock;
                oneChildElement.paragraphStyle.minimumLineHeight = element.textAttachment.displaySize.height;
                oneChildElement.paragraphStyle.maximumLineHeight = element.textAttachment.displaySize.height;
            }
        }
    };
    
    
    XDSReadConfig *config = self.currentConfig;
    CGFloat fontSize = (config.currentFontSize > 1)?config.currentFontSize:config.cachefontSize;
    UIColor *textColor = config.currentTextColor?config.currentTextColor:config.cacheTextColor;
    NSString *fontName = config.currentFontName?config.currentFontName:config.cacheFontName;

    NSString *header = @"你好";
    CGRect headerFrame = [header boundingRectWithSize:CGSizeMake(100, 100)
                                              options:NSStringDrawingUsesLineFragmentOrigin
                                           attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}
                                              context:nil];
    CGFloat headIndent = CGRectGetWidth(headerFrame);
    
    CGSize maxImageSize = CGSizeMake(_showBounds.size.width - headIndent*2, _showBounds.size.height - headIndent);
    
    NSDictionary *dic = @{NSTextSizeMultiplierDocumentOption:@(fontSize/11.0),
                          DTDefaultLineHeightMultiplier:@1.5,
                          DTMaxImageSize:[NSValue valueWithCGSize:maxImageSize],
                          DTDefaultLinkColor:@"purple",
                          DTDefaultLinkHighlightColor:@"red",
                          DTDefaultTextColor:textColor,
                          DTDefaultFontName:fontName,
                          DTWillFlushBlockCallBack:callBackBlock,
//                          DTDefaultFirstLineHeadIndent:@(headIndent),
                          };
    
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithDictionary:dic];
    if (readmePath.length) {
        [options setObject:[NSURL fileURLWithPath:readmePath] forKey:NSBaseURLDocumentOption];
    }
    NSAttributedString *string = [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:NULL];
    
    return string;
}


//TODO:insert a book note into chapter 向该章节中插入一条笔记
- (void)addNote:(XDSNoteModel *)noteModel{
    NSMutableArray *notes = [NSMutableArray arrayWithCapacity:0];
    if (self.notes) {
        [notes addObjectsFromArray:self.notes];
    }
    [notes addObject:noteModel];
    self.notes = notes;
}

//TODO: insert a bookmark into chapter 向该章节中插入一条书签
- (void)addOrDeleteABookmark:(XDSMarkModel *)markModel {
    NSMutableArray *marks = [NSMutableArray arrayWithCapacity:0];
    if (self.marks) {
        [marks addObjectsFromArray:self.marks];
    }
    
    if ([self isMarkAtPage:markModel.page]) { //contains mark 如果存在，移除书签信息
        for (XDSMarkModel *mark in marks) {
            if (mark.page == markModel.page) {
                [marks removeObject:mark];
                break;
            }
        }
    }else{// doesn't contain mark 记录书签信息
        [marks addObject:markModel];
    }
    self.marks = marks;
}


//TODO: does this page contains a bookMark?
- (BOOL)isMarkAtPage:(NSInteger)page{
    if (page >= self.pageCount) {
        return NO;
    }
    for (XDSMarkModel *mark in self.marks) {
        if (mark.page == page) {
            return YES;
        }
    }
    return NO;
}

- (NSArray *)notesAtPage:(NSInteger)page {
    NSInteger location = [_pageLocations[page] integerValue];
    NSInteger length = [_pageStrings[page] length];
    
    NSMutableArray *notes = [NSMutableArray arrayWithCapacity:0];
    for (int i = 0; i < _notes.count; i ++) {
        XDSNoteModel *noteModel = _notes[i];
        NSInteger noteLocation = noteModel.locationInChapterContent;
        NSInteger noteLenght = noteModel.content.length;
        if (noteLocation >= location && noteLocation < location + length) {
            //note location 在page内部
            [notes addObject:noteModel];
            
        }else if (noteLocation < location && noteLocation + noteLenght > location){
            //note location 在page之前
            [notes addObject:noteModel];
        }
    }
    
    return notes;
}
- (BOOL)isReadConfigChanged {
    XDSReadConfig *shareConfig = [XDSReadConfig shareInstance];
    BOOL isReadConfigChanged = ![_currentConfig isEqual:shareConfig];
    if (isReadConfigChanged) {
        self.currentConfig = shareConfig;
    }
    return isReadConfigChanged;
}

-(id)copyWithZone:(NSZone *)zone{
    XDSChapterModel *model = [[XDSChapterModel allocWithZone:zone] init];
    model.chapterName = self.chapterName;
    model.chapterSrc = self.chapterSrc;
    model.originContent = self.originContent;
    model.chapterAttributeContent = self.chapterAttributeContent;
    model.chapterContent = self.chapterContent;
    model.pageAttributeStrings = self.pageAttributeStrings;
    model.pageStrings = self.pageStrings;
    model.pageLocations = self.pageLocations;
    model.pageCount = self.pageCount;
    model.notes = self.notes;
    model.marks = self.marks;
    return model;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.chapterName forKey:kXDSChapterModelChapterNameEncodeKey];
    [aCoder encodeObject:self.chapterSrc forKey:kXDSChapterModelChapterSrcEncodeKey];
    [aCoder encodeObject:self.originContent forKey:kXDSChapterModelOriginContentEncodeKey];
    [aCoder encodeObject:self.notes forKey:kXDSChapterModelNotesPathEncodeKey];
    [aCoder encodeObject:self.marks forKey:kXDSChapterModelMarksEncodeKey];
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if (self) {
        self.chapterName = [aDecoder decodeObjectForKey:kXDSChapterModelChapterNameEncodeKey];
        self.chapterSrc = [aDecoder decodeObjectForKey:kXDSChapterModelChapterSrcEncodeKey];
        self.originContent = [aDecoder decodeObjectForKey:kXDSChapterModelOriginContentEncodeKey];
        self.notes = [aDecoder decodeObjectForKey:kXDSChapterModelNotesPathEncodeKey];
        self.marks = [aDecoder decodeObjectForKey:kXDSChapterModelMarksEncodeKey];

    }
    return self;
}

@end
