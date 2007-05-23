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
    _conn = [[STNPostgreSQLConnection alloc] init];
    _pleaseWait = NO;
    
    [_conn setUser:[NSString stringWithCString:UT_USERNAME encoding:NSASCIIStringEncoding]];
    [_conn setPassword:[NSString stringWithCString:UT_PASSWD encoding:NSASCIIStringEncoding]];
    [_conn setHost:[NSString stringWithCString:UT_HOST encoding:NSASCIIStringEncoding]];
    [_conn setDatabaseName:[NSString stringWithCString:UT_DATABASE encoding:NSASCIIStringEncoding]];
    [_conn setPort:[NSString stringWithCString:UT_PORT encoding:NSASCIIStringEncoding]];
    [_conn setSSLMode:STNPostgreSQLConnectionSSLModePrefer];
}

- (void)testConnectionDirect
{
    NSError *error;
    STAssertTrue([_conn connect:&error], @"connect should return YES (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    _pleaseWait = NO;
}

- (void)testConnectionThreaded
{
    _pleaseWait = YES;
    
    [_conn setDelegate:self];
    [_conn startConnection];
}

- (void)testServerInformation
{
    NSError *error;
    STAssertTrue([_conn connect:&error], @"connection failed! (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    _pleaseWait = NO;
    
    NSDictionary *serverInformation = [_conn serverInformation];
    
    STAssertTrue([[serverInformation objectForKey:@"versionnumber"] isEqualToNumber:[NSNumber numberWithInt:POSTGRESQL_INT_VERSION]], @"Version number mismatch (%d)", [[serverInformation objectForKey:@"versionnumber"] intValue]);
    STAssertTrue([[serverInformation objectForKey:@"formattedversionnumber"] isEqualToString:[NSString stringWithCString:POSTGRESQL_VERSION encoding:NSASCIIStringEncoding]], @"Formatted version number mismatch (%@)", [serverInformation objectForKey:@"formattedversionnumber"]);
    STAssertTrue([[serverInformation objectForKey:@"protocolversion"] isEqualToNumber:[NSNumber numberWithInt:3]], @"Protocol version mismatch (%d)", [[serverInformation objectForKey:@"protocolversion"] intValue]);
}

- (void)testAvailableStatementFeatures
{
    // Tests availability of parametered and prepared statements
    NSError *error;
    STAssertTrue([_conn connect:&error], @"connection failed! (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    _pleaseWait = NO;
    
    NSDictionary *serverInformation = [_conn serverInformation];
    
    if ([[serverInformation objectForKey:@"protocolversion"] isEqualToNumber:[NSNumber numberWithInt:PROTOCOLVERSION_PARAM_STATEMENT]]) {
        STAssertTrue([_conn parameteredStatementAvailable], @"Parametered Statements should be available");
    } else {
        STAssertFalse([_conn parameteredStatementAvailable], @"Parametered Statements should not be available");
    }
    
    if ([[serverInformation objectForKey:@"protocolversion"] isEqualToNumber:[NSNumber numberWithInt:PROTOCOLVERSION_PREP_STATEMENT]]) {
        STAssertTrue([_conn preparedStatementsAvailable], @"Prepared statements should be available");
    } else {
        STAssertFalse([_conn preparedStatementsAvailable], @"Prepared statements should not be available");
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
    _pleaseWait = NO;
}

- (void)tearDown
{
    while (_pleaseWait == YES) {
        sleep(1);
    }
    
    [_conn disconnect];
    [_conn release];
}

@end
