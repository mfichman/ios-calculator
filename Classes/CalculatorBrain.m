//
//  CalculatorBrain.m
//  Calculator
//
//  Created by Matthew Fichman on 9/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "CalculatorBrain.h"

#define VARIABLE_PREFIX @"%";

static CalculatorBrain* expressionEvaluatorBrain = nil;

@implementation CalculatorBrain

@synthesize error, operand;

- (id)init
{
	if ((self = [super init])) {
		expression = [[NSMutableArray alloc] init];
	}
	return self;
}

- (id)expression
{
	/* 
	 * N.B.: expression is set to autorelease because we own objects
	 * created with copy.
	 */
	NSArray *expressionCopy = [expression copy];
	[expressionCopy autorelease];
	return expressionCopy;
}

- (void)setExpression:(id)anExpression
{
	if ([anExpression isKindOfClass:[NSArray class]]) {
		[expression removeAllObjects];
		[expression addObjectsFromArray:anExpression];
	}
}

- (void)performWaitingOperation
{
	if ([@"+" isEqual:waitingOperation]) {
		operand = waitingOperand + operand;
	} else if ([@"-" isEqual:waitingOperation]) {
		operand = waitingOperand - operand;
	} else if ([@"*" isEqual:waitingOperation]) {
		operand = waitingOperand * operand;
	} else if ([@"/" isEqual:waitingOperation]) {
		if (operand) {
			operand = waitingOperand / operand;
		} else {
			error = @"Divide by zero";
		}
	}
}

- (void)setOperand:(double)aDouble
{
	operand = aDouble;
	[expression addObject:[NSNumber numberWithDouble:aDouble]];
}

- (void)setVariableAsOperand:(NSString *)variableName
{	
	/*
	 * Add any variable that is non-empty to the expression; fail silently on
	 * a zero-length variable name.  Also guard against nil.
	 */
	if (variableName && variableName.length > 0) {
		NSString *variablePrefix = VARIABLE_PREFIX;
		[expression addObject:[NSString stringWithFormat:@"%@%@", variablePrefix, variableName]];
	}
}

- (double)performOperation:(NSString *)operation
{
	/* Guard against a nil operation */
	if (!operation) {
		return operand;
	}
	
	/* 
	 * When the user enters a new operation, clear any errors.
	 * If an error occurs during this operation, then record it 
	 */
	[error release];
	error = nil;
	
	/* Add the current operation to the expression */
	[expression addObject:operation];
	
    if ([operation isEqual:@"C"]) {
		/* 
		 * Clear operation.  Clear memory, operands, and waiting operations
		 * Avoid leaking expression memory by removing all objects and reusing 
		 * the same array.
		 */
		[expression removeAllObjects];
		[waitingOperation release];
		waitingOperation = nil;
		waitingOperand = 0.0;
		operand = 0.0;
		savedOperand = 0.0;
	} 
	
	if ([CalculatorBrain variablesInExpression: expression]) {
		return operand;
	}
	
	/* 
	 * Execute the operation the user requested, or save the operation
	 * if it is a binary operation.
	 */
	if ([operation isEqual:@"sqrt"]) {
		if (operand >= 0) {
			operand = sqrt(operand);
		} else {
			error = @"Square root of a negative number";
			operand = NAN;
		}
	} else if ([operation isEqual:@"+/-"]) {
		operand = -operand;
	} else if ([operation isEqual:@"sin"]) {
		operand = sin(operand);
	} else if ([operation isEqual:@"cos"]) {
		operand = cos(operand);
	} else if ([operation isEqual:@"1/x"]) {
		if (operand) {
			operand = 1.0/operand;
		} else {
			error = @"Divide by zero";
			operand = NAN;
		}
	} else if ([operation isEqual:@"Store"]) {
		savedOperand = operand;
	} else if ([operation isEqual:@"Recall"]) {
		operand = savedOperand;
	} else if ([operation isEqual:@"Mem +"]) {
		savedOperand = operand + savedOperand;
	} else {
		/* Binary operation; save current operation and execute previous one */
		[self performWaitingOperation];
		waitingOperation = operation;
		[waitingOperation retain];
		waitingOperand = operand;
	}
	return operand;
}

