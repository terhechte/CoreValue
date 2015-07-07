//
//  StructData.swift
//  StructData
//
//  Created by Benedikt Terhechte on 05/07/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

import Foundation
import CoreData

public protocol NSManagedStruct {
    
    var EntityName: String {get}
    
//    init(object: NSManagedObject)
}

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
                // FIXME: Support for Transformable, by checking serialization protocols?
                throw NSManagedStructError.StructValueError(message: "Could not decode value for field '\(label)'")
            }
            
        }
        
        return result
    }
    
    throw NSManagedStructError.StructConversionError(message: "Object is no struct")
}