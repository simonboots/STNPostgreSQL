//
//  STNPostgreSQLErrorDomain.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 13.11.06.
//  Copyright 2006 stiefels.net. All rights reserved.
//
//  $Id$
//
//  For PostgreSQL Copyright information read PostgreSQL_COPYRIGHT
//
//  Redistribution and use in source and binary forms, with or
//  without modification, are permitted provided that the
//  following conditions are met:
//
//  1. Redistributions of source code must retain the above
//  copyright notice, this list of conditions and the following
//  disclaimer.
//
//  2. Redistributions in binary form must reproduce the above
//  copyright notice, this list of conditions and the following
//  disclaimer in the documentation and/or other materials
//  provided with the distribution.
//
//  THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED
//  WARRANTIES, INCLUDING, BUT NOTLIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS
//  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
//  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT
//  OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
//  OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
//  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
//  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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
    STNPostgreSQLNotConnected = 103,
    STNPostgreSQLNoConnection = 104,
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