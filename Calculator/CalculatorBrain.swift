//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Richard E Millet on 2/1/15.
//  Copyright (c) 2015 remillet. All rights reserved.
//

import Foundation

let piSymbol = "π"

class CalculatorBrain
{
	private enum Op: Printable { // "Printable" is a protocol
		case Operand(Double)
		case UnaryOperation(String, Double -> Double)
		case BinaryOperation(String, (Double, Double) -> Double)
		case Constant(String, Double)
		
		// "Computed" property
		var description: String {
			get {
				switch self {
				case .Operand(let operand):
					return "\(operand)"
				case .UnaryOperation(let unaryOperator, _):
					return unaryOperator
				case .BinaryOperation(let binaryOperator, _):
					return binaryOperator
				case .Constant(let symbol, _):
					return symbol
				}
			}
		}
	}
	
	private var opStack = [Op]() // Array<Op>
	private var knownOps = [String:Op]() //Dictionary<String, Op>()
	
	init() {
		func learnOp(op:Op) {
			knownOps[op.description] = op
		}

		learnOp(Op.BinaryOperation("×", *))
		learnOp(Op.BinaryOperation("÷", {$1 / $0}))
		learnOp(Op.BinaryOperation("+", +))
		learnOp(Op.BinaryOperation("-", {$1 - $0}))
		learnOp(Op.UnaryOperation("√", sqrt))
		learnOp(Op.UnaryOperation("sin", sin))
		learnOp(Op.UnaryOperation("cos", cos))
		learnOp(Op.Constant("π", M_PI))
		
		println(knownOps.description)
	}
	
	func clear() {
		opStack = [Op]()
	}
	
	private func evaluate(ops: [Op]) -> (result: Double?, remainingStack: [Op]) {
		if !ops.isEmpty {
			var remainingStack = ops
			let op = remainingStack.removeLast()
			
			switch op {
			case .Operand(let operand):
				return (operand, remainingStack)
			case .UnaryOperation(_, let operation):
				let operandEvaluation = evaluate(remainingStack)
				if let operand = operandEvaluation.result {
					return (operation(operand), operandEvaluation.remainingStack)
				}
			case .BinaryOperation(_, let operation):
				let operand1Eval = evaluate(remainingStack)
				if let operand1 = operand1Eval.result {
					let operand2Eval = evaluate(operand1Eval.remainingStack)
					if let operand2 = operand2Eval.result {
						return (operation(operand1, operand2), operand2Eval.remainingStack)
					}
				}
			case .Constant(_, let value):
				return(value, remainingStack)
			}
		}
		
		return (nil, ops)
	}
	
	func evaluate() -> Double? {
		//return evaluate(opStack).result
		let (result, remainder) = evaluate(opStack)
		println("\(opStack) = \(result) with \(remainder) left over.")
		return result
	}
	
	func pushOperand(operand: Double?) -> Double? {
		if let operand = operand {
			opStack.append(Op.Operand(operand))
		}
		
		return evaluate()
	}
	
	func pushOperand(symbol: String) -> Double? {
		let op = knownOps[symbol]
		opStack.append(op!)
		return evaluate()
	}
	
	private func popOperand() -> Op {
		var last: Op = opStack.last!
		var result = last
		return result
	}
	
	// push operation onto stack
	func performOperation(symbol: String) -> Double? {
		if let operation = knownOps[symbol] { // 'optional' boolean evaluation?
			opStack.append(operation)
		}
		return evaluate()
	}
}