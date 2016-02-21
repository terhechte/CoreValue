//
//  CollectionTests.swift
//  CoreValue
//
//  Created by Roman Kříž on 21/02/16.
//  Copyright © 2016 Benedikt Terhechte. All rights reserved.
//

import XCTest
import CoreData


struct StoredEmployee : CVManagedPersistentStruct {
    static let EntityName = "Employee"
    var objectID: NSManagedObjectID?

    let name: String
    let age: Int16
    let position: String?
    let department: String
    let job: String

    static func fromObject(o: NSManagedObject) throws -> StoredEmployee {
        return try curry(self.init)
            <^> o <|? "objectID"
            <^> o <| "name"
            <^> o <| "age"
            <^> o <|? "position"
            <^> o <| "department"
            <^> o <| "job"
    }
}

struct StoredCompany: CVManagedPersistentStruct {
    static let EntityName = "Company"
    var objectID: NSManagedObjectID?

    var name: String
    var employees: Array<StoredEmployee>

    static func fromObject(o: NSManagedObject) throws -> StoredCompany {
        return try curry(self.init)
            <^> o <|? "objectID"
            <^> o <| "name"
            <^> o <|| "employees"
    }

    mutating func save(context: NSManagedObjectContext) throws {
        try employees.saveAll(context)

        try defaultSave(context)
    }
}




class CoreValueCollectionsTests: XCTestCase {

    var context: NSManagedObjectContext = {
        return setUpInMemoryManagedObjectContext(CoreValueMacTests)!
    }()

    var company: StoredCompany = {
        let employees = [
            StoredEmployee(objectID: nil, name: "1", age: 10, position: nil, department: "a", job: "b"),
            StoredEmployee(objectID: nil, name: "2", age: 20, position: nil, department: "d", job: "b"),
            StoredEmployee(objectID: nil, name: "3", age: 30, position: nil, department: "g", job: "b"),
            StoredEmployee(objectID: nil, name: "4", age: 40, position: nil, department: "i", job: "b")
        ]

        return StoredCompany(objectID: nil, name: "Company", employees: employees)
    }()

    func testSavingNestedCollectionSettingObjectID() {
        var s1 = self.company

        testTry {
            try s1.save(self.context)
        }

        XCTAssertNotNil(s1.objectID)
        XCTAssertNotNil(s1.employees[0].objectID)
    }

    func testSavingTwoTimes() {
        var s1 = self.company

        testTry {
            try s1.save(self.context)
        }

        let beforeEmployeeID = s1.employees.first?.objectID

        testTry {
            try s1.save(self.context)
        }

        let afterEmployeeID = s1.employees.first?.objectID

        XCTAssertNotNil(beforeEmployeeID)
        XCTAssertEqual(beforeEmployeeID, afterEmployeeID)

        let after: [StoredCompany] = try! StoredCompany.query(self.context, predicate: nil)
        XCTAssertEqual(after.first?.employees.count, 4)
    }

    func testRemovingItemFromNestedCollection() {
        var s1 = self.company

        testTry {
            try s1.save(self.context)
        }

        let before: [StoredCompany] = try! StoredCompany.query(self.context, predicate: nil)
        XCTAssertEqual(before.first?.employees.count, 4)

        s1.employees.removeFirst()

        testTry {
            try s1.save(self.context)
        }

        let after: [StoredCompany] = try! StoredCompany.query(self.context, predicate: nil)
        XCTAssertEqual(after.first?.employees.count, 3)
    }

    func testRemovingAllItemsFromNestedCollection() {
        var s1 = self.company

        // save for the first time
        testTry {
            try s1.save(self.context)
        }

        // check the count of employees
        let before: [StoredCompany] = try! StoredCompany.query(self.context, predicate: nil)
        XCTAssertEqual(before.first?.employees.count, 4)

        // remove all employees from original struct
        s1.employees.removeAll()

        // save the changes
        testTry {
            try s1.save(self.context)
        }

        // check for resulting
        let after: [StoredCompany] = try! StoredCompany.query(self.context, predicate: nil)
        XCTAssertEqual(after.first?.employees.count, 0)
    }
}
