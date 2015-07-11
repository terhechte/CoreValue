## StructData
### Lightweight Framework for using Core Data with Structs

> Status, in Development

This is a framework to use core data with struct models instead of NSObject-based classes. Serialization struct -> NSManagedObject already works (if a bit rough), however the other way around is still work in progress with a lot of thinking but no feasible code yet..

### Todo
- [ ] Add query methods to query from core data straight into structs
- [x] support more types, including NSData, NSDate, and transformable (NSValue)
- [x] add support for array types ([Employee])
- [ ] add support for optional array types ([Employee]?)
- [x] add support for optional sub types (Employee?)
- [ ] add support for setting the inverse relationship (this is tricky to achieve for the struct part, as we don't have references there, since it should work as is for core data, we may not support this?)
- [ ] think about syncing, to make sure objects from core data and back to core data are not inserted twice... (for updating, etc)
- [ ] think about renaming to CoreValue / NSManagedValue
- [ ] add iOS target
- [x] make the managed object context optional
- [x] move the toCoreData into the boxing protocol and fill it with a protocol extension
- [ ] add support for nsset / unordered lists
- [ ] add support for fetched properties (could be a struct a la (objects, predicate))
- [x] test with let instead of var types
- [ ] support transformable: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdNSAttributes.html

### Proposed Operator renaming
In order to improve the readability and understandability of the operators, the following
```
        return curry(self.init)
            <^> o <| "name"
            <*> o <| "age"
            <*> o <|? "position"
            <*> o <| "department"
            <*> o <| "job"
            <*> o <|| "company"
```

should be changed to
```
        return curry(self.init) with
             "name" from o
             "age" from o
             "position" optional-from o
             "department" from o
             "job" from o
             "company" object-from o
```
or
```
        return curry(self.init) with
             "name" <- o
             "age" <- o
             "position" <-? o
             "department" <- o
             "job" <- o
             "company" <-- o
```
