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

#pragma mark initializers/dealloc

+ (STNPostgreSQLStatementParameter *)parameterWithValue:(id)value datatype:(NSString *)datatype
{
    return [[[STNPostgreSQLStatementParameter alloc] initWithValue:value
                                                          datatype:datatype] autorelease];
}

+ (STNPostgreSQLStatementParameter *)parameterWithBinaryValue:(NSData *)value datatype:(NSString *)datatype
{
    return [[[STNPostgreSQLStatementParameter alloc] initWithBinaryValue:value
                                                                datatype:datatype] autorelease];
}

- (id)initWithBinaryValue:(NSData *)value datatype:(NSString *)datatype
{
    self = [self initWithValue:value
                      datatype:datatype];
    _length = [value length];
    _format = STNPostgreSQLParameterFormatBinary;
    
    return self;
}

- (id)initWithValue:(id)value datatype:(NSString *)datatype
{
    self = [super init];
    if (self != nil) {
        [self setValue:value];
        [self setDatatype:datatype];
        _length = 0;
        _format = STNPostgreSQLParameterFormatString;
    }
    return self;
}

- (id)init
{
    [self initWithValue:nil datatype:nil];
    return self;
}

- (void)dealloc
{
    [_value release];
    [super dealloc];
}

#pragma mark getters/setters

- (void)setDatatype:(NSString *)datatype
{
    if (datatype != _datatype) {
        [_datatype release];
        _datatype = [datatype retain];
    }
}

- (NSString *)datatype
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

- (void)setBinaryValue:(NSData *)value
{
    [self setValue:value];
    _length = [value length];
}

- (id)value
{
    return _value;
}


@end
