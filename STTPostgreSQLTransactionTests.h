//
//  STTPostgreSQLTransactionTests.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 22.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <SenTestingKit/SenTestingKit.h>
#import "STNPostgreSQL.h"

@interface STTPostgreSQLTransactionTests : SenTestCase {
    STNPostgreSQLConnection *_conn;
    BOOL _pleaseWait; // wait for thread
    int _callbackcounter;
}

@end
