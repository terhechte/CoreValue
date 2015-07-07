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
    var position: String
    var department: String
    var job: String
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
    
    var context: NSManagedObjectContext?
    
    override func setUp() {
        super.setUp()
        if let c = setUpInMemoryManagedObjectContext(StructDataMacTests) {
            self.context = c
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testToCoreData() {
        if let ctx = self.context {
            let emp = Employee(name: "klaus", age: 20, position: "Manager", department: "Blumen", job: "Lustiger")
            do {
                let cd = try toCoreData(ctx)(entity: emp)
                if (cd.valueForKey("name") as! String) != emp.name {
                    XCTAssert(false, "Conversion failed: name")
                }
                if (cd.valueForKey("age") as! NSNumber).integerValue != Int(emp.age) {
                    XCTAssert(false, "Conversion failed: age")
                }
            } catch _ {
            XCTAssert(false, "Conversion failed")
            }
        } else {
            XCTAssert(false, "Could not create context")
        }
    }
    
}
