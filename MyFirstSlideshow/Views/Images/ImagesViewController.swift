//
//  ImagesViewController.swift
//  MyFirstSlideshow
//
//  Created by Charles Vu on 17/05/2017.
//  Copyright © 2017 Yoti. All rights reserved.
//

import UIKit

/// Images presenting screen to show images via horizontal scrolling.
class ImagesViewController: UIViewController {
    
    // MARK:- IBOutlets -
    
    /// Show infinite number of image via horizontal scrolling.
    @IBOutlet private weak var collectionView: UICollectionView!
    
    /// To showing current page index of image
    @IBOutlet private weak var currentIndexPageControl: UIPageControl!
    
    // MARK:- Variables -
    
    
    /// Describe next and previous button type.
    /// We can use this enum to distinguish button. So that
    /// we can take action accordingly.
    /// - next: next button tag
    /// - prev: previous button tag
    enum ButtonType: Int {
        case next
        case prev
    }
    
    /// Conetoller's view model to handle all busineess logic.
    private lazy var viewModel = ImagesViewModel()
    
    /// Collection view cell identifier to load collection view cell.
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
    
    /// Update view layout on device orientation.
    func deviceOrientation() {

        reloadCollectionView()
        showImage(forPageIndex: currentIndexPageControl.currentPage, withAnimation: false)
    }
    
    // MARK:- Class Helpers -
    
    /// Inital setup for UI components. It will take care of all view's data binding,
    /// collection view and page index setup. Prepare data source for current screen.
    /// We can improve this functionality if we need to introduce data fetching from
    /// network api call.
    private func doInitialSetup() {
        
        dataBinding()
        setupCollectionView()
        setupPageControl()
        viewModel.prpareDataSource()
    }
    
    /// Required data binding from view model. So that we can take action accordingly.
    /// Currently, we are observering collection view refresh calls.
    private func dataBinding() {
        
        viewModel.souldRefresh.singleBind {[weak self] (shouldRefresh) in
            
            self?.reloadCollectionView()
        }
    }
    
    /// Give instruction to collection view to load image accroding to input index.
    ///
    /// - Parameters:
    ///   - index: image index
    ///   - animated: Animate changes
    private func showImage(forPageIndex index: Int, withAnimation animated: Bool) {
        
        collectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .centeredHorizontally, animated: animated)
    }
    
    // MARK:- PageControl Helpers -
    
    /// setting up initial page control feature.
    func setupPageControl() {
        
        currentIndexPageControl.numberOfPages = 0
        currentIndexPageControl.currentPage = 0
    }
    
    // MARK:- CollectionView Helpers -
    
    /// settting up initial collection view handling.
    /// Registering all required collection view cells.
    /// Setting up it's datasource and delegate.
    private func setupCollectionView() {
        
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: Bundle.main),
                                forCellWithReuseIdentifier: imageCellReuseIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    /// Refreesh collection on main thread. So that we can make sure not to get any
    /// UI changes from background thread.
    private func reloadCollectionView() {
        
        moveToMainThread {[weak self] in
            self?.currentIndexPageControl.numberOfPages = self?.viewModel.arrImages.count ?? 0
            self?.collectionView.reloadData()
        }
    }
    
    // MARK:- Actions -
    
    /// Detect next and previous button actions.
    /// It will show next or previous image according to input.
    /// - Parameter button: Next or previous button
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
    
    /// Detect changes to page index on user inetraction.
    /// It will show next or previosu image accroding to page control current index.
    /// - Parameter pageControl: Page control to show current page index.
    @IBAction private func pageIndexChanged(_ pageControl: UIPageControl) {
        
        showImage(forPageIndex: pageControl.currentPage, withAnimation: true)
    }
}

extension ImagesViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        /// Setting up collection view item size to fit for collection view frame.
        return CGSize(width: collectionView.frame.size.width, height: collectionView.frame.size.height)
    }
}

extension ImagesViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        /// Delect user inetraction on any collection view cell(image).
    }
}

// MARK: - Provide
extension ImagesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        /// Providing information to collection view that how many items(images), it needed to show.
        return viewModel.arrImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        /// Fetching collection view cell by using it's reusability feature.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellReuseIdentifier, for: indexPath)
        
        if let imageCell = cell as? ImageCollectionViewCell,
            indexPath.row < viewModel.arrImages.count {
            
            /// Setting up cell information.
            imageCell.setup(viewModel.arrImages[indexPath.row])
        }
        return cell
    }
}
