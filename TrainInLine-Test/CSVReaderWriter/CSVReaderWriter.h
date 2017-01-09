//
//  CSVReaderWriter.h
//  TrainInLine-Test
//
//  Created by Fran Ruano on 6/1/17.
//  Copyright © 2017 Fran Ruano. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, FileMode) {
    FileModeRead = 1,
    FileModeWrite = 2
};

@interface CSVReaderWriter : NSObject
- (BOOL)openWithFileAtPath:(NSString*)path withMode:(FileMode)mode;
- (BOOL)readUpdate:(NSString**)column1 column2:(NSString**)column2;
- (BOOL)readUpdate:(NSMutableArray*)columns;
- (void)write:(NSArray*)columns;
- (void)close;

#pragma mark *** Deprecated/discouraged APIs ***
- (void)open:(NSString*)path mode:(FileMode)mode __attribute__((deprecated("Replaced by openWithFileAtPath:withMode:")));
- (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2 __attribute__((deprecated("Replaced by readAndReturn:column2")));
- (BOOL)read:(NSMutableArray*)columns __attribute__((deprecated("Replaced by readUpdate:")));

@end
