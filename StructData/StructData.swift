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
}

/**
We need the _Structured protocol as a way to decode NSManagedStruct instances in NSManagedStructs.
We can't use NSManagedStruct for this, as it has a self requirement

FIXME: Use protocol composition for this...
typealias comm = protocol<_Structured, Equatable>

*/
public extension _Structured {
    var EntityName: String { return "" }
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

// Pull optional array from JSON
//public func <||? <A where A: Decodable, A == A.DecodedType>(json: JSON, key: String) -> Decoded<[A]?> {
//    return .optional(json <|| [key])
//}


extension NSManagedObject: Structured {
    public static func unbox(value: AnyObject) -> Unboxed<NSManagedObject> {
        return Unboxed.Success(value as! NSManagedObject)
    }
}

// <T:NSManagedStruct where T.StructureType==T>
/*extension Array: Structured {
    //typealias StructureType = [T]
    // <T:Structured where T.StructureType==T>
    public static func unbox<T:Structured where T.StructureType==T>(value: AnyObject) -> Unboxed<T.StructureType> {
        switch value {
        case let v as NSOrderedSet:
            return Unboxed.Success([T.unbox(v.firstObject!).value!])
//            return Unboxed.Success(v.map({ (e) -> T in
//            return T.unbox(e)
//        }))
        default: return Unboxed.TypeMismatch("Array")
        }
    }
}*/

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
//            return Unboxed.Success(v.map({ (e) -> T in
//            return T.unbox(e)
//        }))
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

/*
public func toCoreData(context: NSManagedObjectContext)(entity: [_Structured]) throws -> NSOrderedSet {
    let s = NSMutableOrderedSet()
    for n in entity {
        do {
            try s.addObject(toCoreData(context)(entity: n))
        } catch _ {
            continue
        }
    }
    
    return s.copy() as! NSOrderedSet
}

//public func toCoreData(context: NSManagedObjectContext)(entity: Set<_Structured>) throws -> NSSet {
//}

public func ddd<T: Any where T:_Structured>(input: [T]) -> NSOrderedSet {
    return NSOrderedSet()
}
*/

public func toCoreData(context: NSManagedObjectContext)(entity: _Structured) throws -> NSManagedObject {
    
    let mirror = Mirror(reflecting: entity)
    
    if let style = mirror.displayStyle where style == .Struct {
        
        // try to create an entity
        let desc = NSEntityDescription.entityForName(entity.EntityName, inManagedObjectContext:context)
        guard let _ = desc else {
            fatalError("Entity \(entity.EntityName) not found in Core Data Model")
        }
        
        let result = NSManagedObject(entity: desc!, insertIntoManagedObjectContext: nil)
        
        for (labelMaybe, valueMaybe) in mirror.children {
            
            guard let label = labelMaybe else {
                continue
            }
            
            if ["EntityName"].contains(label) {
                continue
            }
            
            if valueMaybe is Array<AnyObject> {
                print("it is a struc")
            }
//            print(valueMaybe)
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
            case let k as _Structured:
                try result.setValue(toCoreData(context)(entity: k), forKey: label)
            case let k as Array<Any>:
                print("is an array")
//                try result.setValue(toCoreData(context)(entity: k), forKey: label)
            default:
                // Test the type in more detail, for optionals, arrays, sets
                // This is a bit cumbersome as it is tricky to pattern match for Any?
                let mi:MirrorType = reflect(valueMaybe)
//                print(mi)
                if mi.disposition == .IndexContainer {
//                    let kx = valueMaybe as! [_Structured]
//                    print("is in disposition yeah", kx)
//                    ddd(valueMaybe)
                }
                // IMPORTANT, PUT THIS BACK IN!
//                if mi.disposition != .Optional {
//                    // If we're here, and this is not an optional, we're done
//                    throw NSManagedStructError.StructValueError(message: "Could not decode value for field '\(label)' obj \(valueMaybe)")
//                }
                // TILL HERE!
                if mi.count == 0 {
                     // Optional.None
                    result.setValue(nil, forKey: label)
                } else {
                    let (_,some) = mi[0]
                    switch some.value {
                    case let k as AnyObject:
                        result.setValue(k, forKey: label)
                    case let k as _Structured:
                        var bcde: [NSManagedObject] = []
                        for c in 0..<mi.count {
                            let (_,xsome) = mi[c]
                            print("xsome is", xsome)
                            if let xxx = xsome.value as? _Structured {
                                do {
                                    let uxx = try toCoreData(context)(entity: xxx)
                                    bcde.append(uxx)
                                } catch NSManagedStructError.StructConversionError(let msg) {
                                    print (msg)
                                } catch NSManagedStructError.StructValueError(let msg) {
                                    print (msg)
                                } catch let e {
                                    print(e)
                                }
                            }
                        }
                        if bcde.count > 0 {
                            let uxxxx = NSOrderedSet(array: bcde)
                            print("is in array in", uxxxx)
                            print("result is", result)
                            let uuu = result.mutableOrderedSetValueForKey(label)
                            uuu.addObjectsFromArray(bcde)
//                            if let rxr = result as NSManagedObject {
//                                
//                                result.setValue(uxxxx, forKey: label)
//                            }
                        }
                    default:
                        print("argh", some.value)
                        throw NSManagedStructError.StructValueError(message: "Could not ddddecode value for field '\(label)' obj \(valueMaybe)")
                    }
                }
                // FIXME: Support for Transformable, by checking serialization protocols?
            }
            
        }
        
        return result
    }
    
    throw NSManagedStructError.StructConversionError(message: "Object is no struct")
}