//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Richard E Millet on 2/1/15.
//  Copyright (c) 2015 remillet. All rights reserved.
//

import Foundation

class CalculatorBrain
{
	private enum Op {
		case Operand(Double)
		case UnaryOperation(String, Double -> Double)
		case BinaryOperation(String, (Double, Double) -> Double)
		
	}
	
	private var opStack = [Op]() // Array<Op>
	private var knownOps = [String:Op]() //Dictionary<String, Op>()
	
	init() {
		knownOps["×"] = Op.BinaryOperation("×", *)
		knownOps["÷"] = Op.BinaryOperation("÷", {$1 / $0})
		knownOps["+"] = Op.BinaryOperation("+", +)
		knownOps["-"] = Op.BinaryOperation("-", {$1 - $0})
		knownOps["√"] = Op.UnaryOperation("√", sqrt)
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
			}
		}
		
		return (nil, ops)
	}
	
	func evalulate() -> Double? {
		//return evaluate(opStack).result
		let (result, remainder) = evaluate(opStack)
		return result
	}
	
	func pushOperand(operand: Double) {
		opStack.append(Op.Operand(operand))
	}
	
	private func popOperand() -> Op {
		var last: Op = opStack.last!
		var result = last
		return result
	}
	
	// push operation onto stack
	func performOperation(symbol: String) {
		if let operation = knownOps[symbol] { // 'optional' boolean evaluation?
			opStack.append(operation)
		}
	}
}