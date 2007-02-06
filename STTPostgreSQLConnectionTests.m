//
//  STTPostgreSQLConnectionTests.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 06.02.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STTPostgreSQLConnectionTests.h"


@implementation STTPostgreSQLConnectionTests

- (void)setUp
{
    conn = [[STNPostgreSQLConnection alloc] init];
    pleaseWait = NO;
    
    [conn setUser:@"sst"];
    [conn setHost:@"localhost"];
    [conn setDatabaseName:@"template1"];
    [conn setSSLMode:STNPostgreSQLConnectionSSLModePrefer];
}

- (void)testConnectionDirect
{
    NSError *error;
    STAssertTrue([conn connect:&error], @"connect should return YES (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    pleaseWait = NO;
}

- (void)testConnectionThreaded
{
    pleaseWait = YES;
    
    [conn setDelegate:self];
    [conn startConnection];
}

- (void)testServerInformation
{
    NSError *error;
    STAssertTrue([conn connect:&error], @"connection failed! (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    pleaseWait = NO;
    
    NSDictionary *serverInformation = [conn serverInformation];
    
    STAssertTrue([[serverInformation objectForKey:@"versionnumber"] isEqualToNumber:[NSNumber numberWithInt:80200]], @"Version number mismatch (%d)", [[serverInformation objectForKey:@"versionnumber"] intValue]);
    STAssertTrue([[serverInformation objectForKey:@"formattedversionnumber"] isEqualToString:@"8.2.0"], @"Formatted version number mismatch (%@)", [serverInformation objectForKey:@"formattedversionnumber"]);
    STAssertTrue([[serverInformation objectForKey:@"protocolversion"] isEqualToNumber:[NSNumber numberWithInt:3]], @"Protocol version mismatch (%d)", [[serverInformation objectForKey:@"protocolversion"] intValue]);
}

- (void)testAvailableStatementFeatures
{
    // Tests availability of parametered and prepared statements
    NSError *error;
    STAssertTrue([conn connect:&error], @"connection failed! (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    pleaseWait = NO;
    
    NSDictionary *serverInformation = [conn serverInformation];
    
    if ([[serverInformation objectForKey:@"protocolversion"] isEqualToNumber:[NSNumber numberWithInt:PROTOCOLVERSION_PARAM_STATEMENT]]) {
        STAssertTrue([conn parameteredStatementAvailable], @"Parametered Statements should be available");
    } else {
        STAssertFalse([conn parameteredStatementAvailable], @"Parametered Statements should not be available");
    }
    
    if ([[serverInformation objectForKey:@"protocolversion"] isEqualToNumber:[NSNumber numberWithInt:PROTOCOLVERSION_PREP_STATEMENT]]) {
        STAssertTrue([conn preparedStatementsAvailable], @"Prepared statements should be available");
    } else {
        STAssertFalse([conn preparedStatementsAvailable], @"Prepared statements should not be available");
    }
}

- (BOOL)connectionAttemptShouldStart
{
    NSLog(@"connectionAttemptShouldStart called (1/3)");
    return YES;
}

- (void)connectionAttemptWillStart
{
    NSLog(@"connectionAttemptWillStart called (2/3)");
}

- (void)connectionAttemptEnded:(BOOL)success error:(NSError *)error
{
    NSLog(@"connectionAttemptEnded called (3/3)");
    STAssertTrue(success, @"success should be YES (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    pleaseWait = NO;
}

- (void)tearDown
{
    while (pleaseWait == YES) {
        sleep(1);
    }
    
    [conn disconnect];
    [conn release];
}

@end
