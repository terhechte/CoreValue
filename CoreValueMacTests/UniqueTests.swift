//
//  UniqueTests.swift
//  CoreValue
//
//  Created by Tomas Kohout on 7/16/16.
//  Copyright © 2016 Benedikt Terhechte. All rights reserved.
//

import XCTest

import CoreData


struct Author : CVManagedUniqueStruct {
    
    static let EntityName = "Author"
    
    static var IdentifierName: String = "id"
    
    func IdentifierValue() -> IdentifierType { return self.id }
    
    let id: String
    let name: String
    
    static func fromObject(o: NSManagedObject) throws -> Author {
        return try curry(self.init)
            <^> o <| "id"
            <^> o <| "name"
    }
}

struct Article: CVManagedUniqueStruct {
    static let EntityName = "Article"
    
    static var IdentifierName: String = "id"
    
    func IdentifierValue() -> IdentifierType { return self.id }
    
    var id: Int16
    var text: String
    var author: Author?
    
    
    static func fromObject(o: NSManagedObject) throws -> Article {
        return try curry(self.init)
            <^> o <| "id"
            <^> o <| "text"
            <^> o <|? "author"
    }
}

struct Category: CVManagedUniqueStruct {
    static let EntityName = "Category"
    
    static var IdentifierName: String = "id"
    
    func IdentifierValue() -> IdentifierType { return self.id }
    
    //Create hash value for combined identifier
    static func identifier(type type: String, label: String) -> String{
        return "\(type)-\(label)"
    }
    
    var id: String = ""
    
    var type: String {
        didSet {
            id = Category.identifier(type: type, label: label)
        }
    }
    var label: String {
        didSet {
            id = Category.identifier(type: type, label: label)
        }
    }
    
    var articles: Array<Article>
    
    
    static func fromObject(o: NSManagedObject) throws -> Category {
        return try curry(self.init)
            <^> o <| "id"
            <^> o <| "type"
            <^> o <| "label"
            <^> o <|| "articles"
    }
}


class UniqueTests: XCTestCase {
    
    var context: NSManagedObjectContext = {
        return setUpInMemoryManagedObjectContext(CoreValueMacTests)!
    }()
    
    
    
    
    var category: Category = {
        var author1 = Author(id: "e1x45", name: "Hemingway")
        var author2 = Author(id: "hbx31", name: "Capek")
        
        let articles = [
            Article(id: 1, text: "original_text_1", author: author1),
            Article(id: 2, text: "original_text_2", author: author2),
            Article(id: 3, text: "original_text_3", author: author1)
        ]
        
        return Category(id: Category.identifier(type: "sports", label: "football"), type: "sports", label: "football", articles: articles)
    }()
    
    var category_update: [Category] = {
        var author1 = Author(id: "e1x45", name: "Hemingway")
        var author2 = Author(id: "hbx31", name: "Kafka")
        
        let articles = [
            Article(id: 1, text: "updated_text_1", author: author1),
            Article(id: 2, text: "updated_text_2", author: author2),
            Article(id: 3, text: "updated_text_3",  author: author1)
        ]
        
        return [
            Category(id: Category.identifier(type: "sports", label: "football"), type: "sports", label: "football", articles: [articles[0], articles[2]]),
            Category(id: Category.identifier(type: "sports", label: "hockey"), type: "sports", label: "hockey", articles: [articles[1], articles[2]])
        ]
    }()
    
    
    var manyCategories: [Category] = {
        var box: [Article] = []
        for c in 0..<25 {
            box.append(Article(id: Int16(c), text: "text_\(c)", author: nil))
        }
        var companyBox: [Category] = []
        for c in 0..<50 {
            companyBox.append(Category(id: "sports-basketball", type: "sports", label: "basketball", articles: box))
        }
        return companyBox
    }()
    
    
    
