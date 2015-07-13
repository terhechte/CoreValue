//
//  CoreValueMacTests.swift
//  CoreValueMacTests
//
//  Created by Benedikt Terhechte on 05/07/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

import XCTest
import CoreData

struct Employee : NSManagedStruct {
    
    static let EntityName = "Employee"
    
    let name: String
    let age: Int16
    let position: String?
    let department: String
    let job: String
    
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
    static let EntityName = "Shop"
    
    var name: String
    var owner: Employee
    
    static func fromObject(o: NSManagedObject) -> Unboxed<Shop> {
        return curry(self.init)
            <^> o <| "name"
            <*> o <| "owner"
    }
}

struct Company: NSManagedStruct {
    static let EntityName = "Company"
    
    var name: String
    var employees: Array<Employee>
    
    static func fromObject(o: NSManagedObject) -> Unboxed<Company> {
        return curry(self.init)
        <^> o <| "name"
        <*> o <|| "employees"
    }
}

struct Other: NSManagedStruct {
    static let EntityName = "Other"
    
    var boolean: Bool
    var data: NSData
    var date: NSDate
    var decimal: NSDecimalNumber
    var double: Double
    var float: Float
    
    static func fromObject(o: NSManagedObject) -> Unboxed<Other> {
        return curry(self.init)
        <^> o <| "boolean"
        <*> o <| "data"
        <*> o <| "date"
        <*> o <| "decimal"
        <*> o <| "double"
        <*> o <| "float"
    }
}

struct StoredShop: NSManagedPersistentStruct {
    static let EntityName = "Shop"
    
    var objectID: NSManagedObjectID?
    var name: String
    var owner: Employee
    
    static func fromObject(o: NSManagedObject) -> Unboxed<StoredShop> {
        return curry(self.init)
            <^> o <|? "objectID"
            <*> o <| "name"
            <*> o <| "owner"
    }
}

