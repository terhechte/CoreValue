//
//  CoreValueMacTests.swift
//  CoreValueMacTests
//
//  Created by Benedikt Terhechte on 05/07/15.
//  Copyright © 2015 Benedikt Terhechte. All rights reserved.
//

import XCTest
import CoreData

struct SmallEmployee : CVManagedPersistentStruct{
    static let EntityName = "Employee"
    
    var objectID: NSManagedObjectID?
    let name: String
    
    static func fromObject(_ o: NSManagedObject) throws -> SmallEmployee {
        return try curry(self.init)
            <^> o <|? "objectID"
            <^> o <| "name"
    }
    
}

struct SmallShop : CVManagedPersistentStruct{
    static let EntityName = "Shop"
    
    var objectID: NSManagedObjectID?
    let name: String
    var employees: [SmallEmployee]
    
    static func fromObject(_ o: NSManagedObject) throws -> SmallShop {
        return try curry(self.init)
            <^> o <|? "objectID"
            <^> o <| "name"
            <^> o <|| "employees"
    }
}

struct Employee : CVManagedStruct {
    
    static let EntityName = "Employee"
    
    let name: String
    let age: Int16
    let position: String?
    let department: String
    let job: String
    
    static func fromObject(_ o: NSManagedObject) throws -> Employee {
        return try curry(self.init)
            <^> o <| "name"
            <^> o <| "age"
            <^> o <|? "position"
            <^> o <| "department"
            <^> o <| "job"
    }
}

struct StoredShopEmployee : CVManagedPersistentStruct {
    
    static let EntityName = "Employee"
    
    var objectID: NSManagedObjectID?
    let name: String
    let age: Int16
    let position: String?
    let department: String
    let job: String
    let shop: StoredShop?
    
    static func fromObject(_ o: NSManagedObject) throws -> StoredShopEmployee {
        return try curry(self.init)
            <^> o <|? "objectID"
            <^> o <| "name"
            <^> o <| "age"
            <^> o <|? "position"
            <^> o <| "department"
            <^> o <| "job"
            <^> o <|? "shop"
    }
}

struct Shop: CVManagedStruct {
    static let EntityName = "Shop"
    
    var name: String
    var owner: Employee
    var products: Array<Product>?
    
    static func fromObject(_ o: NSManagedObject) throws -> Shop {
        return try curry(self.init)
            <^> o <| "name"
            <^> o <| "owner"
            <^> o <|| "products"
    }
}

struct Product: CVManagedStruct {
    static let EntityName = "Product"
    
    var name: String
    var color: String
    
    static func fromObject(_ o: NSManagedObject) throws -> Product {
        return try curry(self.init)
            <^> o <| "name"
            <^> o <| "color"
    }
}

struct Company: CVManagedStruct {
    static let EntityName = "Company"
    
    var name: String
    var employees: Array<Employee>
    
    static func fromObject(_ o: NSManagedObject) throws -> Company {
        return try curry(self.init)
            <^> o <| "name"
            <^> o <|| "employees"
    }
}

struct Other: CVManagedStruct {
    static let EntityName = "Other"
    
    var boolean: Bool
    var data: Data
    var date: Date
    var decimal: NSDecimalNumber
    var double: Double
    var float: Float
    
    static func fromObject(_ o: NSManagedObject) throws -> Other {
        return try curry(self.init)
            <^> o <| "boolean"
            <^> o <| "data"
            <^> o <| "date"
            <^> o <| "decimal"
            <^> o <| "double"
            <^> o <| "float"
    }
}

struct StoredShop: CVManagedPersistentStruct {
    static let EntityName = "Shop"
    
    var objectID: NSManagedObjectID?
    var name: String
    var owner: Employee
    
    static func fromObject(_ o: NSManagedObject) throws -> StoredShop {
        return try curry(self.init)
            <^> o <|? "objectID"
            <^> o <| "name"
            <^> o <| "owner"
    }
}

struct StoredEmployeeShop: CVManagedPersistentStruct {
    static let EntityName = "Shop"
    
    var objectID: NSManagedObjectID?
    var name: String
    var employees: [StoredShopEmployee]
    
