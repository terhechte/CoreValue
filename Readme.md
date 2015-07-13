## StructData
### Lightweight Framework for using Core Data with Value Types

> Status, in Development

This is a framework to use core data with struct models instead of NSObject-based classes. 

i.e.
ValueType -> NSManagedObject
NSManagedObject -> ValueType

### Todo
- [ ] figure out the best way of  saving (i.e. NSManagedStruct save function that converts to nsmanagedobject and saves on the context?)
      so that one doesn't need to call toObject every time the value type changed...
- [ ] add support for optional array types ([Employee]?)
- [ ] add support for setting the inverse relationship (this is tricky to achieve for the struct part, as we don't have references there, since it should work as is for core data, we may not support this?)
- [ ] think about renaming to CoreValue / NSManagedValue
- [ ] add iOS target
- [ ] add support for nsset / unordered lists
- [ ] add support for fetched properties (could be a struct a la (objects, predicate))
- [ ] support transformable: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdNSAttributes.html
- [ ] does storing automatically work for sub objects / sub arrays
- [ ] add support for other persistence features. update/save, delete

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
        return newObject(self.init) with
             value "name" from o
             value "age" from o
             optional "position" from o
             value "department" from o
             value "job" from o
             object "company" from o
```

### Done Tasks
- [x] Add query methods to query from core data straight into structs
- [x] support more types, including NSData, NSDate, and transformable (NSValue)
- [x] add support for array types ([Employee])
- [x] add support for optional sub types (Employee?)
- [x] think about syncing, to make sure objects from core data and back to core data are not inserted twice... (for updating, etc)
- [x] make the managed object context optional
- [x] move the toCoreData into the boxing protocol and fill it with a protocol extension
- [x] test with let instead of var types
