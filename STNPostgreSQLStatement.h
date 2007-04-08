//
//  STNPostgreSQLStatement.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 01.04.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <Cocoa/Cocoa.h>
#import "STNPostgreSQL.h"

@interface STNPostgreSQLStatement : NSObject {
    NSString *_statement;
    STNPostgreSQLConnection *_connection;
}

- (id)initWithConnection:(STNPostgreSQLConnection *)connection;

- (void)setStatement:(NSString *)statement;
- (NSString *)statement;

- (void)setConnection:(STNPostgreSQLConnection *)connection;
- (STNPostgreSQLConnection *)connection;

- (BOOL)execute:(NSError **)error;

- (NSDictionary *)generateErrorField:(PGresult *)result;

@end