    static func fromObject(_ o: NSManagedObject) throws -> StoredEmployeeShop {
        return try curry(self.init)
            <^> o <|? "objectID"
            <^> o <| "name"
            <^> o <|| "employees"
    }
}

enum CarType:String{
    case Pickup = "pickup"
    case Sedan = "sedan"
    case Hatchback = "hatchback"
}

extension CarType: Boxing,Unboxing {}

struct Car: CVManagedPersistentStruct {
    static let EntityName = "Car"
    var objectID: NSManagedObjectID?
    var name: String
    var type: CarType
    
    static func fromObject(_ o: NSManagedObject) throws -> Car {
        return try curry(self.init)
            <^> o <|? "objectID"
            <^> o <| "name"
            <^> o <| "type"
    }
}


struct UniqueShopEmployee : CVManagedUniqueStruct {
    
    static let EntityName = "Employee"
    
    static var IdentifierName: String = "name"
    
    func IdentifierValue() -> IdentifierType {
        return self.name
    }
    
    let name: String
    let age: Int16
    let position: String?
    let department: String
    let job: String
    let shop: StoredShop?
    
    static func fromObject(_ o: NSManagedObject) throws -> UniqueShopEmployee {
        return try curry(self.init)
            <^> o <| "name"
            <^> o <| "age"
            <^> o <|? "position"
            <^> o <| "department"
            <^> o <| "job"
            <^> o <|? "shop"
    }
}

struct UniqueEmployeeShop: CVManagedUniqueStruct {
    static let EntityName = "Shop"
    
    static var IdentifierName: String = "name"
    
    func IdentifierValue() -> IdentifierType {
        return self.name
    }
    
    var name: String
    var employees: [UniqueShopEmployee]
    
    static func fromObject(_ o: NSManagedObject) throws -> UniqueEmployeeShop {
        return try curry(self.init)
            <^> o <| "name"
            <^> o <|| "employees"
    }
}



/// Attempt f, fail test if it throws
func testTry(_ f: () throws -> ()) {
    do {
        try f()
    } catch let error as NSError {
        XCTAssert(false, error.localizedDescription)
    }
}

func setUpInMemoryManagedObjectContext(_ cls: AnyClass) -> NSManagedObjectContext? {
    let b = Bundle(for: cls)
    let modelURL = b.url(forResource: "CoreValueTests", withExtension: "mom")!
    let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)!
    
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    do {
        try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    } catch _ {
        return nil
    }
    
    assert(Thread.isMainThread)
    let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    return managedObjectContext
}


class CoreValueMacTests: XCTestCase {
    
    var context: NSManagedObjectContext = {
        return setUpInMemoryManagedObjectContext(CoreValueMacTests.self)!
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
        return Shop(name: "Carl's Household Items", owner: Employee(name: "Carl", age: 66, position: nil, department: "Register", job: "Owner"), products: nil)
    }()
    
    var nsShop: NSManagedObject!
    
    let company = {
        return Company(name: "Household Wares Inc.", employees: [Employee(name: "Chris High", age: 23, position: nil, department: "Factory", job: "Worker"), Employee(name: "Ben Down", age: 32, position: nil, department: "Factory", job: "Cleaner")])
    }()
    
    var nsCompany: NSManagedObject!
    
    let other = {
        return Other(boolean: true, data: Data(), date: Date(), decimal: NSDecimalNumber(), double: 10, float: 20)
    }()
    
    var nsOther: NSManagedObject!
    
    override func setUp() {
        super.setUp()
        do {
            self.nsEmployee1 = try self.employee1.toObject(self.context)
        }catch CVManagedStructError.structConversionError(let msg) {
            XCTAssert(false, msg)
        } catch CVManagedStructError.structValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
        
        self.nsEmployee2 = try! self.employee2.toObject(self.context)
        do {
            self.nsShop = try self.shop.toObject(self.context)
        } catch CVManagedStructError.structConversionError(let msg) {
            XCTAssert(false, msg)
        } catch CVManagedStructError.structValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
        
        do {
            self.nsCompany = try self.company.toObject(self.context)
        } catch CVManagedStructError.structConversionError(let msg) {
            XCTAssert(false, msg)
        } catch CVManagedStructError.structValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
        
        do {
            self.nsOther = try self.other.toObject(self.context)
        } catch CVManagedStructError.structConversionError(let msg) {
            XCTAssert(false, msg)
        } catch CVManagedStructError.structValueError(let msg) {
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
            if (cd.value(forKey: "name") as! String) != self.employee1.name {
                XCTAssert(false, "Conversion failed: name")
            }
            if (cd.value(forKey: "age") as! NSNumber).intValue != Int(self.employee1.age) {
                XCTAssert(false, "Conversion failed: age")
            }
        } catch CVManagedStructError.structConversionError(let msg) {
            XCTAssert(false, msg)
        } catch CVManagedStructError.structValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
    }
    
