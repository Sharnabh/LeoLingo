import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    var context: NSManagedObjectContext {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        return appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - User Operations
    func findUser(byPhone phoneNumber: String) -> User? {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "phoneNumber == %@", phoneNumber)
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Error fetching user: \(error)")
            return nil
        }
    }
    
    func validateUser(phoneNumber: String, password: String) -> User? {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "phoneNumber == %@ AND password == %@", phoneNumber, password)
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Error validating user: \(error)")
            return nil
        }
    }
} 
