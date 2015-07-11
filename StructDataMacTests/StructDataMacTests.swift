//
//  StructDataMacTests.swift
//  StructDataMacTests
//
//  Created by Benedikt Terhechte on 05/07/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

import XCTest

struct Employee : NSManagedStruct { //, Structured
    
    let EntityName = "Employee"
    
    var name: String
    var age: Int16
    var position: String?
    var department: String
    var job: String
    
    // FIXME: Relationship support
    static func fromObject(o: NSManagedObject) -> Unboxed<Employee> {
        return curry(self.init)
            <^> o <| "name"
            <*> o <| "age"
            <*> o <|? "position"
            <*> o <| "department"
            <*> o <| "job"
    }
}

struct Shop: NSManagedStruct {
    let EntityName = "Shop"
    
    var name: String
    var owner: Employee
    
    static func fromObject(o: NSManagedObject) -> Unboxed<Shop> {
        return curry(self.init)
            <^> o <| "name"
            <*> o <| "owner"
    }
}

struct Company: NSManagedStruct {
    let EntityName = "Company"
    
    var name: String
    var employees: Array<Employee>
    
    static func fromObject(o: NSManagedObject) -> Unboxed<Company> {
        return curry(self.init)
        <^> o <| "name"
        <*> o <|| "employees"
    }
}

func setUpInMemoryManagedObjectContext(cls: AnyClass) -> NSManagedObjectContext? {
    let b = NSBundle(forClass: cls)
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
    
    let shop = {
        return Shop(name: "Carl's Household Items", owner: Employee(name: "Carl", age: 66, position: nil, department: "Register", job: "Owner"))
    }()
    
    var nsShop: NSManagedObject!
    
    let company = {
        return Company(name: "Household Wares Inc.", employees: [Employee(name: "Chris High", age: 23, position: nil, department: "Factory", job: "Worker"), Employee(name: "Ben Down", age: 32, position: nil, department: "Factory", job: "Cleaner")])
    }()
    
    var nsCompany: NSManagedObject!
    
    override func setUp() {
        super.setUp()
        do {
            self.nsEmployee1 = try toCoreData(self.context)(entity: self.employee1)
        }catch NSManagedStructError.StructConversionError(let msg) {
            XCTAssert(false, msg)
        } catch NSManagedStructError.StructValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
        
        self.nsEmployee2 = try! toCoreData(self.context)(entity: self.employee2)
        do {
            self.nsShop = try toCoreData(self.context)(entity: self.shop)
        } catch NSManagedStructError.StructConversionError(let msg) {
            XCTAssert(false, msg)
        } catch NSManagedStructError.StructValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
        
        do {
            self.nsCompany = try toCoreData(self.context)(entity: self.company)
        } catch NSManagedStructError.StructConversionError(let msg) {
            XCTAssert(false, msg)
        } catch NSManagedStructError.StructValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
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
    
    func testToCoreDataSub() {
        do {
            let cd = try toCoreData(self.context)(entity: self.shop)
            if (cd.valueForKey("name") as! String) != self.shop.name {
                XCTAssert(false, "Conversion failed: name")
            }
            if ((cd.valueForKey("owner")?.valueForKey("name") as! String) != self.shop.owner.name) {
                XCTAssert(false, "Conversion failed: owner's name")
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
    
    func testFromCoreDataSub() {
        switch Shop.fromObject(self.nsShop) {
        case .Success(let t):
            if t.name != self.shop.name ||
                t.owner.name != self.shop.owner.name {
                    XCTAssert(false, "Conversion Error")
            }
        case .TypeMismatch(let msg):
            XCTAssert(false, msg)
        }
    }
    
    func testToCoreDataSubArray() {
        do {
            let cd = try toCoreData(self.context)(entity: self.company)
            if (cd.valueForKey("name") as! String) != self.company.name {
                XCTAssert(false, "Conversion failed: name")
            }
            if ((cd.valueForKey("employees")?.firstObject?!.valueForKey("name") as! String) != self.company.employees[0].name) {
                XCTAssert(false, "Conversion failed: employee's name")
            }
            if ((cd.valueForKey("employees")?.lastObject?!.valueForKey("name") as! String) != self.company.employees.last?.name) {
                XCTAssert(false, "Conversion failed: employee's order")
            }
            if let ab:NSOrderedSet = cd.valueForKey("employees") as? NSOrderedSet {
                if ab.count != self.company.employees.count {
                    XCTAssert(false, "Did not box all employees")
                }
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
    
    func testFromCoreDataSubArray() {
        switch Company.fromObject(self.nsCompany) {
        case .Success(let t):
            if t.name != self.company.name ||
                t.employees[0].name != self.company.employees[0].name {
                    XCTAssert(false, "Conversion Error")
            }
            if t.employees.count != self.company.employees.count {
                XCTAssert(false, "Wrong amount of employees")
            }
            if t.employees.last?.name != self.company.employees.last?.name {
                XCTAssert(false, "Wrong Employee order")
            }
        case .TypeMismatch(let msg):
            XCTAssert(false, msg)
        }
    }
    
}
