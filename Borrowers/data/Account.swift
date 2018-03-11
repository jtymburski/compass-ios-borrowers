//
//  Account.swift
//  Borrowers
//
//  Created by Jordan Tymburski on 2018-03-10.
//  Copyright © 2018 GN Compass. All rights reserved.
//

import CoreData
import Foundation

extension Account {

    static func create() -> Account {
        // Delete all
        deleteAll()

        // Generate UUID
        let uuid = NSUUID().uuidString

        // Create the entity
        var account: Account
        if #available(iOS 10.0, *) {
            account = Account(context: CoreDataStack.managedObjectContext)
            account.deviceId = uuid
        } else {
            // Fallback on earlier versions
            let entityDesc = NSEntityDescription.entity(forEntityName: "Account", in: CoreDataStack.managedObjectContext)
            account = Account(entity: entityDesc!, insertInto: CoreDataStack.managedObjectContext)
            account.deviceId = uuid
        }

        // Save it
        CoreDataStack.saveContext()

        return account
    }

    static func deleteAll() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Account")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try CoreDataStack.managedObjectContext.execute(request)
        } catch {
            print("Account delete all failure: \(error)")
        }
    }

    static func get() -> Account? {
        let fetchRequest: NSFetchRequest<Account> = Account.fetchRequest()
        fetchRequest.fetchLimit = 1

        do {
            let accountData = try CoreDataStack.managedObjectContext.fetch(fetchRequest)
            return accountData.first
        } catch {
            print("Account fetch failure: \(error)")
        }
        return nil
    }

    static func getOrCreate() -> Account {
        if let account = get() {
            return account
        } else {
            return create()
        }
    }
}
