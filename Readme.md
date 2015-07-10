## StructData
### Lightweight Framework for using Core Data with Structs

> Status, in Development

This is a framework to use core data with struct models instead of NSObject-based classes. Serialization struct -> NSManagedObject already works (if a bit rough), however the other way around is still work in progress with a lot of thinking but no feasible code yet..

### Todo
- [ ] Add query methods to query from core data straight into structs
- [ ] support more types, including NSData, NSDate, and transformable (NSValue)
- [ ] add support for array types ([Employee])
- [ ] add support for optional array types ([Employee]?)
- [ ] add support for optional sub types (Employee?)
- [ ] add support for setting the inverse relationship (this is tricky to achieve for the struct part, as we don't have references there, since it should work as is for core data, we may not support this?)
