//
//  Model.swift
//  dbnetworktest
//
//  Created by Patryk Mikolajczyk on 05/03/2017.
//  Copyright © 2017 Patryk Mikolajczyk. All rights reserved.
//

import RealmSwift



class Model: Object {
    dynamic var property1: String = ""
    dynamic var propperty2: String = ""
    dynamic var propperty3: Int = 0
    dynamic var propperty4: Int = 0
}


extension Model {
    
    override static func primaryKey() -> String? {
        return "property1"
    }
}

// METHOD 1
/*
    you can subclass object or make extension for basic operations ofc.
 
 */
extension Model {

    static func map(model: ServiceModel1) -> Model? {
        guard let prop1 = model.property1,
            let prop2 = model.property2,
            let prop3 = model.property3,
            let prop4 = model.property4
            else { return nil }
        let obj = Model()
        obj.property1 = prop1
        obj.propperty2 = prop2
        obj.propperty3 = prop3
        obj.propperty4 = prop4
        return obj
    }
    
    static func getModel1() -> Model? {
        do {
            let realm = try Realm()
            return realm.objects(Model.self).first
        } catch {
            return nil
        }
    }
    
    static func save() {
        let ble = ServiceModel1(property1: "ble", property2: "edward", property3: 0, property4: 1)
        guard let obj = Model.map(model: ble) else {
            fatalError("something went wrong 😇")
        }
        obj.save()
    }
    
    func save() {
        do {
            let realm = try Realm()
            try realm.write {
                realm.add(self, update: true)
            }
        } catch {
            fatalError("something went wrong 😇 \(error)")
        }
    }
}

struct ServiceModel1 {
    let property1: String?
    let property2: String?
    let property3: Int?
    let property4: Int?
}





// METHOD 2
protocol Persistable {
    associatedtype ManagedObject: RealmSwift.Object
    init(managedObject: ManagedObject)
    func managedObject() -> ManagedObject
}

final class WriteTransaction {
    private let realm: Realm
    internal init(realm: Realm) {
        self.realm = realm
    }
    func add<T: Persistable>(_ value: T, update: Bool) {
        realm.add(value.managedObject(), update: update)
    }
}

// Implement the Container
final class Container {
    private let realm: Realm
    public convenience init() throws {
        try self.init(realm: Realm())
    }
    internal init(realm: Realm) {
        self.realm = realm
    }
    public func write(_ block: (WriteTransaction) throws -> Void)
        throws {
            let transaction = WriteTransaction(realm: realm)
            try realm.write {
                try block(transaction)
            }
    }
}

struct ViewModel2: Persistable {
    typealias ManagedObject = Model

    let property1: String
    let property2: String
    let property3: Int
    let property4: Int
}

extension ViewModel2 {
    init(managedObject: ManagedObject) {
        property1 = managedObject.property1
        property2 = managedObject.propperty2
        property3 = managedObject.propperty3
        property4 = managedObject.propperty4
    }
    func managedObject() -> Model {
        let obj = Model()
        obj.property1 = property1
        obj.propperty2 = property2
        obj.propperty3 = property3
        obj.propperty4 = property4
        return obj
    }
    
    func save() {
        do {
            let container = try Container()
            try container.write { transaction in
                transaction.add(self, update: true)
                
            }
        } catch {
            fatalError("error while saving")
        }
    }
    
    static func getModel2() -> ViewModel2? {
        do {
            let realm = try Realm()
            guard let model = realm.objects(Model.self).first else { return nil }
            return ViewModel2(managedObject: model)
        } catch {
            //        fatalError("something went wrong 😇 \(error)")
            //
            return nil
        }
    }
}