    func testToCoreDataNil() {
        do {
            let cd = try self.employee2.toObject(self.context)
            if (cd.value(forKey: "name") as! String) != self.employee2.name {
                XCTAssert(false, "Conversion failed: name")
            }
            if (cd.value(forKey: "age") as! NSNumber).intValue != Int(self.employee2.age) {
                XCTAssert(false, "Conversion failed: age")
            }
            if (cd.value(forKey: "position") != nil) {
                XCTAssert(false, "Conversion failed: age")
            }
        } catch CVManagedStructError.structConversionError(let msg) {
            XCTAssert(false, msg)
        } catch CVManagedStructError.structValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
    }
    
    func testFromCoreDataNonNil() {
        testTry {
            let t = try Employee.fromObject(self.nsEmployee1)
            if t.name != self.employee1.name ||
                t.age != self.employee1.age {
                XCTAssert(false, "Conversion Error")
            }
        }
    }
    
    func testFromCoreDataNil() {
        testTry {
            let t = try Employee.fromObject(self.nsEmployee2)
            if t.name != self.employee2.name ||
                t.age != self.employee2.age ||
                t.position != nil {
                XCTAssert(false, "Conversion Error")
            }
        }
    }
    
    func testToCoreDataSub() {
        do {
            let cd = try self.shop.toObject(self.context)
            if (cd.value(forKey: "name") as! String) != self.shop.name {
                XCTAssert(false, "Conversion failed: name")
            }
            guard let owner = cd.value(forKey: "owner") as? NSManagedObject,
                let name = owner.value(forKey: "name") as? String,
                name == self.shop.owner.name else {
                    XCTAssert(false, "Conversion failed: owner's name")
                    return
            }
            //            if ((cd.value(forKey: "owner")?.value(forKey: "name") as! String) != self.shop.owner.name) {
            //
            //            }
        } catch CVManagedStructError.structConversionError(let msg) {
            XCTAssert(false, msg)
        } catch CVManagedStructError.structValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
    }
    
    func testFromCoreDataSub() {
        testTry {
            let t = try Shop.fromObject(self.nsShop)
            if t.name != self.shop.name ||
                t.owner.name != self.shop.owner.name {
                XCTAssert(false, "Conversion Error")
            }
        }
    }
    
    func testToCoreDataSubArray() {
        do {
            let cd = try self.company.toObject(self.context)
            if (cd.value(forKey: "name") as! String) != self.company.name {
                XCTAssert(false, "Conversion failed: name")
            }
            
            guard let employees = cd.value(forKey: "employees") as? NSOrderedSet,
                let firstEmployee = employees.firstObject as? NSManagedObject,
                let lastEmployee = employees.lastObject as? NSManagedObject,
                let firstName = firstEmployee.value(forKey: "name") as? String,
                let lastName = lastEmployee.value(forKey: "name") as? String,
                firstName == self.company.employees[0].name
                else {
                    XCTAssert(false, "Conversion failed: employee's name")
                    return
            }
            guard lastName == self.company.employees.last?.name else {
                XCTAssert(false, "Conversion failed: employee's order")
                return
            }
            
            
            if employees.count != self.company.employees.count {
                XCTAssert(false, "Did not box all employees")
            }
            
        } catch CVManagedStructError.structConversionError(let msg) {
            XCTAssert(false, msg)
        } catch CVManagedStructError.structValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
    }
    
    func testFromCoreDataSubArray() {
        testTry {
            let t = try Company.fromObject(self.nsCompany)
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
        }
    }
    
