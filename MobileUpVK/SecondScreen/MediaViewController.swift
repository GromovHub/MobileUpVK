//
//  Project name: MobileUpVK
//  File name: MediaViewController.swift
//
//  Copyright © Gromov V.O., 2024
//

import UIKit
import WebKit

class MediaViewController: UIViewController {
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.token = TokenManager.getStoredToken()?.token ?? "no_token"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: -  Properties

    var photo: [VKPhotoItem] = []
    var video: [VKVideoItem] = []
    
    var photoCache: [Int:UIImage] = [:] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    var videoCache: [Int:UIImage] = [:] {
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    var token: String = ""
    var coordinator: Coordinator?
    var groupID: Int = 0
    
    // MARK: - UI elements

    
    var activityIndicator: UIActivityIndicatorView!
    
    let segmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl()
        sc.insertSegment(withTitle: Strings.photoSegmentName, at: 0, animated: true)
        sc.insertSegment(withTitle: Strings.videoSegmentName, at: 1, animated: true)
        sc.selectedSegmentIndex = 0
        sc.translatesAutoresizingMaskIntoConstraints = false
        return sc
    }()
    
    private let collectionView: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        return collection
    }()
        
        private let columnLayout: UICollectionViewFlowLayout = {
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumInteritemSpacing = 4
            layout.minimumLineSpacing = 4
            return layout
        }()
        
    
    // MARK: - lifecycle

    
    override func viewDidLoad() {
        setupViews()
        startFetching()
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.token = TokenManager.getStoredToken()?.token ?? "no_token"
        showLoading()
    }
    
    // MARK: - setup views

    private func setupViews() {
        view.backgroundColor = .systemBackground
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(CustomCell.self, forCellWithReuseIdentifier: "NewCell")
        collectionView.collectionViewLayout = columnLayout
        
        navigationItem.hidesBackButton = true
        navigationItem.title = Strings.welcomeSign
        let signOutButton = UIBarButtonItem(title: Strings.signOutButton, style: .plain, target: self, action: #selector(signOut))
        signOutButton.tintColor = .whiteDarkBlackLight
        navigationItem.rightBarButtonItem = signOutButton
        self.navigationItem.backButtonTitle = ""
        
        view.addSubview(segmentedControl)
        segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        segmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 10).isActive = true
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        setupActivityIndicator()
    }
    

    
    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
            case 0:
            collectionView.reloadData()
            case 1:
            collectionView.reloadData()
            default:
                break
            }
        
       }
    
    @objc private func signOut() {
        coordinator?.showWelcomeScreen()
        photo = []
        photoCache = [:]
        video = []
        videoCache = [:]
        WKWebView.clearAllWebsiteData()
        segmentedControl.selectedSegmentIndex = 0
        TokenManager.clearToken()
    }
}

// MARK: - Fetching

extension MediaViewController {
    
    func startFetching() {
        NetworkManager.shared.getVKGroupID(withName: Strings.groupName, token: token) { result in
            switch result {
            case .success(let success):
                self.groupID = success
                self.fetchPhoto()
                self.fetchVideo()
            case .failure(let failure):
                print(failure)
                self.showAlert(title: failure.localizedDescription, message: "")
            }
        }
    }
    func fetchPhoto() {
        NetworkManager.shared.getVKGroupPhotoURLs(withToken: token, forID: groupID) { result in
            switch result {
            case .success(let success):
                self.photo = success
                self.downloadPhoto(firstIndex: 0, lastIndex: 20)
            case .failure(let failure):
                print(failure)
                self.showAlert(title: failure.localizedDescription, message: "")
            }
        }
    }
    
    func downloadPhoto(firstIndex: Int, lastIndex: Int) {
        if photo.isEmpty {
            print(MobileUpProjectError.downloadPhotoError("Nothing to download. MediaViewController"))
            self.showAlert(title: MobileUpProjectError.downloadPhotoError("").localizedDescription, message: "Nothing to download. MediaViewController")
        }
        for i in firstIndex..<lastIndex {
            NetworkManager.shared.stringURLToUIImage(url: photo[i].origPhoto.url) { result in
                switch result {
                case .success(let image):
                    self.photoCache[i] = image
                case .failure(let failure):
                    print(failure)
                    self.showAlert(title: failure.localizedDescription, message: "")
                }
            }
        }
    }
    
    func fetchVideo() {
        NetworkManager.shared.getVKGroupVideo(withToken: token, forID: groupID) { result in
            switch result {
            case .success(let video):
                self.video = video
                self.downloadVideo(firstIndex: 0, lastIndex: 20)
            case .failure(let failure):
                print(failure)
                self.showAlert(title: failure.localizedDescription, message: "")
            }
        }
    }
    
    func downloadVideo(firstIndex: Int, lastIndex: Int) {
        for i in firstIndex..<lastIndex {
            NetworkManager.shared.stringURLToUIImage(url: video[i].image.last!.url) { result in
                switch result {
                case .success(let image):
                    self.videoCache[i] = image
                case .failure(let failure):
                    print(failure)
                    self.showAlert(title: failure.localizedDescription, message: "")
                }
            }
            
        }
    }
}

// MARK: - activity indicator

extension MediaViewController {
    
    func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.hideLoading()
        }
    }
    
    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.activityIndicator.stopAnimating()
        }
    }
}


// MARK: - Collection delegate
extension MediaViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch segmentedControl.selectedSegmentIndex {
        case 0: photoCache.count
        case 1: videoCache.count
        default: 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewCell", for: indexPath) as! CustomCell
        
        switch segmentedControl.selectedSegmentIndex {
        case 0: cell.imageView.image = photoCache[indexPath.item]
            cell.label.text = ""
            cell.label.isHidden = true
        case 1: cell.imageView.image = videoCache[indexPath.item]
            cell.label.text = video[indexPath.item].title
            cell.label.isHidden = false
        default: return cell
        }
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        switch segmentedControl.selectedSegmentIndex {
        case 0: let width = (collectionView.bounds.width - 4) / 2 // space between columns
            return CGSize(width: width, height: width) // square cells
        case 1: let width = (collectionView.bounds.width)
            return CGSize(width: width, height: width * 0.7 )
        default: print(MobileUpProjectError.collectionViewFlowError("MediaViewController"))
            return CGSize(width: 0, height: 0)
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch segmentedControl.selectedSegmentIndex {
        case 0: coordinator?.showDetailView(with: .photo(photo[indexPath.item], photoCache[indexPath.item] ?? UIImage(systemName: "figure.cooldown")!))
        case 1: coordinator?.showDetailView(with: .webView(video[indexPath.item]))
        default: break
        }
        
    }
    
    //TODO: - collectionView willDisplay. Load more images
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        print("shown cell with id", indexPath.item)
    }
    
    
}







