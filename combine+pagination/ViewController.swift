//
//  ViewController.swift
//  combine+pagination
//
//  Created by Z on 21/01/2023.
//

import UIKit
import Combine

final class ViewController: UIViewController {

    @IBOutlet weak var showsTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    var allShows: Show?
    var filteredShows: Show?
    var currentPage : Int = 1
    var isLoadingList : Bool = false

    
    private var cancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchShows(currentPage)
        searchTextField.addTarget(self, action: #selector(ViewController.textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    private func fetchShows(_ pageNumber: Int) {
        
        cancellable?.cancel()
        cancellable = nil 
        cancellable = ShowService().getShows(pageNumber: String(pageNumber)).map { [weak self] shows in
            self?.isLoadingList = false
            self?.allShows = shows
            self?.filteredShows = shows
        }.sink { _ in } receiveValue: { [weak self] _story in
            self?.isLoadingList = false
            self?.showsTableView.reloadData()
        }
    }
    
    func loadMoreItemsForList() {
        currentPage += 1
        fetchShows(currentPage)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let textFieldText = textField.text?.lowercased(),
              let allShows else { return }
        
        if textFieldText.isEmpty {
            filteredShows = allShows
            showsTableView.reloadData()
            return
        }
        
        filteredShows = allShows.filter { $0.name?.lowercased().contains( textFieldText ) ?? false }
        showsTableView.reloadData()
    }
    
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filteredShows?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell");
        
        
        cell.textLabel?.text = filteredShows?[indexPath.row].name
        return cell
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList) {
            self.isLoadingList = true
            self.loadMoreItemsForList()
        }
    }
}
