//
//  MasterViewController.swift
//  Blog Reader
//
//  Created by Georgy Khaydenko on 04.02.18.
//  Copyright © 2018 Georgy Khaydenko. All rights reserved.
//

//blogger API key
//AIzaSyBm_boEtxCdqpzAZmNOtZRFxfetayPTqRY

//google blogID = "10861780"

import UIKit
import CoreData



class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let url = URL(string: "https://www.googleapis.com/blogger/v3/blogs/10861780/posts?key=AIzaSyBm_boEtxCdqpzAZmNOtZRFxfetayPTqRY") //list of posts
        
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            
            if error != nil {
                
                print(error as Any)
                
            } else {
                
                if let urlContent = data {
                    
                    do {
                        
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        
                        if let posts = (jsonResult["items"] as? NSArray)  {
                            
                            for post in posts {
                                
                                if let title = (post as? NSDictionary)?["title"] {
                                    
                                    /*
                                     //we can delete all content or check the same in storage
                                     //this is how to delete
                                     
                                    let context = self.fetchedResultsController.managedObjectContext
                                    
                                    let request = NSFetchRequest<Event>(entityName: "Event")
                                     
                                    do {
                                        
                                        let results = try context.fetch(request)
                                        
                                        if results.count > 0 {
                                            
                                            for result in results {
                                                
                                                context.delete(result)
                                                
                                                do {
                                                    
                                                    try context.save()
                                                    
                                                } catch {
                                                    
                                                    print("Specific delete failed")
                                                    
                                                }
                                                
                                            }
                                            
                                        }
                                        
                                    } catch {
                                        
                                        print("Delete failed")
                                        
                                    }
                                     */
                                    
                                    //checking the same info in storage
                                    
                                    let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Event")
                                    
                                    request.predicate = NSPredicate(format: "title = %@", title as! String)
                                    
                                    request.returnsObjectsAsFaults = false
                                    
                                    do {
                                        
                                        let results = try self.managedObjectContext?.fetch(request)
                                        
                                        if (results?.count)! > 0 {
                                            
                                            print(results as Any)
                                            
                                        } else {
                                    
                                            if let content = (post as? NSDictionary)?["url"] {
                                                
                                                let newPost = NSEntityDescription.insertNewObject(forEntityName: "Event", into: self.managedObjectContext!)
                                                
                                                let pageURl = String(describing: content)
                                                
                                                let data = NSData(contentsOf: URL(string: pageURl)!)!
                                                
                                                if let postID = (post as? NSDictionary)?["id"] {
                                                    
                                                    newPost.setValue(postID, forKey: "postID")
                                                    
                                                    let indexValue = newPost.value(forKey: "postID") as! String

                                                    
                                                    let filePath: String = "\(paths[0])/\(indexValue)\(".html")"
                                                    
                                                    print(filePath)

                                                    data.write(toFile: filePath , atomically: true)
                                                    
                                                    newPost.setValue(title, forKey: "title")
                                                    newPost.setValue(pageURl, forKey: "content")
                                                    newPost.setValue(data, forKey: "data")
                                                    
                                                    do {
                                                        
                                                        try self.managedObjectContext?.save()
                                                        
                                                        print("Saved \(title)")
                                                        
                                                    } catch {
                                                        print("Ther is an error")
                                                    }

                                                    
                                                }
                                                
                                            }
                                        }
                                    }
                                
                                }
                                
                            }

                        }
                        
                    } catch {
                        
                        print("JSON processing failed")
                        
                    }
                    
                }
                
            }
            
        }
        
        task.resume()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(_ sender: Any) {
        let context = self.fetchedResultsController.managedObjectContext
        let newEvent = Event(context: context)
             
        // If appropriate, configure the new managed object.
        newEvent.timestamp = NSDate()

        // Save the context.
        do {
            try context.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let event = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withEvent: event)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withEvent event: Event) {
        cell.textLabel!.text = event.title
    }

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Event> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        
        // Set the batch size to a suitable number.
        fetchRequest.fetchBatchSize = 20
        
        // Edit the sort key as appropriate.
        let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
             // Replace this implementation with code to handle the error appropriately.
             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
             let nserror = error as NSError
             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }    
    var _fetchedResultsController: NSFetchedResultsController<Event>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!)!, withEvent: anObject as! Event)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}

