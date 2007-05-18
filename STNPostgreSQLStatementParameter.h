//
//  STNPostgreSQLStatementParameter.h
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 13.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import <Cocoa/Cocoa.h>

enum STNPostgreSQLParameterFormat {
    STNPostgreSQLParameterFormatString = 0,
    STNPostgreSQLParameterFormatBinary = 1
};

@interface STNPostgreSQLStatementParameter : NSObject {
    unsigned int _datatype;
    int _length;
    int _format;
    id  _value;
}

+ (STNPostgreSQLStatementParameter *)parameterWithValue:(id)value datatype:(unsigned int)datatype;
+ (STNPostgreSQLStatementParameter *)parameterWithBinaryValue:(NSData *)value datatype:(unsigned int)datatype length:(int)length;

- (id)initWithValue:(id)value datatype:(unsigned int)datatype length:(int)length format:(int)format;
- (id)initWithValue:(id)value datatype:(unsigned int)datatype;
- (id)initWithBinaryValue:(NSData *)value datatype:(unsigned int)datatype length:(int)length;

- (void)setDatatype:(unsigned int)datatype;
- (unsigned int)datatype;
- (void)setLength:(int)length;
- (int)length;
- (void)setFormat:(int)format;
- (int)format;
- (void)setValue:(id)value;
- (id)value;
- (void)dealloc;

@end
