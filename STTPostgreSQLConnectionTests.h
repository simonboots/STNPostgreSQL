//
//  STTPostgreSQLConnectionTests.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 06.02.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <SenTestingKit/SenTestingKit.h>
#import "STNPostgreSQL.h"

@interface STTPostgreSQLConnectionTests : SenTestCase {
    STNPostgreSQLConnection *conn;
    BOOL pleaseWait; // wait for thread
}

- (void)setUp;
- (void)tearDown;

- (void)testConnectionDirect;
- (void)testConnectionThreaded;

- (BOOL)connectionAttemptShouldStart;
- (void)connectionAttemptWillStart;
- (void)connectionAttemptEnded:(BOOL)success error:(NSError *)error;

@end
