//
//  TrainInLine_TestTests.m
//  TrainInLine-TestTests
//
//  Created by Fran Ruano on 6/1/17.
//  Copyright © 2017 Fran Ruano. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CSVReaderWriter.h"

@interface CSVReaderWriter (Testing)
    - (NSString*)readLine;
    - (void)writeLine:(NSString*)line;
@end


@interface CSVReaderWriterTests : XCTestCase
    @property (strong, nonatomic) CSVReaderWriter *csvReaderWriter;
    @property (strong, nonatomic) NSString *pathRead;
    @property (strong, nonatomic) NSString *pathWrite;
    @property (strong, nonatomic) NSString *pathEmptyFile;
    @property (strong, nonatomic) NSString *pathWrongFormat;
@end

@implementation CSVReaderWriterTests
    NSString * const readFileContent = @"Yellow\tBlue\tWhite\rOrange\tGreen\tPurple\r";


- (void)setUp {
    [super setUp];
    
    self.csvReaderWriter = [CSVReaderWriter new];
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    self.pathRead = [bundle pathForResource:@"csvReadTest"
                                 ofType:@"csv"];
    self.pathEmptyFile = [bundle pathForResource:@"csvEmpty"
                                     ofType:@"csv"];
    self.pathWrongFormat = [bundle pathForResource:@"csvWrongFormat"
                                     ofType:@"csv"];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    self.pathWrite = [documentsDirectory stringByAppendingPathComponent:@"csvWriteTest.csv"];
}

- (void)tearDown {
    [self.csvReaderWriter close];
    self.csvReaderWriter = nil;
    self.pathRead = nil;
    self.pathWrite = nil;
    self.pathEmptyFile = nil;
    self.pathWrongFormat = nil;
    
    [super tearDown];
}
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma mark - (void)open:(NSString*)path mode:(FileMode)mode;

//Deprecated
- (void)testOpenNonExistingFileWithReadMode {
    [self.csvReaderWriter open:@"TestFileRead.txt" mode:FileModeRead];
    NSInputStream* inputStream = [self.csvReaderWriter valueForKey:@"inputStream"];
    XCTAssertEqual(inputStream.streamStatus, NSStreamStatusError, @"inputStream should fail. File shouldn't exists");
}

- (void)testOpenFileWithReadMode {
    [self.csvReaderWriter open:self.pathRead mode:FileModeRead];
    NSInputStream* inputStream = [self.csvReaderWriter valueForKey:@"inputStream"];
    XCTAssertEqual(inputStream.streamStatus, NSStreamStatusOpen, @"inputStream should be open");
}

- (void)testOpenFileWithWriteMode {
    [self.csvReaderWriter open:self.pathWrite mode:FileModeWrite];
    NSOutputStream* outputStream = [self.csvReaderWriter valueForKey:@"outputStream"];
    XCTAssertEqual(outputStream.streamStatus, NSStreamStatusOpen, @"outputStream should be open");
}

- (void)testOpenFileWithNonValidMode {
    XCTAssertThrows([self.csvReaderWriter open:self.pathWrite mode:3], @"NSException fire for non valid Mode");
}

//No deprecated
- (void)testNewOpenNonExistingFileWithReadMode {
    BOOL isFileOpen = [self.csvReaderWriter openWithFileAtPath:@"TestFileRead.txt" withMode:FileModeRead];
    NSInputStream* inputStream = [self.csvReaderWriter valueForKey:@"inputStream"];
    XCTAssertEqual(inputStream.streamStatus, NSStreamStatusError, @"inputStream should fail. File shouldn't exists");
    XCTAssertFalse(isFileOpen, @"File should have an Error");
}

- (void)testNewOpenNonExistingFileWithWriteMode {
    BOOL isFileOpen = [self.csvReaderWriter openWithFileAtPath:@"TestFileRead.txt" withMode:FileModeWrite];
    NSOutputStream* outputStream = [self.csvReaderWriter valueForKey:@"outputStream"];
    XCTAssertEqual(outputStream.streamStatus, NSStreamStatusError, @"outputStream should fail. File shouldn't exists");
    XCTAssertFalse(isFileOpen, @"File should have an Error");
}

