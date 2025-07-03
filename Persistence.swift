//
//  Persistence.swift
//  SnapArt
//
//  Created by Le Thanh Nhan on 2/7/25.
//

import CoreData
import FirebaseAuth

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for i in 0..<5 {
            let newImage = EditedImage(context: viewContext)
            newImage.id = UUID()
            newImage.title = "Sample Image \(i+1)"
            newImage.createdAt = Date()
            newImage.updatedAt = Date()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "SnapArt")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    func saveUserData(for firebaseUser: FirebaseAuth.User) {
        let context = container.viewContext
        
        // Check if user exists in CoreData
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", firebaseUser.uid)
        
        do {
            let results = try context.fetch(fetchRequest)
            let user: User
            
            if let existingUser = results.first {
                // Update existing user
                user = existingUser
            } else {
                // Create new user
                user = User(context: context)
                user.id = UUID(uuidString: firebaseUser.uid) ?? UUID()
                user.createdAt = Date()
            }
            
            // Update properties
            user.email = firebaseUser.email
            
            try context.save()
        } catch {
            print("Error saving user data: \(error)")
        }
    }
}
