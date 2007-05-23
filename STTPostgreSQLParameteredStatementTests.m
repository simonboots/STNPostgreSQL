//
//  STTPostgreSQLParameteredStatementTests.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 17.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STTPostgreSQLParameteredStatementTests.h"


@implementation STTPostgreSQLParameteredStatementTests

- (void)setUp
{
    _conn = [[STNPostgreSQLConnection alloc] init];
    NSError *error;
    
    [_conn setUser:[NSString stringWithCString:UT_USERNAME encoding:NSASCIIStringEncoding]];
    [_conn setPassword:[NSString stringWithCString:UT_PASSWD encoding:NSASCIIStringEncoding]];
    [_conn setHost:[NSString stringWithCString:UT_HOST encoding:NSASCIIStringEncoding]];
    [_conn setDatabaseName:[NSString stringWithCString:UT_DATABASE encoding:NSASCIIStringEncoding]];
    [_conn setPort:[NSString stringWithCString:UT_PORT encoding:NSASCIIStringEncoding]];
    [_conn setSSLMode:STNPostgreSQLConnectionSSLModePrefer];
    STAssertTrue([_conn connect:&error], @"connect should return YES (%@)", [[error userInfo] objectForKey:@"errormessage"]);
}

- (void)testValidStatement
{
    STNPostgreSQLParameteredStatement *statement = [[STNPostgreSQLParameteredStatement alloc] init];
    [statement setConnection:_conn];
    
    [statement setStatement:@"INSERT INTO test VALUES($1, $2)"];
    [statement addParameterWithValue:@"4712" type:@"int8"];
    [statement addParameterWithValue:@"SimonSt" type:@"varchar"];
    
    NSError *error;
    
    STAssertTrue([statement execute:&error], @"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
}

- (void)testInvalidStatement
{
    STNPostgreSQLParameteredStatement *statement = [[STNPostgreSQLParameteredStatement alloc] init];
    [statement setConnection:_conn];
    
    [statement setStatement:@"INSERT INTO test VALUES($1, $2)"];
    [statement addParameterWithValue:@"4712" type:@"int8"];
    
    NSError *error;
    
    STAssertFalse([statement execute:&error], @"Statement shouldn't be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
}

- (void)testWithSeparateParameter
{
    STNPostgreSQLParameteredStatement *statement = [[STNPostgreSQLParameteredStatement alloc] init];
    [statement setConnection:_conn];
    
    [statement setStatement:@"INSERT INTO test VALUES($1, $2)"];
    [statement addParameterWithValue:@"4713" type:@"int8"];
    
    // separate parameter
    
    STNPostgreSQLStatementParameter *param = [STNPostgreSQLStatementParameter parameterWithValue:@"A Value" 
                                                                                        datatype:@"varchar"];
    
    [statement addParameter:param];
    
    NSError *error;
    
    STAssertTrue([statement execute:&error], @"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
}

- (void)testWithSeparateBinaryParameter
{
    char binaryValue[] = {'H', 'e', 'l', 'l', 'o', ' ', 'W', 'o', 'r', 'l', 'd'};
    NSData *binaryData = [NSData dataWithBytes:binaryValue length:11];
    
    STNPostgreSQLParameteredStatement *statement =[[STNPostgreSQLParameteredStatement alloc] init];
    [statement setConnection:_conn];
    
    [statement setStatement:@"INSERT INTO test VALUES($1, $2)"];
    [statement addParameterWithValue:@"4714" type:@"int8"];
    
    // binary parameter
    STNPostgreSQLStatementParameter *binaryParameter = [STNPostgreSQLStatementParameter parameterWithBinaryValue:binaryData
                                                                                                        datatype:@"varchar"];
    [statement addParameter:binaryParameter];
    
    NSError *error;
    
    STAssertTrue([statement execute:&error], @"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
    
}
    

- (void)tearDown
{
    [_conn disconnect];
    [_conn release];
}

@end