- (void)testNewOpenFileWithReadMode {
    BOOL isFileOpen = [self.csvReaderWriter openWithFileAtPath:self.pathRead withMode:FileModeRead];
    NSInputStream* inputStream = [self.csvReaderWriter valueForKey:@"inputStream"];
    XCTAssertEqual(inputStream.streamStatus, NSStreamStatusOpen, @"inputStream should be open");
    XCTAssertTrue(isFileOpen, @"File should have be opened");
}

- (void)testNewOpenFileWithWriteMode {
    BOOL isFileOpen = [self.csvReaderWriter openWithFileAtPath:self.pathWrite withMode:FileModeWrite];
    NSOutputStream* outputStream = [self.csvReaderWriter valueForKey:@"outputStream"];
    XCTAssertEqual(outputStream.streamStatus, NSStreamStatusOpen, @"outputStream should be open");
    XCTAssertTrue(isFileOpen, @"File should have be opened");
}

#pragma mark - (void)close;
- (void)testCloseFileWithReadMode {
    [self.csvReaderWriter open:self.pathRead mode:FileModeRead];
    NSInputStream* inputStream = [self.csvReaderWriter valueForKey:@"inputStream"];
    XCTAssertEqual(inputStream.streamStatus, NSStreamStatusOpen, @"inputStream should be open");
    [self.csvReaderWriter close];
    inputStream = [self.csvReaderWriter valueForKey:@"inputStream"];
    XCTAssertEqual(inputStream.streamStatus, NSStreamStatusClosed, @"inputStream should be closed");
}

- (void)testCloseFileWithWriteMode {
    [self.csvReaderWriter open:self.pathWrite mode:FileModeWrite];
    NSOutputStream* outputStream = [self.csvReaderWriter valueForKey:@"outputStream"];
    XCTAssertEqual(outputStream.streamStatus, NSStreamStatusOpen, @"outputStream should be open");
    [self.csvReaderWriter close];
    outputStream = [self.csvReaderWriter valueForKey:@"outputStream"];
    XCTAssertEqual(outputStream.streamStatus, NSStreamStatusClosed, @"outputStream should be closed");
}

#pragma mark - (NSString*)readLine
- (void)testReadLine {
    [self.csvReaderWriter open:self.pathRead mode:FileModeRead];
    NSString *strReadLine = [self.csvReaderWriter readLine];
    
    BOOL isReadLineEqual = [strReadLine isEqualToString:readFileContent];
    XCTAssertTrue(isReadLineEqual, @"Readline are not matching");
}

#pragma mark - (void)write:(NSArray*)columns
- (void)testWriteWithArray {
    NSArray *arr = [[NSArray alloc] initWithObjects:@"Yellow", @"Blue", @"White", nil];
    NSString *strReturn = @"Yellow\tBlue\tWhite";
    
    [self.csvReaderWriter open:self.pathWrite mode:FileModeWrite];
    [self.csvReaderWriter write:arr];
    [self.csvReaderWriter close];
    
    [self.csvReaderWriter open:self.pathWrite mode:FileModeRead];
    NSString *strReadLine = [self.csvReaderWriter readLine];
    
    BOOL isReadLineEqual = [strReadLine isEqualToString:strReturn];
    XCTAssertTrue(isReadLineEqual, @"Readline are not matching");
}

- (void)testWriteWithEmptyArray {
    NSArray *arr = [NSArray new];
    NSString *strReturn = @"";
    
    [self.csvReaderWriter open:self.pathWrite mode:FileModeWrite];
    [self.csvReaderWriter write:arr];
    [self.csvReaderWriter close];
    
    [self.csvReaderWriter open:self.pathWrite mode:FileModeRead];
    NSString *strReadLine = [self.csvReaderWriter readLine];
    
    BOOL isReadLineEqual = [strReadLine isEqualToString:strReturn];
    XCTAssertTrue(isReadLineEqual, @"Readline are not matching");
}