    func testOtherDataTypesToCoreData() {
        do {
            let cd = try self.other.toObject(self.context)
            
            if (cd.value(forKey: "boolean") as! NSNumber).boolValue != self.other.boolean {
                XCTAssert(false, "Conversion failed: boolean")
            }
            
            guard cd.value(forKey: "data") is NSData else {
                XCTAssert(false, "Conversion failed: nsdata")
                return
            }
            
            guard cd.value(forKey: "date") is NSDate else {
                XCTAssert(false, "Conversion failed: nsdate")
                return
            }
            
            guard cd.value(forKey: "decimal") is NSDecimalNumber else {
                XCTAssert(false, "Conversion failed: decimal")
                return
            }
            
            guard cd.value(forKey: "double") is NSNumber else {
                XCTAssert(false, "Conversion failed: double")
                return
            }
            
        } catch CVManagedStructError.structConversionError(let msg) {
            XCTAssert(false, msg)
        } catch CVManagedStructError.structValueError(let msg) {
            XCTAssert(false, msg)
        } catch let e {
            print(e)
            XCTAssert(false, "An Error Occured")
        }
    }
    
    func testRawRepresentableToCoreData() {
        let car1 = Car(objectID: nil, name: "Super Sedan", type: .Sedan)
        do {
            let cd = try car1.toObject(context)
            if (cd.value(forKey: "type") as! String) != CarType.Sedan.rawValue {
                XCTAssert(false, "Boxing failed: Raw Represantable String")
            }
            
            let obj:Car = try Car.unbox(cd)
            
            if (obj.type != .Sedan) {
                XCTAssert(false, "Unboxing failed: Raw Represantable String")
            }
            
        } catch let e {
            XCTAssert(false, "\(e)")
        }
    }
    
    func testOptionalCollectionToCoreData() {
        // create two shops
        let s1 = Shop(name: "shop_with_products1", owner: Employee(name: "a", age: 4, position: nil, department: "", job: ""), products: [Product(name: "Pancake", color:"golden")])
        do {
            try s1.toObject(self.context)
        } catch let e {
            XCTAssert(false, "\(e)")
        }
        
        let s2 = Shop(name: "shop_with_products2", owner: Employee(name: "a", age: 4, position: nil, department: "", job: ""), products: [Product(name: "Unicorn", color: "sparkling")])
        testTry {
            try s2.toObject(self.context)
        }
        
        // And query the count
        testTry {
            let predicate = NSPredicate(format: "self.name=='shop_with_products1'", argumentArray: [])
            let results: [Shop] = try Shop.query(self.context, predicate: predicate)
            XCTAssert(results.count == 1, "Wrong amount of objects, update did insert: \(results.count)")
            XCTAssert(results.first?.products?.count == 1, "Wrong amount of products, actual amount: \(results.first?.products?.count ?? 0)")
        }
    }
}

class CoreValueDuplicateTests: XCTestCase {
    
    var context: NSManagedObjectContext = {
        return setUpInMemoryManagedObjectContext(CoreValueMacTests.self)!
    }()
    
    
    private var countSmallEmployees : Int{
        let all : [SmallEmployee] = try! SmallEmployee.query(context, predicate: nil)
        let count = all.count
        return count
    }
    
    func save2Shops(with employee : SmallEmployee){
        var shop1 = SmallShop(objectID: nil, name: "Shop 1", employees: [employee])
        var shop2 = SmallShop(objectID: nil, name: "Shop 2", employees: [employee])
        
        try! shop1.save(context)
        try! shop2.save(context)
        
        let shops : [SmallShop] = try! SmallShop.query(context, predicate: nil)
        XCTAssertEqual(shops.count,2)
    }
    
    func test2Shops1Employee() {
        
        let originalCount = self.countSmallEmployees
        
        let employee = SmallEmployee(objectID: nil, name: "John Doe")
        
        self.save2Shops(with:employee)
        
        XCTAssertEqual(originalCount+2, self.countSmallEmployees)
    }
    
