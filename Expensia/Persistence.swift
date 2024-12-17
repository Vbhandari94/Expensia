//
//  Persistence.swift
//  Expensia
//
//  Created by Varun Bhandari on 17/12/24.
//

//
//  Persistence.swift
//  Expensia
//
//  Created by Varun Bhandari on 17/12/24.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        // Use the Core Data model name here (e.g., Expensia.xcdatamodeld)
        container = NSPersistentCloudKitContainer(name: "Expensia")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        // Configure the iCloud container
        if let storeDescription = container.persistentStoreDescriptions.first {
            let options = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.smr.SpendSensenew2")
            storeDescription.cloudKitContainerOptions = options
        }

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                // Handle the error more gracefully in production.
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