func setUpInMemoryManagedObjectContext(cls: AnyClass) -> NSManagedObjectContext? {
    let b = NSBundle(forClass: cls)
    let modelURL = b.URLForResource("CoreValueTests", withExtension: "mom")!
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


class CoreValueMacTests: XCTestCase {
    
    var context: NSManagedObjectContext = {
        return setUpInMemoryManagedObjectContext(CoreValueMacTests)!
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
    
    let other = {
        return Other(boolean: true, data: NSData(), date: NSDate(), decimal: NSDecimalNumber(), double: 10, float: 20)
    }()
    
    var nsOther: NSManagedObject!
    
    override func setUp() {
        super.setUp()
        do {
            self.nsEmployee1 = try self.employee1.toObject(self.context)
        }catch NSManagedStructError.StructConversionError(let msg) {
            XCTAssert(false, msg)
        } catch NSManagedStructError.StructValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
        
        self.nsEmployee2 = try! self.employee2.toObject(self.context)
        do {
            self.nsShop = try self.shop.toObject(self.context)
        } catch NSManagedStructError.StructConversionError(let msg) {
            XCTAssert(false, msg)
        } catch NSManagedStructError.StructValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
        
        do {
            self.nsCompany = try self.company.toObject(self.context)
        } catch NSManagedStructError.StructConversionError(let msg) {
            XCTAssert(false, msg)
        } catch NSManagedStructError.StructValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
        
        do {
            self.nsOther = try self.other.toObject(self.context)
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
            let cd = try self.employee1.toObject(self.context)
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
            let cd = try self.employee2.toObject(self.context)
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
            let cd = try self.shop.toObject(self.context)
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
            let cd = try self.company.toObject(self.context)
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
    
    func testOtherDataTypesToCoreData() {
        do {
            let cd = try self.other.toObject(self.context)
            
            if (cd.valueForKey("boolean") as! NSNumber).boolValue != self.other.boolean {
                XCTAssert(false, "Conversion failed: boolean")
            }
            
            guard cd.valueForKey("data") is NSData else {
                XCTAssert(false, "Conversion failed: nsdata")
                return
            }
            
            guard cd.valueForKey("date") is NSDate else {
                XCTAssert(false, "Conversion failed: nsdate")
                return
            }
            
            guard cd.valueForKey("decimal") is NSDecimalNumber else {
                XCTAssert(false, "Conversion failed: decimal")
                return
            }
            
            guard cd.valueForKey("double") is NSNumber else {
                XCTAssert(false, "Conversion failed: double")
                return
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
}


class CoreValueQueryTests: XCTestCase {
    
    var context: NSManagedObjectContext = {
        return setUpInMemoryManagedObjectContext(CoreValueMacTests)!
    }()
    
    var manyEmployees: [NSManagedObject] = []
    
    override func setUp() {
        super.setUp()
        for n in 0..<50 {
            let employee = Employee(name: "employee \(n)", age: n + 10, position: nil, department: "", job: "")
            do {
                manyEmployees.append(try employee.toObject(self.context))
            } catch let e {
                print(e)
                XCTAssert(false, "An Error Occured")
            }
        }
    }
    
    func testQueryYoungOnes() {
        let predicate = NSPredicate(format: "age > 10 and age < 12", argumentArray: nil)
        // Important, the results: [Employee] is required for the type checker to figure things out
        let results: [Employee] = Employee.query(self.context, predicate: predicate)
        if results.count != 1 {
            XCTAssert(false, "Wrong amount for you ones \(results.count)")
        }
    }
    
    func testQueryOldOnes() {
        let predicate = NSPredicate(format: "age > 50", argumentArray: nil)
        // Important, the results: [Employee] is required for the type checker to figure things out
        let results: [Employee] = Employee.query(self.context, predicate: predicate)
        if results.count != 9 {
            XCTAssert(false, "Wrong amount for old ones \(results.count)")
        }
    }
    
    func testQueryOrder() {
        // Important, the results: [Employee] is required for the type checker to figure things out
        let descriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "age", ascending: false)]
        let results: [Employee] = Employee.query(self.context, predicate: nil, sortDescriptors: descriptors)
        if let r = results.first {
            if r.age != 59 {
                XCTAssert(false, "wrong employee age: \(r.age)")
            }
        } else {
            XCTAssert(false, "Wrong query amount result: 0")
        }
    }
    
    func testStorage() {
        // test whether storing / updating works properly
        
        // create two shops
        var s1 = StoredShop(objectID: nil, name: "shop1", owner: Employee(name: "a", age: 4, position: nil, department: "", job: ""))
        do {
            try s1.mutatingToObject(self.context)
        } catch let e {
            XCTAssert(false, "\(e)")
        }
        
        var s2 = StoredShop(objectID: nil, name: "shop2", owner: Employee(name: "a", age: 4, position: nil, department: "", job: ""))
        do {
            try s2.mutatingToObject(self.context)
        } catch let e {
            XCTAssert(false, "\(e)")
        }
        
        // now update both shops
        do {
            try s1.mutatingToObject(self.context)
        } catch let e {
            XCTAssert(false, "\(e)")
        }
        
        do {
            try s2.mutatingToObject(self.context)
        } catch let e {
            XCTAssert(false, "\(e)")
        }
        
        // And query the count
        let predicate = NSPredicate(format: "self.name=='shop1'", argumentArray: [])
        let results: [StoredShop] = StoredShop.query(self.context, predicate: predicate)
        XCTAssert(results.count == 1, "Wrong amount of objects, update did insert: \(results.count)")
    }
    
    func testDeletion() {
        // create two shops
        var s1 = StoredShop(objectID: nil, name: "shop1", owner: Employee(name: "a", age: 4, position: nil, department: "", job: ""))
        do {
            try s1.save(self.context)
        } catch let e {
            XCTAssert(false, "\(e)")
        }
        
        var s2 = StoredShop(objectID: nil, name: "shop2", owner: Employee(name: "a", age: 4, position: nil, department: "", job: ""))
        do {
            try s2.save(self.context)
        } catch let e {
            XCTAssert(false, "\(e)")
        }
        
        // delete one
        do {
            try s2.delete(self.context)
        } catch let error {
            XCTAssert(false, "Deletion Failed: \(error)")
        }
        
        // and count
        let results: [StoredShop] = StoredShop.query(self.context, predicate: nil)
        XCTAssert(results.count == 1, "Failed to delete object \(s2) from context")
    }
}