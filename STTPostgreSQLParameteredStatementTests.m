//
//  STTPostgreSQLParameteredStatementTests.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 17.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//
//  For PostgreSQL Copyright information read PostgreSQL_COPYRIGHT
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
    
    [statement setStatement:@"INSERT INTO stnpostgresqltests VALUES($1, $2)"];
    [statement addParameterWithValue:@"11" type:@"int8"];
    [statement addParameterWithValue:@"eleven" type:@"varchar"];
    
    NSError *error;
    
    STAssertTrue([statement execute:&error], @"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
}

- (void)testInvalidStatement
{
    STNPostgreSQLParameteredStatement *statement = [[STNPostgreSQLParameteredStatement alloc] init];
    [statement setConnection:_conn];
    
    [statement setStatement:@"INSERT INTO stnpostgresqltests VALUES($1, $2)"];
    [statement addParameterWithValue:@"12" type:@"int8"];
    
    NSError *error;
    
    STAssertFalse([statement execute:&error], @"Statement shouldn't be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
}

- (void)testWithSeparateParameter
{
    STNPostgreSQLParameteredStatement *statement = [[STNPostgreSQLParameteredStatement alloc] init];
    [statement setConnection:_conn];
    
    [statement setStatement:@"INSERT INTO stnpostgresqltests VALUES($1, $2)"];
    [statement addParameterWithValue:@"13" type:@"int8"];
    
    // separate parameter
    
    STNPostgreSQLStatementParameter *param = [STNPostgreSQLStatementParameter parameterWithValue:@"thirteen" 
                                                                                        datatype:@"varchar"];
    
    [statement addParameter:param];
    
    NSError *error;
    
    STAssertTrue([statement execute:&error], @"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    [statement release];
}

- (void)testWithSeparateBinaryParameter
{
    char binaryValue[] = {'F', 'o', 'u', 'r', 't', 'e', 'e', 'n'};
    NSData *binaryData = [NSData dataWithBytes:binaryValue length:8];
   
    STNPostgreSQLParameteredStatement *statement =[[STNPostgreSQLParameteredStatement alloc] init];
    [statement setConnection:_conn];
    
    [statement setStatement:@"INSERT INTO stnpostgresqltests VALUES($1, $2)"];
    [statement addParameterWithValue:@"14" type:@"int8"];
    
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
