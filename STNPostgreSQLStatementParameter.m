//
//  STNPostgreSQLStatementParameter.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 13.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STNPostgreSQLStatementParameter.h"


@implementation STNPostgreSQLStatementParameter

+ (STNPostgreSQLStatementParameter *)parameterWithValue:(id)value datatype:(unsigned int)datatype
{
    return [[[STNPostgreSQLStatementParameter alloc] initWithValue:value
                                                          datatype:datatype] autorelease];
}

+ (STNPostgreSQLStatementParameter *)parameterWithBinaryValue:(NSData *)value datatype:(unsigned int)datatype length:(int)length
{
    return [[STNPostgreSQLStatementParameter alloc] initWithBinaryValue:value
                                                                datatype:datatype
                                                                  length:length];
}

- (id)initWithValue:(id)value datatype:(unsigned int)datatype
{
    return [self initWithValue:value
                      datatype:datatype
                        length:0 
                        format:STNPostgreSQLParameterFormatString];
}

- (id)initWithBinaryValue:(NSData *)value datatype:(unsigned int)datatype length:(int)length
{
    return [self initWithValue:value
                      datatype:datatype
                        length:length
                        format:STNPostgreSQLParameterFormatBinary];
}

- (id)initWithValue:(id)value datatype:(unsigned int)datatype length:(int)length format:(int)format
{
    self = [super init];
    if (self != nil) {
        [self setValue:value];
        [self setDatatype:datatype];
        [self setLength:length];
        [self setFormat:format];
    }
    return self;
}

- (id)init
{
    [self initWithValue:nil datatype:0 length:0 format:STNPostgreSQLParameterFormatString];
    return self;
}

- (void)setDatatype:(unsigned int)datatype
{
    _datatype = datatype;
}

- (unsigned int)datatype
{
    return _datatype;
}

- (void)setLength:(int)length
{
    _length = length;
}

- (int)length
{
    return _length;
}

- (void)setFormat:(int)format
{
    _format = format;
}

- (int)format
{
    return _format;
}

- (void)setValue:(id)value
{
    if (_value != value) {
        [_value release];
        _value = [value retain];
    }
}

- (id)value
{
    return _value;
}

- (void)dealloc
{
    [_value release];
    [super dealloc];
}

@end
