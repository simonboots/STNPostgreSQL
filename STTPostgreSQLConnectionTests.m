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
