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
}

// MARK: Monadic Operators

public func <^> <A, B>(f: A -> B, a: Unboxed<A>) -> Unboxed<B> {
    return a.map(f)
}

public func <*> <A, B>(f: Unboxed<A -> B>, a: Unboxed<A>) -> Unboxed<B> {
    return a.apply(f)
}

public protocol _Structured {
    var EntityName: String {get}
    // Boxing can throw, as there may be no way to construct an NSObject representation of a struct type
    func box(object: NSManagedObject, withKey: String) throws
}

/**
We need the _Structured protocol as a way to decode NSManagedStruct instances in NSManagedStructs.
We can't use NSManagedStruct for this, as it has a self requirement

FIXME: Use protocol composition for this...
typealias comm = protocol<_Structured, Equatable>

*/
public extension _Structured {
    var EntityName: String { return "" }
    func box(object: NSManagedObject, withKey: String) throws {
        if let ctx = object.managedObjectContext {
                try object.setValue(toCoreData(ctx)(entity: self), forKey: withKey)
        }
    }
}


/**
This abonimation exists so that the user only has to conform to one protocol in order to support
structdata. The code here would be a tad cleaner if we'd require the user to conform to two
protocols, however one of them would be empty, so I suppose it's for the better to do it this way
FIXME: Think about this some more and try to find a way to do this without this weird protocol
setup and extension mess
*/
public protocol Structured : _Structured {
    typealias StructureType = Self
    static func unbox(value: AnyObject) -> Unboxed<StructureType>
}

public protocol NSManagedStruct : Structured {
    static func fromObject(object: NSManagedObject) -> Unboxed<Self>
}

extension NSManagedStruct {
    static func unbox<A: NSManagedStruct where A==A.StructureType>(value: AnyObject) -> Unboxed<A> {
        if let v = value as? NSManagedObject {
            return A.fromObject(v)
        }
        return Unboxed.TypeMismatch("\(value) is not NSManagedObject")
    }
}

// pull value from nsmanagedobject
infix operator <| { associativity left precedence 150 }
infix operator <|| { associativity left precedence 150 }
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

public func <|| <A where A: Structured, A == A.StructureType>(value: NSManagedObject, key: String) -> Unboxed<[A]> {
    if let s = value.valueForKey(key) {
        return Array.unbox(s)
    }
    return Unboxed.TypeMismatch("\(key) \(A.self)")
}

extension NSManagedObject: Structured {
    public static func unbox(value: AnyObject) -> Unboxed<NSManagedObject> {
        return Unboxed.Success(value as! NSManagedObject)
    }
    public func box(object: NSManagedObject, withKey: String) throws {
        object.setValue(self, forKey: withKey)
    }
}

/*
all other approaches (see above) are impossible (i.e. strict protocol conformance via :Structured
because there is no way to satisfy the typechecker that
public static func unbox(value: AnyObject) -> Unboxed<StructureType>
is the same as
public static func unbox(value: AnyObject) -> Unboxed<[StructureType]>
the only way that seemed plausible to me was
typealias StructureType = [T]
public static func unbox(value: AnyObject) -> Unboxed<StructureType>
but that crashes the compiler
*/

extension Array where T: Structured, T == T.StructureType {
    public static func unbox(value: AnyObject) -> Unboxed<[T]> {
        switch value {
        case let v as NSOrderedSet:
            return Unboxed.Success([T.unbox(v.firstObject!).value!])
        default: return Unboxed.TypeMismatch("Array")
        }
    }
}

extension Int: Structured {
    public static func unbox(value: AnyObject) -> Unboxed<Int> {
        switch value {
        case let v as NSNumber: return Unboxed.Success(v.integerValue)
        default: return Unboxed.TypeMismatch("Int")
        }
    }
    public func box(object: NSManagedObject, withKey: String) throws {
        object.setValue(NSNumber(integer: self), forKey: withKey)
    }
}

extension Int16: Structured {
    public static func unbox(value: AnyObject) -> Unboxed<Int16> {
        switch value {
        case let v as NSNumber: return Unboxed.Success(Int16(v.intValue))
        default: return Unboxed.TypeMismatch("Int16")
        }
    }
    public func box(object: NSManagedObject, withKey: String) throws {
        object.setValue(NSNumber(short: self), forKey: withKey)
    }
}

extension String: Structured {
    public static func unbox(value: AnyObject) -> Unboxed<String> {
        switch value {
        case let v as String: return Unboxed.Success(v)
        default: return Unboxed.TypeMismatch("String")
        }
    }
    public func box(object: NSManagedObject, withKey: String) throws {
        object.setValue(self, forKey: withKey)
    }
}

// FIXME: Int32, Int64, Double, Float, Boolean, NSDate, NSData, NSValue
/*
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
*/

/* Encoding */

public enum NSManagedStructError : ErrorType {
    case StructConversionError(message: String)
    case StructValueError(message: String)
}

public func toCoreData(context: NSManagedObjectContext)(entity: _Structured) throws -> NSManagedObject {
    
    let mirror = Mirror(reflecting: entity)
    
    if let style = mirror.displayStyle where style == .Struct {
        
        // FIXME: only create an entity, if it doesn't exist yet, otherwise update it
        
        // try to create an entity
        let desc = NSEntityDescription.entityForName(entity.EntityName, inManagedObjectContext:context)
        guard let _ = desc else {
            fatalError("Entity \(entity.EntityName) not found in Core Data Model")
        }
        
        let result = NSManagedObject(entity: desc!, insertIntoManagedObjectContext: context)
        
        for (labelMaybe, valueMaybe) in mirror.children {
            
            guard let label = labelMaybe else {
                continue
            }
            
            if ["EntityName"].contains(label) {
                continue
            }
            
            // FIXME: This still looks awful. Need to spend more time cleaning this up
            if let value = valueMaybe as? _Structured {
                try value.box(result, withKey: label)
            } else {
                let valueMirror:MirrorType = reflect(valueMaybe)
                if valueMirror.count == 0 {
                    result.setValue(nil, forKey: label)
                } else {
                    // Since MirrorType has no typealias for it's children, we have to 
                    // unpack the first one in order to identify them
                    switch (valueMirror.count, valueMirror.disposition, valueMirror[0]) {
                    case (_, .Optional, (_, let some)) where some.value is AnyObject:
                        result.setValue(some.value as? AnyObject, forKey: label)
                    case (_, .IndexContainer, (_, let some)) where some.value is _Structured:
                        // Since valueMirror isn't an array type, we can't map over it or even properly extend it
                        var objects: [NSManagedObject] = []
                        for c in 0..<valueMirror.count {
                            if let value = valueMirror[c].1.value as? _Structured {
                                objects.append(try toCoreData(context)(entity: value))
                            }
                        }
                        
                        if objects.count > 0 {
                            let mutableValue = result.mutableOrderedSetValueForKey(label)
                            mutableValue.addObjectsFromArray(objects)
                        }
                        
                    default:
                        // If we end up here, we were unable to decode it
                        throw NSManagedStructError.StructValueError(message: "Could not decode value for field '\(label)' obj \(valueMaybe)")
                    }
                }
            }
            
        }
        
        return result
    }
    throw NSManagedStructError.StructConversionError(message: "Object is no struct")
}