    func test2Shops1EmployeeSavingEmployeeFirst() {
        
        let originalCount = self.countSmallEmployees
        
        var employee = SmallEmployee(objectID: nil, name: "John Doe")
        try! employee.save(context)
        
        self.save2Shops(with:employee)
        
        XCTAssertEqual(originalCount+1, self.countSmallEmployees)
    }
}

class CoreValueQueryTests: XCTestCase {
    
    var context: NSManagedObjectContext = {
        return setUpInMemoryManagedObjectContext(CoreValueMacTests.self)!
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
        // Important, the results: [Employee] is required for the type checker to figure things out
        testTry {
            let predicate = NSPredicate(format: "age > 10 and age < 12", argumentArray: nil)
            let results: [Employee] = try Employee.query(self.context, predicate: predicate)
            if results.count != 1 {
                XCTAssert(false, "Wrong amount for you ones \(results.count)")
            }
        }
    }
    
    func testQueryOldOnes() {
        testTry {
            let predicate = NSPredicate(format: "age > 50", argumentArray: nil)
            // Important, the results: [Employee] is required for the type checker to figure things out
            let results: [Employee] = try Employee.query(self.context, predicate: predicate)
            if results.count != 9 {
                XCTAssert(false, "Wrong amount for old ones \(results.count)")
            }
        }
    }
    
    func testQueryOrder() {
        // Important, the results: [Employee] is required for the type checker to figure things out
        let descriptors: [NSSortDescriptor] = [NSSortDescriptor(key: "age", ascending: false)]
        testTry {
            let results: [Employee] = try Employee.query(self.context, predicate: nil, sortDescriptors: descriptors)
            if let r = results.first {
                if r.age != 59 {
                    XCTAssert(false, "wrong employee age: \(r.age)")
                }
            } else {
                XCTAssert(false, "Wrong query amount result: 0")
            }
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
        testTry {
            try s2.mutatingToObject(self.context)
        }
        
        // now update both shops
        testTry {
            try s1.mutatingToObject(self.context)
        }
        
        testTry {
            try s2.mutatingToObject(self.context)
        }
        
        // And query the count
        testTry {
            let predicate = NSPredicate(format: "self.name=='shop1'", argumentArray: [])
            let results: [StoredShop] = try StoredShop.query(self.context, predicate: predicate)
            XCTAssert(results.count == 1, "Wrong amount of objects, update did insert: \(results.count)")
        }
    }
    
    func testDeletion() {
        // create two shops
        var s1 = StoredShop(objectID: nil, name: "shop1", owner: Employee(name: "a", age: 4, position: nil, department: "", job: ""))
        testTry {
            try s1.save(self.context)
        }
        
        var s2 = StoredShop(objectID: nil, name: "shop2", owner: Employee(name: "a", age: 4, position: nil, department: "", job: ""))
        testTry {
            try s2.save(self.context)
        }
        
        // delete one
        testTry {
            try s2.delete(self.context)
        }
        
        // and count
        testTry {
            let results: [StoredShop] = try StoredShop.query(self.context, predicate: nil)
            XCTAssert(results.count == 1, "Failed to delete object \(s2) from context")
        }
    }
    
    func testInfiniteLoop() {
        let employee = StoredShopEmployee(objectID: nil, name: "John Doe", age: 18, position: "Clerk", department: "Carpet", job: "Cleaner", shop:nil)
        var shop = StoredEmployeeShop(objectID: nil, name: "Carpet shop", employees: [employee])
        
        try! shop.save(context)
        //Will crash in infinite loop
        let shops:[StoredEmployeeShop] = try! StoredEmployeeShop.query(context, predicate: nil)
        print(shops)
        XCTAssertNotNil(shops)
    }
    
    var employeesCount : Int{
        let employees : [StoredShopEmployee] = try! StoredShopEmployee.query(context, predicate: nil)
        return  employees.count
    }
    
    func testDuplicateEntries() {
        let beforeCount = self.employeesCount
        
        var employee = StoredShopEmployee(objectID: nil, name: "John", age: 18, position: "Clerk", department: "All", job: "Clerk", shop:nil)
        
        try! employee.save(context)
        
        XCTAssertEqual(beforeCount + 1, self.employeesCount)
        
        var shop1 = StoredEmployeeShop(objectID: nil, name: "Carpet shop 1", employees: [employee])
        var shop2 = StoredEmployeeShop(objectID: nil, name: "Carpet shop 2", employees: [employee])
        
        try! shop1.save(context)
        try! shop2.save(context)
        
        XCTAssertEqual(beforeCount + 1, self.employeesCount)
    }
}


class CoreValuePerformanceTests: XCTestCase {
    
