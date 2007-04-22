//
//  STTPostgreSQLStatementTests.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 22.04.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <SenTestingKit/SenTestingKit.h>
#import "STNPostgreSQL.h"

@interface STTPostgreSQLStatementTests : SenTestCase {
    STNPostgreSQLConnection *_conn;
    BOOL _pleaseWait; // wait for thread
}

- (void)setUp;
- (void)tearDown;

- (void)testValidStatement;
- (void)testInvalidStatement;

@end
