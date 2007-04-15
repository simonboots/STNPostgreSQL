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
    NSError *error;
    
    [conn setUser:@"sst"];
    [conn setHost:@"localhost"];
    [conn setDatabaseName:@"postgres"];
    [conn setSSLMode:STNPostgreSQLConnectionSSLModePrefer];
    
    NSLog([conn connectionString]);
    
    if ([conn connect:&error]) {
        NSLog(@"Connection successful");
        NSError *error;
        STNPostgreSQLStatement *statement = [[STNPostgreSQLStatement alloc] initWithConnection:conn];
        [statement setStatement:@"CREATE TABLE test (id int, name varchar(50))"];
        if ([statement execute:&error]) {
            NSLog(@"Table created!");
        } else {
            NSLog(@"creation failed: %@", [[error userInfo] objectForKey:@"errormessage"]);
            NSLog(@"severity: %@", [[[error userInfo] objectForKey:@"errorfield"] valueForField:STNPostgreSQLSeverityErrorField]);
        }
        
    } else {
        NSLog(@"Connection failed");
        NSLog(@"Error: %@", [[error userInfo] objectForKey:@"errormessage"]);
    }
    
    [pool release];
    
    return 0;
}