    var context: NSManagedObjectContext = {
        return setUpInMemoryManagedObjectContext(CoreValueMacTests.self)!
    }()
    
    var manyCompanies: [Company] = {
        var box: [Employee] = []
        for c in 0..<25 {
            box.append(Employee(name: "employee", age: Int16(c), position: nil, department: "", job: ""))
        }
        var companyBox: [Company] = []
        for c in 0..<50 {
            companyBox.append(Company(name: "a Company \(c)", employees: box))
        }
        return companyBox
    }()
    
    var manyStoredShops: [StoredEmployeeShop] = {
        var box: [StoredShopEmployee] = []
        for c in 0..<25 {
            box.append(StoredShopEmployee(objectID: nil, name: "employee", age: Int16(c), position: nil, department: "", job: "", shop: nil))
        }
        var companyBox: [StoredEmployeeShop] = []
        for c in 0..<50 {
            companyBox.append(StoredEmployeeShop(objectID: nil, name: "a Company \(c)", employees: box))
        }
        return companyBox
    }()
    
    var manyUniqueShops: [UniqueEmployeeShop] = {
        var box: [UniqueShopEmployee] = []
        for c in 0..<25 {
            box.append(UniqueShopEmployee(name: "employee", age: Int16(c), position: nil, department: "", job: "", shop: nil))
        }
        var companyBox: [UniqueEmployeeShop] = []
        for c in 0..<50 {
            companyBox.append(UniqueEmployeeShop(name: "a Company \(c)", employees: box))
        }
        return companyBox
    }()
    
    func testBoxPerformance() {
        self.measure {
            testTry {
                let results: [NSManagedObject] = try self.manyCompanies.map { company in
                    let managedCompany = try company.toObject(self.context)
                    XCTAssert(managedCompany.value(forKey: "name") as? String == company.name)
                    return managedCompany
                }
                XCTAssert(results.count == self.manyCompanies.count, "Boxed Companies have to be the same amount of entities")
            }
        }
    }
    
    func testBoxPersistentPerformance() {
        self.measure {
            testTry {
                let results: [NSManagedObject] = try self.manyStoredShops.map { shop in
                    var mutatedShop = shop
                    let managedShop = try mutatedShop.mutatingToObject(self.context)
                    XCTAssert(managedShop.value(forKey: "name") as? String == shop.name)
                    return managedShop
                }
                XCTAssert(results.count == self.manyStoredShops.count, "Boxed Companies have to be the same amount of entities")
            }
        }
    }
    
    func testBoxUniquePerformance() {
        self.measure {
            testTry {
                let results: [NSManagedObject] = try self.manyUniqueShops.map { shop in
                    let managedShop = try shop.toObject(self.context)
                    XCTAssert(managedShop.value(forKey: "name") as? String == shop.name)
                    return managedShop
                }
                XCTAssert(results.count == self.manyUniqueShops.count, "Boxed Companies have to be the same amount of entities")
            }
        }
    }
    
    func testBoxUniqueInBatchPerformance() {
        self.measure {
            testTry {
                let results: [NSManagedObject] = try self.manyUniqueShops.toObjects(self.context)
                XCTAssert(results.count == self.manyUniqueShops.count, "Boxed Companies have to be the same amount of entities")
            }
        }
    }
    
    func testUnboxPerformance() {
        testTry {
            let results: [NSManagedObject] = try manyCompanies.map { company in
                let managedCompany = try company.toObject(self.context)
                XCTAssert(managedCompany.value(forKey: "name") as? String == company.name)
                return managedCompany
            }
            
            self.measure {
                testTry {
                    let entities = try results.map {
                        try Company.fromObject($0)
                    }
                    
                    XCTAssert(entities.count == results.count, "Unboxed Companies have to have the same amount of entities.")
                }
            }
        }
    }
}


