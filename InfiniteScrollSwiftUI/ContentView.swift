//
//  ContentView.swift
//  InfiniteScrollSwiftUI
//
//  Created by Fahim Rahman on 2023-07-26.
//

import SwiftUI
import DynamicJSON
import Kingfisher
import SimpleAFLoader

struct ContentView: View {
    
    @State private var jsonData = JSON()
    @State private var imageURLArray = [String]()
    @State private var currentPage = 0
    @State private var contentLimit = 50
    @State private var isLoadingMoreData = false
    @State private var isLoaderVisible: Bool = false
    
    var body: some View {
        List {
            ForEach(0..<(self.imageURLArray.count), id: \.self) { i in
                LazyVStack {
                    KFImage(URL(string: self.imageURLArray[i]))
                        .diskCacheExpiration(.days(1))
                        .diskCacheAccessExtending(.expirationTime(.days(1)))
                        .loadDiskFileSynchronously()
                        .resizable()
                        .frame(width: UIScreen.main.bounds.size.width - 20, height: UIScreen.main.bounds.size.width / 1.9, alignment: .center)
                        .cornerRadius(10)
                        .onAppear {
                            if self.imageURLArray[i] == self.imageURLArray.last {
                                self.loadMoreItems()
                            }
                        }
                }
                .padding(.vertical, 5)
            }
            .listRowSeparator(.hidden)
            .listRowInsets(EdgeInsets())
        }
        .listStyle(PlainListStyle())
        .clipped()
        .task {
            self.isLoaderVisible.toggle()
            NetworkManager.shared.makeGenericAPIRequest(url: "https://picsum.photos/v2/list?page=\(self.currentPage)&limit=\(contentLimit)", method: .get) { result in
                do {
                    self.jsonData = JSON(try result.get())
                    for i in 0..<(self.jsonData.array?.count ?? 0) {
                        self.imageURLArray.append(self.jsonData[i].download_url.string ?? "")
                    }
                    self.isLoaderVisible.toggle()
                }
                catch {
                    print(error.localizedDescription)
                }
            }
        }
        .overlay(LoaderView(loaderColor: .black.opacity(0.8), loaderTextColor: .black.opacity(0.8), loadingText: "Getting Data", loaderElementSize: .medium, loaderAnimationSpeed: .medium, showLoader: isLoaderVisible))
        .disabled(isLoaderVisible)
    }
    
    private func loadMoreItems() {
        guard !isLoadingMoreData else { return }
        isLoadingMoreData = true
        currentPage += 1
        NetworkManager.shared.makeGenericAPIRequest(url: "https://picsum.photos/v2/list?page=\(self.currentPage)&limit=\(contentLimit)", method: .get) { result in
            do {
                self.jsonData = JSON(try result.get())
                for i in 0..<(self.jsonData.array?.count ?? 0) {
                    self.imageURLArray.append(self.jsonData[i].download_url.string ?? "")
                }
            } catch {
                print(error.localizedDescription)
            }
            isLoadingMoreData = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
