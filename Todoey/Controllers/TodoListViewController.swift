//
//  ViewController.swift
//  Todoey
//
//  Created by Fernando Rosa on 25/11/19.
//  Copyright © 2019 Fernando Rosa. All rights reserved.
//

import UIKit
import CoreData

class TodoListViewController: UITableViewController {
        
    var itemArray = [Item]()
    
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        loadItems()

        
    }
    
    //MARK: - TableView Datasource Methods

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoItemCell", for: indexPath)
        
        let item = itemArray[indexPath.row]
        
        cell.textLabel?.text = item.title
        
        cell.accessoryType = item.done ? .checkmark : .none
        
        return cell
    }
    
    
    //MARK: - TableView Delegate Methods

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          
//        var replacement = itemArray[indexPath.row].title!
//        if itemArray[indexPath.row].done == false {
//            replacement = String("\(replacement) - OK")
//            itemArray[indexPath.row].setValue(replacement, forKey: "title")
//        } else {
//            let newReplacement = replacement.replacingOccurrences(of: " - OK", with: "")
//            itemArray[indexPath.row].setValue(newReplacement, forKey: "title")
//        }

        itemArray[indexPath.row].done = !itemArray[indexPath.row].done
        
        // Primeiro remove de Context, depois do Array, caso contrário o indexPath apontará para o item errado
//        context.delete(itemArray[indexPath.row])
//        itemArray.remove(at: indexPath.row)
        
        saveItems()
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    
    //MARK: - Add New Items
    
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            //What will happen once the user clicks the Add Item button on UIAlert
            print("Success!")
            
            
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.done = false
            self.itemArray.append(newItem)
            
            self.saveItems()
            
            
            
        }
        alert.addTextField { (alertTextField) in
            
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Save Items
    
    fileprivate func saveItems() {
        
        do {
            try context.save()
        } catch {
            print("Error saving context, \(error)")
        }
        // Recarrega os dados do array no tableView
        self.tableView.reloadData()
    }
    
    
    //MARK: - Load Items
    
    // O "with" é o parâmetro externo que aparece ao chamar o método
    // "= Item.fetchRequest()" é o valor padrão caso não seja fornecido um parâmetro como é o caso lá em viewDidLoad
    
    func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest() ) {
        
        do {
            itemArray = try context.fetch(request)
        } catch {
            print("Error fetching data from context, \(error)")
        }
        self.tableView.reloadData()
    }
    
    
    //MARK: - Delete Item

    func deleteItem(index: Int) {
                
        // Primeiro remove de Context, depois do Array, caso contrário o "indexPath.row" apontará para o item errado
        self.context.delete(self.itemArray[index])
        self.itemArray.remove(at: index)
        self.saveItems()
    }
    
    
    //MARK: - TableView Swipe to Delete

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let edit = UIContextualAction(style: .normal, title: "") { (action, view, nil) in
            let refreshAlert = UIAlertController(title: "Delete?", message: "Are you sure you want to remove this item? ", preferredStyle: .alert)

            refreshAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (action: UIAlertAction!) in
                
                print("yes")
                
                self.deleteItem(index: indexPath.row)
                
            }))

            refreshAlert.addAction(UIAlertAction(title: "No", style: .default, handler: { (action: UIAlertAction!) in
                refreshAlert .dismiss(animated: true, completion: nil)
                
                print("no")
                
                self.loadItems()
            }))

            self.present(refreshAlert, animated: true, completion: nil)
        }
        edit.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        //edit.image = #imageLiteral(resourceName: "storyDelete")
        edit.title = "Delete"
        let config = UISwipeActionsConfiguration(actions: [edit])
        config.performsFirstActionWithFullSwipe = true
        return config
    }
}


   //MARK: - SearchBar Methods


extension TodoListViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        // CONTAINS é um comando que define o tipo de busca.
        // [cd] faz com que a busca não leve em conta maiúsculas/minúscula ("c" de "case" ou acentos ("d" de "diacritics")
        request.predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
        
        request.sortDescriptors = [ NSSortDescriptor(key: "title", ascending: true) ]
        // A linha acima substitui as duas abaixo
//        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
//        request.sortDescriptors = [sortDescriptor]
        
        loadItems(with: request)
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
            
        }
        
    }
    
}
