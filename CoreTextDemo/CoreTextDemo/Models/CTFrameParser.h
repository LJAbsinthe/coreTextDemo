//
//  CTFrameParser.h
//  CoreTextDemo
//
//  Created by LJ on 2018/5/9.
//  Copyright © 2018年 LJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreTextData.h"

@interface CTFrameParser : NSObject

+ (CoreTextData *)parseTemplateFile:(NSString *)path config:(CTFrameParserConfig *)config;

@end
