//
//  STNPostgreSQLErrorDomain.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 13.11.06.
//  Copyright 2006 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <Cocoa/Cocoa.h>

/*!
@const 
 @abstract   error domain constant
 @discussion contains error domain constant
 */

extern NSString *const STNPostgreSQLErrorDomain;

/*!
@enum
 @abstract      Error codes for STNPostgreSQLErrorDomain
 @discussion    Error codes for STNPostgreSQLErrorDomain
 @constant      STNPostgreSQLConnectionFailed Connection couldn't be established
 @constant      STNPostgreSQLClientEncodingFailed Client encoding couldn't be set
 @constant      STNPostgreSQLStatementFatalError Fatal error in statement execution
 */
enum {
    STNPostgreSQLConnectionFailed = 101,
    STNPostgreSQLClientEncodingFailed = 102,
	STNPostgreSQLEmptyQueryError = 110,
	STNPostgreSQLBadResponseError = 111,
	STNPostgreSQLStatementNonFatalError = 112,
	STNPostgreSQLStatementFatalError = 113
};