    func testUniqueSavingTwoTimes() {
        let s1 = self.category
        
        testTry {
            try s1.save(self.context)
        }
        
        testTry {
            try s1.save(self.context)
        }
        
        let after: [Category] = try! Category.query(self.context, predicate: nil)
        XCTAssertEqual(after.count, 1)
        XCTAssertEqual(after.first?.articles.count, 3)
    }
    
    func testUpdatesCategory() {
        var s1 = self.category
        
        testTry {
            try s1.save(self.context)
        }
        
        let after: [Category] = try! Category.query(self.context, predicate: NSPredicate(format: "label = %@", "football"))
        XCTAssertEqual(after.count, 1)
        
        //Update identifier
        s1.label = "curling"
        
        testTry {
            try s1.save(self.context)
        }
        
        let curling: [Category] = try! Category.query(self.context, predicate: NSPredicate(format: "label = %@", "curling"))
        XCTAssertEqual(curling.count, 1)
        
        //Football stays the same (doesn't get deleted, this is desired behaviour)
        let football: [Category] = try! Category.query(self.context, predicate: NSPredicate(format: "label = %@", "football"))
        XCTAssertEqual(football.count, 1)
    }
    
    
    func testUpdatesBasedOnId() {
        let s1 = self.category
        
        testTry {
            try s1.save(self.context)
        }
        
        let after: [Category] = try! Category.query(self.context, predicate: nil)
        XCTAssertEqual(after.count, 1)
        XCTAssertEqual(after.first?.articles.count, 3)
        
        let s2 = self.category_update
        testTry {
            try s2.saveAll(self.context)
        }
        
        let after2: [Category] = try! Category.query(self.context, predicate: nil)
        XCTAssertEqual(after2.count, 2)
        
        let category1 = after2.filter { $0.label == "football" && $0.type == "sports" }.first
        
        XCTAssertEqual(category1?.articles.count, 2)
        XCTAssertEqual(category1?.articles[0].id, 1)
        XCTAssertEqual(category1?.articles[1].id, 3)
        
        
        
        let category2 = after2.filter { $0.label == "hockey" && $0.type == "sports" }.first
        
        XCTAssertEqual(category2?.articles.count, 2)
        XCTAssertEqual(category2?.articles[0].id, 2)
        XCTAssertEqual(category2?.articles[1].id, 3)
        XCTAssertEqual(category2?.articles[0].author?.name, "Kafka")
    }
    
    func testSaveWithInconsistentData() {
        
        var category = self.category
        
        //Add another article to the category that has same id but different text
        let conflictedId = category.articles[0].id
        let conflictedArticle = Article( id: conflictedId, text: "conflicted_text", author: category.articles[0].author)
        category.articles.append(conflictedArticle)
        
        testTry {
            try category.save(self.context)
        }
        
        let after:[Category] = try! Category.query(self.context, predicate: NSPredicate(format: "id = %@", category.id))
        
        XCTAssertEqual(after.count, 1)
        XCTAssertEqual(category.articles[0].text, "original_text_1")
        
        //The last one in array should be saved
        XCTAssertEqual(after.first?.articles[0].text, "conflicted_text")
    }
    
    
    func testToObjectPerformance() {
        testTry {
            self.measureBlock {
                testTry {
                    let results: [NSManagedObject] = try self.manyCategories.map { category in
                        let managedCompany = try category.toObject(self.context)
                        XCTAssert(managedCompany.valueForKey("id") as? String == category.id)
                        return managedCompany
                    }
                    XCTAssert(results.count == self.manyCategories.count, "Unboxed Companies have to be the same amount of entities")
                }
            }
        }
    }
    
    func testToObjectsPerformance() {
        testTry {
            self.measureBlock {
                testTry {
                    let results: [NSManagedObject] = try self.manyCategories.toObjects(self.context)
                    XCTAssert(results.count == self.manyCategories.count, "Unboxed Companies have to be the same amount of entities")
                }
            }
        }
    }
}