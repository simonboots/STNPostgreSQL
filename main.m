//
//  main.m
//  STNPostgreSQL - Playground
//
//  Created by Simon Stiefel on 03.01.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//
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

#include <STNPostgreSQL.h>

int main(void)
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    STNPostgreSQLConnection *conn = [STNPostgreSQLConnection connection];
    [conn retain];
    STNPostgreSQLStatement *statement = [[STNPostgreSQLStatement alloc] initWithConnection:conn];
    NSError *error;
    
    [conn setUser:@"sst"];
    [conn setHost:@"localhost"];
    [conn setDatabaseName:@"postgres"];
    [conn setSSLMode:STNPostgreSQLConnectionSSLModePrefer];
    
    NSLog([conn connectionString]);
    
    if ([conn connect:&error]) {
        NSLog(@"Connection successful");
        NSError *error;
        [statement setStatement:@"CREATE TABLE test (id int, name varchar(50))"];
        if ([statement execute:&error]) {
            NSLog(@"Table created!");
            NSLog(@"kindOfCommand: %@", [[statement result] kindOfCommand]);
        } else {
            NSLog(@"creation failed: %@", [[error userInfo] objectForKey:@"errormessage"]);
            NSLog(@"severity: %@", [[[error userInfo] objectForKey:@"errorfield"] valueForField:STNPostgreSQLSeverityErrorField]);
        }
        
    } else {
        NSLog(@"Connection failed");
        NSLog(@"Error: %@", [[error userInfo] objectForKey:@"errormessage"]);
    }
    
    // Parametered Statement
    STNPostgreSQLParameteredStatement *parameteredstatement = [[STNPostgreSQLParameteredStatement alloc] init];
    [parameteredstatement setConnection:conn];
    [parameteredstatement setStatement:@"INSERT INTO test VALUES($1, $2)"];
    [parameteredstatement addParameterWithValue:@"100" type:@"int8"];
    [parameteredstatement addParameterWithValue:@"Simon" type:@"varchar"];
        
    if (![parameteredstatement execute:&error]) {
        NSLog(@"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    }
    [parameteredstatement release];
    
    STNPostgreSQLStatement *statement1 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO test VALUES(1123, 'successful')"];
    STNPostgreSQLStatement *statement2 = [STNPostgreSQLStatement statementWithStatement:@"INSERT INTO test VALUES(1234, 'also successful')"];
    STNPostgreSQLTransaction *transaction = [STNPostgreSQLTransaction transaction];
    
    [transaction addStatement:statement1];
    [transaction addStatement:statement2];
 
    [transaction executeWithConnection:conn error:&error];
    
    [conn disconnect];
    [conn release];
    
    [pool release];
    
    return 0;
}