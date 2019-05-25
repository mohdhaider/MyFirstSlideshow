//
//  ImagesViewController.swift
//  MyFirstSlideshow
//
//  Created by Charles Vu on 17/05/2017.
//  Copyright © 2017 Yoti. All rights reserved.
//

import UIKit

class ImagesViewController: UIViewController {
    
    // MARK:- IBOutlets -
    
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var currentIndexPageControl: UIPageControl!
    
    // MARK:- Variables -
    
    enum ButtonType: Int {
        case next
        case prev
    }
    
    private lazy var viewModel = ImagesViewModel()
    
    private let imageCellReuseIdentifier = "ImageCell"
    
    // MARK:- Controller Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doInitialSetup()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        deviceOrientation()
    }
    
    func deviceOrientation() {

        reloadCollectionView()
        showImage(forPageIndex: currentIndexPageControl.currentPage, withAnimation: false)
    }
    
    // MARK:- Class Helpers -
    
    private func doInitialSetup() {
        
        dataBinding()
        setupCollectionView()
        setupPageControl()
        viewModel.prpareDataSource()
    }
    
    private func dataBinding() {
        
        viewModel.souldRefresh.singleBind {[weak self] (shouldRefresh) in
            
            self?.reloadCollectionView()
        }
    }
    
    private func showImage(forPageIndex index: Int, withAnimation animated: Bool) {
        
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
    // MARK:- PageControl Helpers -
    
    func setupPageControl() {
        
        currentIndexPageControl.numberOfPages = 0
        currentIndexPageControl.currentPage = 0
    }
    
    // MARK:- CollectionView Helpers -
    
    private func setupCollectionView() {
        
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: Bundle.main),
                                forCellWithReuseIdentifier: imageCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    private func reloadCollectionView() {
        
        moveToMainThread {[weak self] in
            self?.currentIndexPageControl.numberOfPages = self?.viewModel.arrImages.count ?? 0
            self?.collectionView.reloadData()
        }
    }
    
    // MARK:- Actions -
    
    @IBAction private func buttonDirectionSelected(_ button: UIButton) {
        
        switch button.tag {
        case ButtonType.next.rawValue:
            
            if currentIndexPageControl.currentPage + 1 < viewModel.arrImages.count {
               currentIndexPageControl.currentPage += 1
                showImage(forPageIndex: currentIndexPageControl.currentPage, withAnimation: true)
            }
            
        case ButtonType.prev.rawValue:

            if currentIndexPageControl.currentPage - 1  >= 0 {
                currentIndexPageControl.currentPage -= 1
                showImage(forPageIndex: currentIndexPageControl.currentPage, withAnimation: true)
            }
            
        default:
            break
        }
    }
    
    @IBAction private func pageIndexChanged(_ pageControl: UIPageControl) {
        
        showImage(forPageIndex: pageControl.currentPage, withAnimation: true)
    }
}

extension ImagesViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
}

extension ImagesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        
    }
}

extension ImagesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellReuseIdentifier, for: indexPath)
        
        if let imageCell = cell as? ImageCollectionViewCell,
            indexPath.row < viewModel.arrImages.count {
            
            imageCell.setup(viewModel.arrImages[indexPath.row])
        }
        return cell
    }
}
