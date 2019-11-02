//
//  WGImagePreviewController.swift
//  ImagePreviewDemo
//
//  Created by Gerry Wang on 02/11/2019.
//  Copyright © 2019 Gerry Wang. All rights reserved.
//

import UIKit

class WGImagePreviewController: UIViewController {

    public lazy var imageView : UIImageView = {
        let view = UIImageView()
        view.image = image
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    public var image : UIImage = {
        let image = UIImage(named: "p3.jpg")!
        return image
        }() {
        didSet {
            imageView.image = self.image
        }
    }
    
    private lazy var contentView : UIView = {
        let view = UIView()
        return view
    }()
    
    @objc func doubleTapAction(gest : UITapGestureRecognizer) -> () {
        switch modeFlag {
        case .scaleAspectFit:
            scrollView.zoomScale = fillSizeScale
            modeFlag = .scaleAspectFill
        case .scaleAspectFill:
            scrollView.zoomScale = minSizeScale
            modeFlag = .scaleAspectFit
        default:
            break
        }
    }
    
    var modeFlag : UIView.ContentMode = .scaleAspectFit
    
    lazy var scrollView : UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.contentInsetAdjustmentBehavior = .never
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = true
        view.backgroundColor = UIColor.clear
        view.showsVerticalScrollIndicator = false
        view.showsHorizontalScrollIndicator = false
        view.maximumZoomScale = maxSizeScale
        view.minimumZoomScale = minSizeScale
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(gest:)))
        doubleTap.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTap)
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        initUI()
    }
    
    override func viewDidLayoutSubviews() {
        initContentViewAndImageViewToFitSizeFrame()
        super.viewDidLayoutSubviews()
    }
    
    func initUI() -> () {
        view.backgroundColor = UIColor.black
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(imageView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
    }
    
    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        view.setNeedsLayout()
    }

    func initContentViewAndImageViewToFitSizeFrame() -> () {
        contentView.frame = CGRect(x: 0, y: 0, width: fitSize.width, height: fitSize.height)
        imageView.frame = contentView.bounds
        adjustScrollViewContenInset()
    }
    
    /// 调整content inset. 图片初始化时加载为scale aspect fit大小, 设定scrollview的inset, 以让content view能够居中
    /// 在图片缩小和放大的时候, 需要不断调整inset, 当图片的宽度或者高度大于屏幕宽度时, 就把相关的方向赋值为0
    private func adjustScrollViewContenInset() -> () {
        let top : CGFloat = kscreenHeight - contentView.frame.size.height > 0 ? (kscreenHeight - contentView.frame.size.height) / 2 : 0
        let left : CGFloat = kscreenWidth - contentView.frame.size.width > 0 ? (kscreenWidth - contentView.frame.size.width) / 2 : 0
        scrollView.contentInset = UIEdgeInsets(top:top, left: left, bottom: top, right: left)
    }
    
    // MARK: - 计算
    /// 最小的缩放倍数为1.0, 1.0时加载的大小为图像的aspectfit图像大小
    private let minSizeScale : CGFloat = 1.0
    
    /// fill size scale 通过计算fill size的宽度 / fit size的宽度取得
    private var fillSizeScale : CGFloat {
        return fillSize.width / fitSize.width
    }
    
    /// 最大的放大倍数取fill的放大倍数 * 1.5倍
    private var maxSizeScale : CGFloat {
        return fillSizeScale * 1.5
    }
    
    let kscreenWidth = UIScreen.main.bounds.width
    let kscreenHeight = UIScreen.main.bounds.height
    
    var whRatio_image : CGFloat {
        return image.size.width / image.size.height
    }
    
    var whRatio_screen : CGFloat {
        return kscreenWidth / kscreenHeight
    }
    
    private var fitSize : CGSize {
        var size = CGSize.zero
        if whRatio_image > whRatio_screen {
            size = CGSize(width: kscreenWidth, height: kscreenWidth / whRatio_image)
        }else {
            size = CGSize(width: kscreenHeight * whRatio_image, height: kscreenHeight)
        }
        return size
    }
    
    private var fillSize : CGSize {
        var size = CGSize.zero
        if whRatio_image > whRatio_screen {
            size = CGSize(width: kscreenHeight * whRatio_image, height: kscreenHeight)
        }else {
            size = CGSize(width: kscreenWidth, height: kscreenWidth / whRatio_image)
        }
        return size
    }
}

extension WGImagePreviewController : UIScrollViewDelegate {
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if scrollView.zoomScale <= minSizeScale {
            modeFlag = .scaleAspectFit
        }
        else if scrollView.zoomScale >= fillSizeScale {
            modeFlag = .scaleAspectFill
        }
        adjustScrollViewContenInset()
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
}
