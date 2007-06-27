//
//  STNPostgreSQLStatementParameter.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 13.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
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

#import "STNPostgreSQLStatementParameter.h"

@implementation STNPostgreSQLStatementParameter

#pragma mark initializers/dealloc

+ (STNPostgreSQLStatementParameter *)parameterWithDatatype:(NSString *)datatype
{
    return [[[STNPostgreSQLStatementParameter alloc] initWithValue:nil
                                                          datatype:datatype] autorelease];
}

+ (STNPostgreSQLStatementParameter *)parameterWithValue:(id)value
{
    return [[[STNPostgreSQLStatementParameter alloc] initWithValue:value
                                                          datatype:nil] autorelease];
}

+ (STNPostgreSQLStatementParameter *)parameterWithBinaryValue:(NSData *)value
{
    return [[[STNPostgreSQLStatementParameter alloc] initWithBinaryValue:value
                                                                datatype:nil] autorelease];
}

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
    _format = STNPostgreSQLParameterFormatString;
}

- (void)setBinaryValue:(NSData *)value
{
    [self setValue:value];
    _length = [value length];
    _format = STNPostgreSQLParameterFormatBinary;
}

- (id)value
{
    return _value;
}


@end
