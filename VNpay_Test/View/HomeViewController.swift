//
//  ViewController.swift
//  VNpay_Test
//
//  Created by pham kha dinh on 15/8/24.
//

import UIKit
class HomeViewController: UIViewController {
    
    private let searchController = UISearchController(searchResultsController: nil)
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.delegate = self
        table.dataSource = self
        table.register(ImageTableViewCell.self, forCellReuseIdentifier: "PicsumCell")
        return table
    }()
    
    private let loadingFooter: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        label.text = "Loading..."
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    private let refreshControl = UIRefreshControl()
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let viewModel = PicsumViewModel()
    private var isShowingAlert = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "HOME"
        view.backgroundColor = .white
        setupUI()
        setupSearchBar()
        tableView.rowHeight = UITableView.automaticDimension
        bindViewModel()
        setupRefreshControl()
        viewModel.fetchData()
        tableView.tableFooterView = loadingFooter
        loadingFooter.isHidden = true
    }
    
    private func showValidationAlert() {
        guard !isShowingAlert else { return }
        isShowingAlert = true
        
        let alert = UIAlertController(title: "Lỗi nhập liệu",
                                      message: "Vui lòng chỉ nhập chữ cái, số và khoảng trắng. Tối đa 15 ký tự.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.isShowingAlert = false
        })
        present(alert, animated: true)
    }
    
    private func setupSearchBar() {
        searchController.searchResultsUpdater = self
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Tìm kiếm theo tác giả hoặc id"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(activityIndicator)
        tableView.separatorStyle = .none

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    private func bindViewModel() {
        viewModel.reloadTableView = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
                self?.refreshControl.endRefreshing()
                self?.activityIndicator.stopAnimating()
            }
        }
    }

    private func setupRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
    }

    @objc private func refreshData() {
        viewModel.currentPage = 1
        viewModel.hasMorePages = true
        viewModel.heightPhotos.removeAll()
        viewModel.fetchData()
    }

}


// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PicsumCell", for: indexPath) as! ImageTableViewCell
        let item = viewModel.item(at: indexPath)
        cell.configure(with: item, viewModel: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.heightForRow(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Check if the last row number is the same as the last current data element
        if indexPath.row == self.viewModel.filteredItems.count - 1 {
            self.viewModel.hasMorePages = true
            self.loadNextPageIfNeeded()
        }
    }
    private func loadNextPageIfNeeded() {
        if !viewModel.isSearching && !viewModel.isLoadingMoreData && viewModel.hasMorePages {
            loadingFooter.isHidden = false
            viewModel.loadNextPageIfNeeded()
        } else {
            loadingFooter.isHidden = true
        }
    }
}

//MARK: - UISearchBar
extension HomeViewController: UISearchBarDelegate, UISearchResultsUpdating {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let validatedText = validateSearchText(searchText)
        if validatedText != searchText {
            searchBar.text = validatedText
            showValidationAlert()
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        let validatedText = validateSearchText(searchText)
        viewModel.filterItems(with: validatedText)
    }

    private func validateSearchText(_ text: String) -> String {
        let validCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ")
        let filteredText = String(text.unicodeScalars.filter { validCharacters.contains($0) })
        return String(filteredText.prefix(15))
    }
}




