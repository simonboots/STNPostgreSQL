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
#import "libpq-fe.h"

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
enum STNPostgreSQLError {
    STNPostgreSQLConnectionError = 101,
    STNPostgreSQLClientEncodingError = 102,
	STNPostgreSQLEmptyQueryError = 110,
	STNPostgreSQLBadResponseError = 111,
	STNPostgreSQLStatementNonFatalError = 112,
	STNPostgreSQLStatementFatalError = 113
};

enum STNPostgreSQLErrorFields {
    STNPostgreSQLSeverityErrorField = PG_DIAG_SEVERITY,
    STNPostgreSQLSQLStateErrorField = PG_DIAG_SQLSTATE,
    STNPostgreSQLPrimaryMessageErrorField = PG_DIAG_MESSAGE_PRIMARY,
    STNPostgreSQLDetailMessageErrorField = PG_DIAG_MESSAGE_DETAIL,
    STNPostgreSQLHintMessageErrorField = PG_DIAG_MESSAGE_HINT,
    STNPostgreSQLStatementPositionErrorField = PG_DIAG_STATEMENT_POSITION,
    STNPostgreSQLInternalPositionErrorField = PG_DIAG_INTERNAL_POSITION,
    STNPostgreSQLInternalQueryErrorField = PG_DIAG_INTERNAL_QUERY,
    STNPostgreSQLContextErrorField = PG_DIAG_CONTEXT,
    STNPostgreSQLSourceFileErrorField = PG_DIAG_SOURCE_FILE,
    STNPostgreSQLSourceLineErrorField = PG_DIAG_SOURCE_LINE,
    STNPostgreSQLSourceFunctionErrorField = PG_DIAG_SOURCE_FUNCTION
};