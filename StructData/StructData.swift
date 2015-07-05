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
}

public enum NSManagedStructError : ErrorType {
    case StructConversionError()
}
public func toCoreData(context: NSManagedObjectContext)(entity: NSManagedStruct) throws -> NSManagedObject {
    
    let mirror = Mirror(reflecting: entity)
    
    if let style = mirror.displayStyle where style == .Struct || style == .Class {
        
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
            
            switch valueMaybe {
            case let k as Int16:
                result.setValue(NSNumber(short: k), forKey: label)
            case let k as AnyObject:
                result.setValue(k, forKey: label)
            default:
                continue
            }
            
        }
        
        return result
    }
    
    throw NSManagedStructError.StructConversionError()
}