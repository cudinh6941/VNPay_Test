//
//  PhotoViewModel.swift
//  VNpay_Test
//
//  Created by pham kha dinh on 15/8/24.
//

import Foundation
import UIKit

class PicsumViewModel {
    var allItems: [ImageItem] = []
    var filteredItems: [ImageItem] = []
    
    var isSearching: Bool = false
    var heightPhotos: [CGFloat] = [] 
    var reloadTableView: (() -> Void)?
    
    var isLoadingMoreData = false
    var currentPage = 1
    var hasMorePages = true

    func fetchData(isLoadingMore: Bool = false) {
        if !isLoadingMore {
            currentPage = 1
        }
        guard hasMorePages else { return }
        
        let urlString = "https://picsum.photos/v2/list?page=\(currentPage)&amp;limit=100"
        guard let url = URL(string: urlString) else { return }

        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            defer {
                self.isLoadingMoreData = false
            }
            guard let data = data, error == nil else {
                print("Failed to load data: \(error?.localizedDescription ?? "No error description")")
                return
            }

            do {
                let decodedItems = try JSONDecoder().decode([ImageItem].self, from: data)
                if isLoadingMore {
                    self.allItems += decodedItems
                    self.filteredItems += decodedItems
                } else {
                    self.allItems = decodedItems
                    self.filteredItems = decodedItems
                }
                self.hasMorePages = decodedItems.count == self.allItems.count
                let fixedWidth: CGFloat = UIScreen.main.bounds.width - 20
                let newHeights = decodedItems.map { item in
                    let aspectRatio = CGFloat(item.height) / CGFloat(item.width)
                    return fixedWidth * aspectRatio
                }
                self.heightPhotos += newHeights

                DispatchQueue.main.async {
                    self.reloadTableView?()
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
    
    func loadNextPageIfNeeded() {
         guard !isSearching && hasMorePages && !isLoadingMoreData else { return }
         isLoadingMoreData = true
         currentPage += 1
         fetchData(isLoadingMore: true)
     }
    
    func filterItems(with searchText: String) {
        hasMorePages = false
        if searchText.isEmpty {
            filteredItems = allItems
            isSearching = false
        } else {
            let lowercasedSearchText = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            filteredItems = allItems.filter { item in
                let authorMatch = item.author.lowercased().contains(lowercasedSearchText)
                let idMatch = item.id == lowercasedSearchText 
                return authorMatch || idMatch
            }
            isSearching = true
        }
        reloadTableView?()
    }
    
    func numberOfRows() -> Int {
        return filteredItems.count
    }

    func item(at indexPath: IndexPath) -> ImageItem {
        guard indexPath.row < filteredItems.count else {
            fatalError("Index out of range when accessing filteredItems at row \(indexPath.row)")
        }
        return filteredItems[indexPath.row]
    }


    func heightForRow(at indexPath: IndexPath) -> CGFloat {
        return heightPhotos[indexPath.row] + 20
    }

    func downloadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) -> URLSessionDataTask? {
          guard let url = URL(string: urlString) else {
              completion(nil)
              return nil
          }
          if let cachedImage = ImageCache.shared.object(forKey: url.absoluteString as NSString) {
              completion(cachedImage)
              return nil
          }

          let task = URLSession.shared.dataTask(with: url) { data, response, error in
              guard let data = data, error == nil else {
                  print("Failed to load image: \(error?.localizedDescription ?? "No error description")")
                  DispatchQueue.main.async {
                      completion(nil)
                  }
                  return
              }

              if let image = UIImage(data: data) {
                  ImageCache.shared.setObject(image, forKey: url.absoluteString as NSString)
                  DispatchQueue.main.async {
                      completion(image)
                  }
              } else {
                  DispatchQueue.main.async {
                      completion(nil)
                  }
              }
          }
          task.resume()
          return task
      }

}

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

