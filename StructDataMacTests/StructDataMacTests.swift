//
//  StructDataMacTests.swift
//  StructDataMacTests
//
//  Created by Benedikt Terhechte on 05/07/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

import XCTest


struct Employee : NSManagedStruct {
    
    let EntityName = "Employee"
    
    var name: String
    var age: Int16
    var position: String?
    var department: String
    var job: String
    
    // FIXME: Relationship support
    static func fromObject(o: NSManagedObject) -> Unboxed<Employee> {
        let x = curry(self.init) <^> o <| "name"
        <*> o <| "age"
        <*> o <|? "position"
        <*> o <| "department"
        <*> o <| "job"
        return x
    }
}

func setUpInMemoryManagedObjectContext(cls: AnyClass) -> NSManagedObjectContext? {
    let b = NSBundle(forClass: cls)
    //let modelURL = NSBundle.mainBundle().URLForResource("StructDataMacTests", withExtension: "momd")!
    let modelURL = b.URLForResource("StructDataMacTests", withExtension: "mom")!
    let managedObjectModel = NSManagedObjectModel(contentsOfURL: modelURL)!
    
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    do {
        try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    } catch _ {
        return nil
    }
    
    let managedObjectContext = NSManagedObjectContext()
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    return managedObjectContext
}


class StructDataMacTests: XCTestCase {
    
    var context: NSManagedObjectContext = {
        return setUpInMemoryManagedObjectContext(StructDataMacTests)!
    }()
    
    let employee1 = {
        return Employee(name: "John Doe", age: 20, position: "Manager", department: "Flowers", job: "Garden Guy")
    }()
    
    let employee2 = {
        return Employee(name: "Nobody", age: 14, position: nil, department: "Kindergarten", job: "Playing")
    }()
    
    var nsEmployee1: NSManagedObject!
    
    var nsEmployee2: NSManagedObject!
    
    
    override func setUp() {
        super.setUp()
        self.nsEmployee1 = try! toCoreData(self.context)(entity: self.employee1)
        self.nsEmployee2 = try! toCoreData(self.context)(entity: self.employee2)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testToCoreDataNonNil() {
        do {
            let cd = try toCoreData(self.context)(entity: self.employee1)
            if (cd.valueForKey("name") as! String) != self.employee1.name {
                XCTAssert(false, "Conversion failed: name")
            }
            if (cd.valueForKey("age") as! NSNumber).integerValue != Int(self.employee1.age) {
                XCTAssert(false, "Conversion failed: age")
            }
        } catch NSManagedStructError.StructConversionError(let msg) {
            XCTAssert(false, msg)
        } catch NSManagedStructError.StructValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
    }
    
    func testToCoreDataNil() {
        do {
            let cd = try toCoreData(self.context)(entity: self.employee2)
            if (cd.valueForKey("name") as! String) != self.employee2.name {
                XCTAssert(false, "Conversion failed: name")
            }
            if (cd.valueForKey("age") as! NSNumber).integerValue != Int(self.employee2.age) {
                XCTAssert(false, "Conversion failed: age")
            }
            if (cd.valueForKey("position") != nil) {
                XCTAssert(false, "Conversion failed: age")
            }
        } catch NSManagedStructError.StructConversionError(let msg) {
            XCTAssert(false, msg)
        } catch NSManagedStructError.StructValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
    }
    
    func testFromCoreDataNonNil() {
        switch Employee.fromObject(self.nsEmployee1) {
        case .Success(let t):
            if t.name != self.employee1.name ||
               t.age != self.employee1.age {
                XCTAssert(false, "Conversion Error")
            }
        case .TypeMismatch(let msg):
            XCTAssert(false, msg)
        }
    }
    
    func testFromCoreDataNil() {
        switch Employee.fromObject(self.nsEmployee2) {
        case .Success(let t):
            if t.name != self.employee2.name ||
               t.age != self.employee2.age ||
               t.position != nil {
                XCTAssert(false, "Conversion Error")
            }
        case .TypeMismatch(let msg):
            XCTAssert(false, msg)
        }
    }
    
}
