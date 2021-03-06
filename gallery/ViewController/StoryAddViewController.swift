//
//  StoryAddViewController.swift
//  gallery
//
//  Created by nothing on 9/2/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa
import MBProgressHUD

class StoryAddViewController: UIViewController {
    
    private lazy var detailView: StoryDetailView = {
        StoryDetailView()
    }()
    
    private var disposeBag = DisposeBag()
    
    var images: [UIImage]?
    
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setup()
        
        detailView.images = images
        if let images = images, images.count > 0 {
            detailView.selectedThumbnailIndex = 0
        }
        let imageCount: Int = images?.count ?? 0
        detailView.photoCountLabel.text = "\(imageCount)개의 사진"
        
    }    
    
    
    // MARK: - private
    private func save() {
        let dv = detailView
        let title = dv.titleTextField.text
        let content = dv.descriptionTextView.text
        let selectedThumbnailIndex = dv.selectedThumbnailIndex
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        navigationController?.view.isUserInteractionEnabled = false
        Storage.createStory(title, content, images ?? [], selectedThumbnailIndex) {
            self.navigationController?.view.isUserInteractionEnabled = true
            MBProgressHUD.hide(for: self.view, animated: true)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    private func setup() {
        
        // layout
        
        view.addSubview(detailView)
        detailView.snp.makeConstraints { (make) in            
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.leading.equalTo(view)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: nil, action: nil)
        navigationItem.rightBarButtonItem?.rx.tap
            .bind(onNext: { [weak self] _ in
                guard let `self` = self else { return }
                self.save()
            })
            .addDisposableTo(disposeBag)
        
        let longTapGesture = UILongPressGestureRecognizer()
        detailView.collectionView.addGestureRecognizer(longTapGesture)
        longTapGesture.rx.event
            .bind { e in
                if e.state == UIGestureRecognizerState.began {
                    self.showImagesInFullViewController(at: self.detailView.selectedThumbnailIndex ?? 0)
                }
            }
            .addDisposableTo(disposeBag)
        
        // style
        title = "New"
    }

}

extension StoryAddViewController: ImagePresentableProtocol {}

