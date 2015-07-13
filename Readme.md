## CoreValue
### Lightweight Framework for using Core Data with Value Types

> Status, in Development

This is a framework to use core data with struct models instead of NSObject-based classes. 

i.e.
ValueType -> NSManagedObject
NSManagedObject -> ValueType

### Todo
- [ ] add support for optional array types ([Employee]?)
- [ ] add iOS target
- [ ] add carthage support (sharing scheme, testing it)
- [ ] add travis build
- [ ] add support for nsset / unordered lists
- [ ] add support for fetched properties (could be a struct a la (objects, predicate))
- [ ] support transformable: https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/CoreData/Articles/cdNSAttributes.html
- [ ] add jazzy for docs and update headers to have proper docs

### Done Tasks
- [x] Add query methods to query from core data straight into structs
- [x] support more types, including NSData, NSDate, and transformable (NSValue)
- [x] add support for array types ([Employee])
- [x] add support for optional sub types (Employee?)
- [x] think about syncing, to make sure objects from core data and back to core data are not inserted twice... (for updating, etc)
- [x] make the managed object context optional
- [x] move the toCoreData into the boxing protocol and fill it with a protocol extension
- [x] test with let instead of var types
- [x] does storing automatically work for sub objects / sub arrays
- [x] add support for other persistence features. update/save, delete
- [x] think about a simpler api around BoxingStructs:  `.object` to create an ephemeral object, .save to save it, .delete to delete it?
      currently the complexity of understanding the mutatingToObject and toObject behaviour with all it's side effects is too high
- [x] figure out the best way of  saving (i.e. NSManagedStruct save function that converts to nsmanagedobject and saves on the context?)
      so that one doesn't need to call toObject every time the value type changed...
- [x] think about renaming to CoreValue / NSManagedValue