- (void)testWriteWithNilArray {
    NSString *strReturn = @"";
    
    [self.csvReaderWriter open:self.pathWrite mode:FileModeWrite];
    [self.csvReaderWriter write:nil];
    [self.csvReaderWriter close];
    
    [self.csvReaderWriter open:self.pathWrite mode:FileModeRead];
    NSString *strReadLine = [self.csvReaderWriter readLine];
    
    BOOL isReadLineEqual = [strReadLine isEqualToString:strReturn];
    XCTAssertTrue(isReadLineEqual, @"Readline are not matching");
}

#pragma mark - (void)writeLine:(NSString*)line
- (void)testWriteLineWithValue {
    NSString *strLineContent = @"Test\tContent\tFor";
    [self.csvReaderWriter open:self.pathWrite mode:FileModeWrite];
    [self.csvReaderWriter writeLine:strLineContent];
    [self.csvReaderWriter close];

    [self.csvReaderWriter open:self.pathWrite mode:FileModeRead];
    NSString *strReadLine = [self.csvReaderWriter readLine];
    
    BOOL isReadLineEqual = [strReadLine isEqualToString:strLineContent];
    XCTAssertTrue(isReadLineEqual, @"Readline are not matching");
    
}

- (void)testWriteLineWithNoValue {
    [self.csvReaderWriter open:self.pathWrite mode:FileModeWrite];
    [self.csvReaderWriter writeLine:nil];
    [self.csvReaderWriter close];
    
    [self.csvReaderWriter open:self.pathWrite mode:FileModeRead];
    NSString *strReadLine = [self.csvReaderWriter readLine];
    
    BOOL isReadLineEqual = [strReadLine isEqualToString:@""];
    XCTAssertTrue(isReadLineEqual, @"Readline are not matching");
    
}

#pragma mark - (BOOL)read:(NSMutableArray*)columns
- (void)testReadWithEmptyArray {
    NSMutableArray *arr = [NSMutableArray new];
    [self.csvReaderWriter open:self.pathEmptyFile mode:FileModeRead];
    BOOL readResponse = [self.csvReaderWriter read:arr];
    
    XCTAssertFalse(readResponse, @"Read line didn't get the correct values");
}

- (void)testReadWithArraywithEmptyElements {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:@"column1", @"column2", nil];
    [self.csvReaderWriter open:self.pathRead mode:FileModeRead];
    BOOL readResponse = [self.csvReaderWriter read:arr];
    XCTAssertTrue(readResponse, @"Read line didn't get the correct values");
    BOOL isFirstArrayElementEqual = [arr[0] isEqualToString:@"Yellow"];
    XCTAssertTrue(isFirstArrayElementEqual, @"Readline are not matching");
    BOOL isSecondArrayElementEqual = [arr[1] isEqualToString:@"Blue"];
    XCTAssertTrue(isSecondArrayElementEqual, @"Readline are not matching");
}

- (void)testReadFromEmptyFile {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:@"column1", @"column2", nil];
    [self.csvReaderWriter open:self.pathEmptyFile mode:FileModeRead];
    BOOL readResponse = [self.csvReaderWriter read:arr];
    XCTAssertFalse(readResponse, @"Read line didn't get the correct values");
    XCTAssertEqual(arr[0], [NSNull null], @"Readline are not matching");
    XCTAssertEqual(arr[1], [NSNull null], @"Readline are not matching");
}

- (void)testReadFromFileWithWrongFormat {
    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:@"column1", @"column2", nil];
    [self.csvReaderWriter open:self.pathWrongFormat mode:FileModeRead];
    BOOL readResponse = [self.csvReaderWriter read:arr];
    XCTAssertFalse(readResponse, @"Read line didn't get the correct values");
    XCTAssertEqual(arr[0], [NSNull null], @"Readline are not matching");
    XCTAssertEqual(arr[1], [NSNull null], @"Readline are not matching");
}

