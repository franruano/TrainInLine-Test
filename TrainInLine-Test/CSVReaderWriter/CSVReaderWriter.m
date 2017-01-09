//
//  CSVReaderWriter.m
//  TrainInLine-Test
//
//  Created by Fran Ruano on 6/1/17.
//  Copyright © 2017 Fran Ruano. All rights reserved.
//

#import "CSVReaderWriter.h"

@implementation CSVReaderWriter {
    NSInputStream* inputStream;
    NSOutputStream* outputStream;
}

//Declare column values as constants
const int FIRST_COLUMN = 0;
const int SECOND_COLUMN = 1;


#pragma mark *** Open stream ***
/**
 * Open stream according to the opening mode indicated
 *
 * @param path string path to the file
 * @param mode file opening mode
 * @return True if file is open, false if any error
 */
- (BOOL)openWithFileAtPath:(NSString*)path withMode:(FileMode)mode {
    // Used a better flow structure than concatenated if/else
    switch (mode) {
        case FileModeRead:
            inputStream = [NSInputStream inputStreamWithFileAtPath:path];
            [inputStream open];
            if (inputStream.streamStatus == NSStreamStatusOpen) {
                return YES;
            }
            break;
        case FileModeWrite:
            outputStream = [NSOutputStream outputStreamToFileAtPath:path
                                                             append:NO];
            [outputStream open];
            if (outputStream.streamStatus == NSStreamStatusOpen) {
                return YES;
            }
            break;
        default: {
            NSException* ex = [NSException exceptionWithName:@"UnknownFileModeException"
                                                      reason:@"Unknown file mode specified"
                                                    userInfo:nil];
            @throw ex;
        }
    }
    return NO;
}

- (void)open:(NSString*)path mode:(FileMode)mode {
    [self openWithFileAtPath:path withMode:mode];
}

#pragma mark *** Read stream ***
- (NSString*)readLine {
    uint8_t ch = 0;
    NSMutableString* str = [NSMutableString string];
    while ([inputStream read:&ch maxLength:1] == 1) {
        if (ch == '\n')
            break;
        [str appendFormat:@"%c", ch];
    }
    return str;
}

// Extracting common code to avoid repetition
- (BOOL) setColumnsToNil:(NSString **)column1 column2:(NSString**)column2 {
    *column1 = nil;
    *column2 = nil;
    return false;
}

// Use NSString to improve performance
/**
 * It reads the line and return the first two columns of the file
 *
 * @return True if the read was correct. False otherwise
 */
- (BOOL)readUpdate:(NSString**)column1 column2:(NSString**)column2 {
    NSString* line = [self readLine];
    if ([line length] == 0) {
        return [self setColumnsToNil:column1 column2:column2];
    }
    
    NSArray* splitLine = [line componentsSeparatedByString: @"\t"];
    // Condition need to be changed to < 2
    if ([splitLine count] < 2) {
        return [self setColumnsToNil:column1 column2:column2];
    }
    
    // It doesn't need else branch
    // Not necessary to instanciate NSMutableString
    *column1 = splitLine[FIRST_COLUMN];
    *column2 = splitLine[SECOND_COLUMN];
    return true;
}

- (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2 {
    return [self readUpdate:column1 column2:column2];
}

// Extracting common code to avoid repetition
- (BOOL)setColumnsToNull:(NSMutableArray *)columns {
    columns[FIRST_COLUMN] = [NSNull null];
    columns[SECOND_COLUMN] = [NSNull null];
    return false;
}

- (BOOL)readUpdate:(NSMutableArray*)columns {
    //Defensive code to avoid access out of index
    if ((columns == nil) || ([columns count] < 2)) {
        return false;
    }
    
    NSString* line = [self readLine];
    if ([line length] == 0) {
        // Being consistant with spacing
        return [self setColumnsToNull:columns];
    }
    
    NSArray* splitLine = [line componentsSeparatedByString: @"\t"];
    // Count could be 0 or 1 when fail
    if ([splitLine count] < 2) {
        return [self setColumnsToNull:columns];
    }
    
    // It doesn't need else branch
    columns[FIRST_COLUMN] = splitLine[FIRST_COLUMN];
    columns[SECOND_COLUMN] = splitLine[SECOND_COLUMN];
    return true;
}

- (BOOL)read:(NSMutableArray*)columns {
    return [self readUpdate: columns];
}

#pragma mark *** Write stream ***
- (void)writeLine:(NSString*)line {
    // Avoid write twice appending \n before writing to improve performance
    NSData* data = [[line stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding];
    
    const void* bytes = [data bytes];
    [outputStream write:bytes maxLength:[data length]];
}

- (void)write:(NSArray*)columns {
    //Keeping consistant with the rest of the code
    NSMutableString* outPut = [NSMutableString string];
    //Easier to mantain and read code removing index access
    for (NSString *value in columns) {
        [outPut appendString: value];
        if(value != [columns lastObject]) {
            [outPut appendString: @"\t"];
        }
    }
    [self writeLine:outPut];
}

#pragma mark *** Close stream ***
- (void)close {
    if (inputStream != nil) {
        [inputStream close];
    }
    // Need to close outputStream
    if (outputStream != nil) {
        [outputStream close];
    }
}

@end
