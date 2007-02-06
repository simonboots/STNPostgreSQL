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
    STNPostgreSQLConnection *conn = [[STNPostgreSQLConnection alloc] init];
    NSError *error;
    
    [conn setUser:@"sst"];
    [conn setHost:@"localhost"];
    [conn setDatabaseName:@"template1"];
    [conn setSSLMode:STNPostgreSQLConnectionSSLModePrefer];

    NSLog([conn connectionString]);
    
    if ([conn connect:&error]) {
        NSLog(@"Connection successfull");
    } else {
        NSLog(@"Connection failed");
        NSLog(@"Error: %@", [[error userInfo] objectForKey:@"errormessage"]);
    }
    
    [pool release];
    
    return 0;
}