#pragma mark - (BOOL)read:(NSMutableString**)column1 column2:(NSMutableString**)column2
- (void)testReadEmptyFileWithTwoString {
    NSMutableString *firstColumn = [[NSMutableString alloc] initWithString:@"column1"];
    NSMutableString *secondColumn = [[NSMutableString alloc] initWithString:@"column2"];
    [self.csvReaderWriter open:self.pathEmptyFile mode:FileModeRead];
    BOOL readResponse = [self.csvReaderWriter read:&firstColumn column2:&secondColumn];
    XCTAssertFalse(readResponse, @"Read line didn't get the correct values");
    XCTAssertNil(firstColumn, @"Readline are not matching");
    XCTAssertNil(secondColumn, @"Readline are not matching");
}

- (void)testReadWrongFormatFileWithTwoString {
    NSMutableString *firstColumn = [[NSMutableString alloc] initWithString:@"column1"];
    NSMutableString *secondColumn = [[NSMutableString alloc] initWithString:@"column2"];
    [self.csvReaderWriter open:self.pathWrongFormat mode:FileModeRead];
    BOOL readResponse = [self.csvReaderWriter read:&firstColumn column2:&secondColumn];
    XCTAssertFalse(readResponse, @"Read line didn't get the correct values");
    XCTAssertNil(firstColumn, @"Readline are not matching");
    XCTAssertNil(secondColumn, @"Readline are not matching");
}

- (void)testReadWithTwoString {
    NSMutableString *firstColumn = [[NSMutableString alloc] initWithString:@"column1"];
    NSMutableString *secondColumn = [[NSMutableString alloc] initWithString:@"column2"];
    [self.csvReaderWriter open:self.pathRead mode:FileModeRead];
    BOOL readResponse = [self.csvReaderWriter read:&firstColumn column2:&secondColumn];
    XCTAssertTrue(readResponse, @"Read line didn't get the correct values");
    BOOL isFirstColumnEqual = [firstColumn isEqualToString:@"Yellow"];
    XCTAssertTrue(isFirstColumnEqual, @"Readline are not matching");
    BOOL isSecondColumnEqual = [secondColumn isEqualToString:@"Blue"];
    XCTAssertTrue(isSecondColumnEqual, @"Readline are not matching");
}

- (void)testReadEmptyFileWithNil {
    NSMutableString *firstColumn = nil;
    NSMutableString *secondColumn = nil;
    [self.csvReaderWriter open:self.pathEmptyFile mode:FileModeRead];
    BOOL readResponse = [self.csvReaderWriter read:&firstColumn column2:&secondColumn];
    XCTAssertFalse(readResponse, @"Read line didn't get the correct values");
    XCTAssertNil(firstColumn, @"Readline are not matching");
    XCTAssertNil(secondColumn, @"Readline are not matching");
}

- (void)testReadWrongFormatFileWithNil {
    NSMutableString *firstColumn = nil;
    NSMutableString *secondColumn = nil;
    [self.csvReaderWriter open:self.pathWrongFormat mode:FileModeRead];
    BOOL readResponse = [self.csvReaderWriter read:&firstColumn column2:&secondColumn];
    XCTAssertFalse(readResponse, @"Read line didn't get the correct values");
    XCTAssertNil(firstColumn, @"Readline are not matching");
    XCTAssertNil(secondColumn, @"Readline are not matching");
}

- (void)testReadWithNil {
    NSMutableString *firstColumn = nil;
    NSMutableString *secondColumn = nil;
    [self.csvReaderWriter open:self.pathRead mode:FileModeRead];
    BOOL readResponse = [self.csvReaderWriter read:&firstColumn column2:&secondColumn];
    XCTAssertTrue(readResponse, @"Read line didn't get the correct values");
    BOOL isFirstColumnEqual = [firstColumn isEqualToString:@"Yellow"];
    XCTAssertTrue(isFirstColumnEqual, @"Readline are not matching");
    BOOL isSecondColumnEqual = [secondColumn isEqualToString:@"Blue"];
    XCTAssertTrue(isSecondColumnEqual, @"Readline are not matching");
}
#pragma clang diagnostic pop
@end
