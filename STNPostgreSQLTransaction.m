//
//  STNPostgreSQLTransaction.m
//  STNPostgreSQL
//
//  Created by Simon Stiefel on 03.05.07.
//  Copyright 2007 stiefels.net. All rights reserved.
//
//  $Id$
//

#import "STNPostgreSQLTransaction.h"
#import "STNPostgreSQLConnection.h"
#import "STNPostgreSQLStatement.h"

@implementation STNPostgreSQLTransaction

#pragma mark initializers/dealloc

+ (STNPostgreSQLTransaction *)transaction
{
    return [[[self alloc] init] autorelease];
}

+ (STNPostgreSQLTransaction *)transactionWithStatement:(STNPostgreSQLStatement *)statement
{
    return [[[self alloc] initWithStatement:statement] autorelease];
}

+ (STNPostgreSQLTransaction *)transactionWithStatements:(NSArray *)statements
{
    return [[[self alloc] initWithStatements:statements] autorelease];
}

- (id)initWithStatement:(STNPostgreSQLStatement *)statement
{
    self = [self init];
    [self addStatement:statement];
    return self;
}

- (id)initWithStatements:(NSArray *)statements
{
    self = [self init];
    [_statements release];
    _statements = [statements mutableCopy];
    return self;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        _statements = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_delegate release];
    [_statements release];
    [super dealloc];
}

#pragma mark getters/setters

- (void)setStatements:(NSArray *)statements
{
    if (statements != _statements) {
        [_statements release];
        _statements = [statements mutableCopy];
    }
}

- (NSMutableArray *)statements
{
    return _statements;
}

- (void)setDelegate:(id)delegate
{
    if (delegate != _delegate) {
        [_delegate release];
        _delegate = [delegate retain];
    }
}

- (id)delegate
{
    return _delegate;
}

#pragma mark statement operations

- (void)addStatement:(STNPostgreSQLStatement *)statement
{
    [_statements addObject:statement];
}

- (STNPostgreSQLStatement *)statementAtIndex:(unsigned int)index
{
    return [_statements objectAtIndex:index];
}

- (void)insertStatement:(STNPostgreSQLStatement *)statement atIndex:(unsigned int)index
{
    [_statements insertObject:statement atIndex:index];
}

- (void)dropStatementAtIndex:(unsigned int)index
{
    [_statements removeObjectAtIndex:index];
}

- (int)statementCount
{
    return [_statements count];
}

- (void)clearStatements
{
    [_statements removeAllObjects];
}

#pragma mark execution methods

- (BOOL)executeWithConnection:(STNPostgreSQLConnection *)connection error:(NSError **)error
{    
    BOOL success = YES;
    
    STNPostgreSQLStatement *beginTransaction = [STNPostgreSQLStatement statementWithStatement:@"BEGIN"];
    if (! [beginTransaction executeWithConnection:connection error:error]) {
        return NO;
    }
    
    NSEnumerator *statementEnumerator = [_statements objectEnumerator];
    id nextStatement;
    int counter = 0;
    
    while (nextStatement = [statementEnumerator nextObject]) {
        if ([_delegate respondsToSelector:@selector(shouldExecuteStatement:atIndex:ofTotal:)]) {
            if (! [_delegate shouldExecuteStatement:nextStatement atIndex:counter ofTotal:[self statementCount]]) {
                success = NO;
                break;
            }
        }
        
        success = [nextStatement executeWithConnection:connection error:error];
        
        counter++;

        if (! success) {
            break;
        }
    }
    
    STNPostgreSQLStatement *endTransaction;

    if (success) {
        endTransaction = [STNPostgreSQLStatement statementWithStatement:@"COMMIT"];
    } else {
        endTransaction = [STNPostgreSQLStatement statementWithStatement:@"ROLLBACK"];
    }
    
    NSError *endError;
    [endTransaction executeWithConnection:connection error:&endError];
    return success;
}

- (void)startExecutionWithConnection:(STNPostgreSQLConnection *)connection
{
    if ([_delegate respondsToSelector:@selector(transactionAttemptShouldStart)]) {
        if (! [_delegate transactionAttemptShouldStart]) {
            return;
        }
    }
    
    // start thread
    [NSThread detachNewThreadSelector:@selector(executeWithDelegateCalls:) toTarget:self withObject:connection];
}

- (void)executeWithDelegateCalls:(id)param
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    BOOL success;
    NSError *error;
    
    //call delegate
    if ([_delegate respondsToSelector:@selector(transactionAttemptWillStart)]) {
        [_delegate transactionAttemptWillStart];
    }
    
    success = [self executeWithConnection:param error:&error];
    
    // call delegate
    if ([_delegate respondsToSelector:@selector(transactionAttemptEnded:error:)]) {
        [_delegate transactionAttemptEnded:success error:error];
        NSLog(@"transactionAttemptEnded:error: called by object");
    }
    
    [pool release];
    return;
}
    

@end