+ (double)evaluateExpression:(id)anExpression
		 usingVariableValues:(NSDictionary *)variables
{
	/* Argument sanity check */
	if (![anExpression isKindOfClass:NSArray.class] || !variables) {
		return 0;
	}

	/* Clear or initialize the evaluator brain */
	if (!expressionEvaluatorBrain) {
		expressionEvaluatorBrain = [[CalculatorBrain alloc] init];
	} else {
		[expressionEvaluatorBrain performOperation:@"C"];
	}
		
	/* For each object in the expression, set the operand or perform the operation */
	for (id object in (NSArray *)anExpression) {
		
		if ([object isKindOfClass:NSNumber.class]) {
			/* Object is a number operand */
			expressionEvaluatorBrain.operand = [object doubleValue];
			
		} else if ([object isKindOfClass:NSString.class]) {
			/* Object is either a variable or an operator */
			NSString *variablePrefix = VARIABLE_PREFIX;
			if ([object length] > variablePrefix.length && [object hasPrefix:variablePrefix]) {
				/* 
				 * This string is a variable because it has the correct prefix. Get the
				 * variable value and use it to set the current operand.
				 */
				NSString *variableName = [object substringFromIndex:variablePrefix.length];
				NSNumber *value = [variables objectForKey:variableName];
				if (value) {
					expressionEvaluatorBrain.operand = [value doubleValue];
				} else {
					expressionEvaluatorBrain.operand = 0;
				}
				
			} else {
				/* Operator found */
				expressionEvaluatorBrain.operand = [expressionEvaluatorBrain performOperation:object];
			}
		}
	}
	
	return expressionEvaluatorBrain.operand;
}

+ (NSSet *)variablesInExpression:(id)anExpression
{
	/* Argument sanity check */
	if (![anExpression isKindOfClass:NSArray.class]) {
		return nil;
	}

	NSMutableSet *variables = nil;
	NSString *variablePrefix = VARIABLE_PREFIX;

	/* Look for strings with the correct prefix, and add them to the set */
	for (id object in (NSArray *)anExpression) {
		
		if ([object isKindOfClass:NSString.class] && 
			[object length] > variablePrefix.length &&
			[object hasPrefix:variablePrefix]) {
		
			NSString *variableName = [object substringFromIndex:variablePrefix.length];
			if (!variables) {
				variables = [[NSMutableSet alloc] init];
				[variables autorelease];
			}
			[variables addObject:variableName];
		}
	}
	return variables;
}

+ (NSString *)descriptionOfExpression:(id)anExpression
{
	/* Argument sanity check */
	if (![anExpression isKindOfClass:NSArray.class]) {
		return nil;
	}
	
	NSString *variablePrefix = VARIABLE_PREFIX;
	NSMutableString *description = [[NSMutableString alloc] init];
	[description autorelease];
	
	/* Append all of the objects to the description string */
	for (id object in (NSArray *)anExpression) {
		if ([object isKindOfClass:NSNumber.class]) {
			/* Operand, append the double value */
			[description appendFormat:@"%g", [object doubleValue]];
		} else if ([object isKindOfClass:NSString.class]) {
			if ([object length] > variablePrefix.length && [object hasPrefix:variablePrefix]) {
				/* Variable name */
				NSString *variableName = [object substringFromIndex:variablePrefix.length];
				[description appendFormat:@"%@", variableName];
			} else {
				/* Operation, append the symbol */
				[description appendFormat:@"%@", object];
			}
		}
		[description appendString:@" "];
	}
	return description;
}

+ (id)propertyListForExpression:(id)anExpression
{
	if ([anExpression isKindOfClass:NSArray.class]) {
		/* 
		 * Make a copy of the expression, which we own.  Then, since 
		 * 'propertyListForExpression' doesn't start with new, alloc or copy,
		 * make sure the object is set to autorelease.
		 */
		id expressionCopy = [anExpression copy];
		[expressionCopy autorelease];
		return expressionCopy;
	} else {
		return nil;
	}
}

+ (id)expressionForPropertyList:(id)propertyList
{
	if ([propertyList isKindOfClass:NSArray.class]) {
		/* 
		 * Make a copy of the expression, which we own.  Then, since 
		 * 'expressionForPropertyList' doesn't start with new, alloc or copy,
		 * make sure the object is set to autorelease.
		 */
		id expressionCopy = [propertyList copy];
		[expressionCopy autorelease];
		return expressionCopy;
	} else {
		return nil;
	}
}


- (void)dealloc
{
	[waitingOperation release];
	[expression release];
	[error release];
	[super dealloc];
}

@end
