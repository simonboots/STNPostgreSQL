//
//  STTPostgreSQLConnectionTests.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 06.02.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//
//  Redistribution and use in source and binary forms, with or
//  without modification, are permitted provided that the
//  following conditions are met:
//
//  1. Redistributions of source code must retain the above
//  copyright notice, this list of conditions and the following
//  disclaimer.
//
//  2. Redistributions in binary form must reproduce the above
//  copyright notice, this list of conditions and the following
//  disclaimer in the documentation and/or other materials
//  provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOTLIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
//  OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
