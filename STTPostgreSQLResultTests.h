//
//  STTPostgreSQLResultTests.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 03.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <SenTestingKit/SenTestingKit.h>
#import "STNPostgreSQL.h"

@interface STTPostgreSQLResultTests : SenTestCase {
    STNPostgreSQLConnection *_conn;
    STNPostgreSQLStatement *_statement;
    STNPostgreSQLResult *_result;
}

@end
