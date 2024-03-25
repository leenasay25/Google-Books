//
//  FavViewController.swift
//  GoogleBooksAPI
//
//  Created by Leena Alsayari on 29/03/2023.
//  Copyright © 2023 udacity. All rights reserved.
//

import UIKit
import CoreData

class FavViewController: UIViewController, UITableViewDataSource,  NSFetchedResultsControllerDelegate {
    
  
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var books = [Book]()
    var booksURLs : String = ""
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<FavBook>!

    
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<FavBook> = FavBook.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "favBooks")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Favourite Books"
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        dataController = appDelegate.dataController
        setupFetchedResultsController()
        indicator.hidesWhenStopped = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultsController = nil
    }
    
    func showAlert(error: AppError){
    
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "ok", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    
    //Table View Methods
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
    
        performSegue(withIdentifier: "detailedSegue", sender: cell)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aFavbook = fetchedResultsController.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "favbookCell", for: indexPath) as! favBookCell
        

        // Configure cell
        cell.title.text = aFavbook.title
        cell.subtitle.text = aFavbook.subtitle
        cell.imageView?.image = nil
        
        self.indicator.isHidden = false
        self.indicator.startAnimating()
        
        DispatchQueue.main.async {
            if let data = aFavbook.image {
                cell.imageView?.image = UIImage(data: data)
                cell.setNeedsLayout()
                self.indicator.stopAnimating()
            }
        }
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        cell.layer.borderWidth = 1.0
        cell.layer.borderColor = UIColor.black.cgColor
        return cell
    }
   
    func deleteFavBook(at indexPath: IndexPath) {
        let bookToDelete = fetchedResultsController.object(at: indexPath)
        dataController.viewContext.delete(bookToDelete)
        try? dataController.viewContext.save()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteFavBook(at: indexPath)
        default: () // Unsupported
        }
    }
  

    
    

}


extension FavViewController {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
            break
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            break
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert: tableView.insertSections(indexSet, with: .fade)
        case .delete: tableView.deleteSections(indexSet, with: .fade)
        case .update, .move:
            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
        }
    }

    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }


}

