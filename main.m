//
//  main.m
//  STNPostgreSQL - Playground
//
//  Created by Simon Stiefel on 03.01.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
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
        [statement setStatement:@"CREATE TABLE test3 (id int, name varchar(50))"];
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
    [parameteredstatement addParameterWithValue:@"4712" type:@"int8" length:0 format:0];
    [parameteredstatement addParameterWithValue:@"SimonSt" type:@"varchar" length:0 format:0];
        
    if (![parameteredstatement execute:&error]) {
        NSLog(@"Statement should be executed (%@)", [[error userInfo] objectForKey:@"errormessage"]);
    }
    [parameteredstatement release];
    
    [conn disconnect];
    [conn release];
    
    conn = [[STNPostgreSQLConnection alloc] init];
    [conn retain];
    [conn setUser:@"sst"];
    [conn setHost:@"localhost"];
    [conn setDatabaseName:@"postgres"];
    [conn setSSLMode:STNPostgreSQLConnectionSSLModePrefer];
    [conn connect:&error];
    [conn disconnect];
    [conn release];
    [pool release];
    
    return 0;
}