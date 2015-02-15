//
//  Stack.swift
//  PostfixToInfix
//
//  Created by Richard E Millet on 2/12/15.
//  Copyright (c) 2015 remillet. All rights reserved.
//

import Foundation

struct Stack<T> : Printable {
	var items = [T]()
	
	mutating func push(item: T) {
		items.append(item)
	}
	
	mutating func pop() -> T {
		return items.removeLast()
	}
	
	func peek() -> T? {
		return items.last
	}
	
	func isEmpty() -> Bool {
		return items.isEmpty
	}
	
	var description: String {
		get {
			var result = ""
			for token in items {
				result += "\(token)" + ", "
			}
			result = result[result.startIndex..<result.endIndex.predecessor().predecessor()]
			return "[\(result)]"
		}
	}
}