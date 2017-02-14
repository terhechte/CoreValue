//: Playground - noun: a place where people can play

import UIKit

var str = "Hello, playground"

//This is the problem of bug#19
protocol ParentProtocol{
    func doSomething()
    
}

protocol ChildProtocol : ParentProtocol{
  
}

extension ParentProtocol{
    func printSomething(){
        print( "Parent is printing")
    }
    
    func doSomething(){
        self.printSomething()
    }
}

extension ChildProtocol{
    //Add this and everything is ok
//    func doSomething(){
//        self.printSomething()
//    }

    func printSomething(){
        print( "Child is printing")
    }
}

struct Child : ChildProtocol{
    
}

let c1 = Child()
c1.doSomething()

