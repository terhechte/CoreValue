//
//  StructData.swift
//  StructData
//
//  Created by Benedikt Terhechte on 05/07/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

import Foundation
import CoreData

infix operator <^> { associativity left precedence 130 }
infix operator <*> { associativity left precedence 130 }
infix operator >>- { associativity left precedence 100 }
infix operator -<< { associativity right precedence 100 }

public protocol NSManagedStruct {
    
    typealias StructureType = Self
    
    var EntityName: String {get}
    
    //static func fromObject(object: NSManagedObject)
    static func fromObject(o: NSManagedObject) -> Unboxed<StructureType>
}

/* Decoding */

public enum Unboxed<T> {
    case Success(T)
    case TypeMismatch(String)
    
    public var value: T? {
        switch self {
        case let .Success(value): return value
        default: return .None
        }
    }
}

public extension Unboxed {
    func map<U>(f: T -> U) -> Unboxed<U> {
        switch self {
        case let .Success(value): return .Success(f(value))
        case let .TypeMismatch(string): return .TypeMismatch(string)
        }
    }
    
    func apply<U>(f: Unboxed<T -> U>) -> Unboxed<U> {
        switch f {
        case let .Success(value): return value <^> self
        case let .TypeMismatch(string): return .TypeMismatch(string)
        }
    }
    
    func flatMap<U>(f: T -> Unboxed<U>) -> Unboxed<U> {
        switch self {
        case let .Success(value): return f(value)
        case let .TypeMismatch(string): return .TypeMismatch(string)
        }
    }
}

public func pure<A>(a: A) -> Unboxed<A> {
    return .Success(a)
}

// MARK: Monadic Operators

public func >>- <A, B>(a: Unboxed<A>, f: A -> Unboxed<B>) -> Unboxed<B> {
    return a.flatMap(f)
}

public func <^> <A, B>(f: A -> B, a: Unboxed<A>) -> Unboxed<B> {
    return a.map(f)
}

public func <*> <A, B>(f: Unboxed<A -> B>, a: Unboxed<A>) -> Unboxed<B> {
    return a.apply(f)
}

public protocol Structured {
    typealias StructureType = Self
    static func unbox(value: AnyObject) -> Unboxed<StructureType>
}

// pull value from nsmanagedobject
infix operator <| { associativity left precedence 150 }
infix operator <|? { associativity left precedence 150 }

public func <| <A where A: Structured, A == A.StructureType>(value: NSManagedObject, key: String) -> Unboxed<A> {
    if let s = value.valueForKey(key) {
        return A.unbox(s)
    }
    return Unboxed.TypeMismatch("\(key) \(A.self)")
}

public func <|? <A where A: Structured, A == A.StructureType>(value: NSManagedObject, key: String) -> Unboxed<A?> {
    if let s = value.valueForKey(key) {
            return Unboxed<A?>.Success(A.unbox(s).value)
    }
    return Unboxed<A?>.Success(nil)
}




extension NSManagedObject: Structured {
    public static func unbox(value: AnyObject) -> Unboxed<NSManagedObject> {
        return Unboxed.Success(value as! NSManagedObject)
    }
}

extension Int: Structured {
    public static func unbox(value: AnyObject) -> Unboxed<Int> {
        switch value {
        case let v as NSNumber: return Unboxed.Success(v.integerValue)
        default: return Unboxed.TypeMismatch("Int")
        }
    }
}

extension Int16: Structured {
    public static func unbox(value: AnyObject) -> Unboxed<Int16> {
        switch value {
        case let v as NSNumber: return Unboxed.Success(Int16(v.intValue))
        default: return Unboxed.TypeMismatch("Int16")
        }
    }
}

extension String: Structured {
    public static func unbox(value: AnyObject) -> Unboxed<String> {
        switch value {
        case let v as String: return Unboxed.Success(v)
        default: return Unboxed.TypeMismatch("String")
        }
    }
}


/* Encoding */

public enum NSManagedStructError : ErrorType {
    case StructConversionError(message: String)
    case StructValueError(message: String)
}

public func toCoreData<T: NSManagedStruct>(context: NSManagedObjectContext)(entity: T) throws -> NSManagedObject {
    
    let mirror = Mirror(reflecting: entity)
    
    if let style = mirror.displayStyle where style == .Struct {
        
        // try to create an entity
        let desc = NSEntityDescription.entityForName(entity.EntityName, inManagedObjectContext:context)
        let result = NSManagedObject(entity: desc!, insertIntoManagedObjectContext: nil)
        
        for (labelMaybe, valueMaybe) in mirror.children {
            
            guard let label = labelMaybe else {
                continue
            }
            
            if ["EntityName"].contains(label) {
                continue
            }
            
            // FIXME: Try to support more types
            switch valueMaybe {
            case let k as Int16:
                result.setValue(NSNumber(short: k), forKey: label)
            case let k as Int32:
                result.setValue(NSNumber(int: k), forKey: label)
            case let k as Int64:
                result.setValue(NSNumber(longLong: k), forKey: label)
            case let k as Double:
                result.setValue(NSNumber(double: k), forKey: label)
            case let k as Float:
                result.setValue(NSNumber(float: k), forKey: label)
            case let k as Boolean:
                result.setValue(NSNumber(unsignedChar: k), forKey: label)
            case let k as AnyObject:
                result.setValue(k, forKey: label)
            default:
                // Test for an optional value
                // This is a bit cumbersome as it is tryick to pattern match for Any?
                let mi:MirrorType = reflect(valueMaybe)
                if mi.disposition != .Optional {
                    // If we're here, and this is not an optional, we're done
                    throw NSManagedStructError.StructValueError(message: "Could not decode value for field '\(label)' obj \(valueMaybe)")
                }
                if mi.count == 0 {
                     // Optional.None
                    result.setValue(nil, forKey: label)
                } else {
                    let (_,some) = mi[0]
                    switch some.value {
                    case let k as AnyObject:
                        result.setValue(k, forKey: label)
                    default:
                        throw NSManagedStructError.StructValueError(message: "Could not decode value for field '\(label)' obj \(valueMaybe)")
                    }
                }
                // FIXME: Support for Transformable, by checking serialization protocols?
            }
            
        }
        
        return result
    }
    
    throw NSManagedStructError.StructConversionError(message: "Object is no struct")
}