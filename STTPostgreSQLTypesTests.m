//
//  STTPostgreSQLTypesTests.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 09.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STTPostgreSQLTypesTests.h"


@implementation STTPostgreSQLTypesTests

- (void)setUp
{
    _conn = [[STNPostgreSQLConnection alloc] init];
    NSError *error;
    
    [_conn setUser:@"sst"];
    [_conn setHost:@"localhost"];
    [_conn setDatabaseName:@"postgres"];
    [_conn setSSLMode:STNPostgreSQLConnectionSSLModePrefer];
    STAssertTrue([_conn connect:&error], @"connect should return YES (%@)", [[error userInfo] objectForKey:@"errormessage"]);
}

- (void)testTypeCount
{
    STNPostgreSQLTypes *types = [_conn availableTypes];
    STAssertTrue([[types types] count] > 1, @"Typecount is zero!");
}

- (void)testIntegerTypeOid
{
    unsigned int oid = [[_conn availableTypes] oidForType:@"int8"];
    STAssertEquals(oid, (unsigned int)20, @"int8 is not oid 20 (is %d)", oid);
}

- (void)testOidType
{
    NSString *typename = [[_conn availableTypes] typeWithOid:790];
    STAssertEqualObjects(typename, @"money", @"Oid 790 is not type 'money' (is %@)", typename);
}

- (void)tearDown
{
    [_conn disconnect];
    [_conn release];
}

@end
