// Copyright 2022 Neeva Inc. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import SDWebImage
import Shared
import UIKit

enum ImageContextAction: String, CaseIterable {
    case saveImage = "Save Image"
    case copyImage = "Copy Image"
    case copyImageLink = "Copy Image Link"
    case addToSpace = "Add to Space"
    case addToSpaceWithImage = "Add to Space with Image"

    var title: String {
        return rawValue
    }
}

enum ImageContextUX {
    static let itemHeight: CGFloat = 40
    static let itemWidth: CGFloat = 240
    static let tableCornerRadius: CGFloat = 12
    static let itemSpacing: CGFloat = 8
}

class ImageContextMenu: UIViewController {

    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
        let view = UIVisualEffectView(effect: blurEffect)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.alpha = 0.95
        return view
    }()

    private let tableView: SelfSizingTableView = {
        let tableView = SelfSizingTableView()
        tableView.register(
            ImageContextMenuTableViewCell.self, forCellReuseIdentifier: "ContextMenuItem")
        tableView.layer.cornerRadius = ImageContextUX.tableCornerRadius
        tableView.backgroundColor = .DefaultBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.estimatedRowHeight = ImageContextUX.itemHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.bounces = false
        tableView.separatorInset = .zero
        tableView.isScrollEnabled = false
        tableView.isHidden = true
        tableView.sectionHeaderTopPadding = 0
        return tableView
    }()

    private let imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .DefaultBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = ImageContextUX.tableCornerRadius
        view.isHidden = true
        return view
    }()

    private let loadingView: UIView = {
        let view = UIView()
        view.backgroundColor = .DefaultBackground
        view.layer.cornerRadius = ImageContextUX.tableCornerRadius
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.tintColor = .DefaultBackground
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    private let baseDomainLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        label.font = FontStyle.labelMedium.uiFont(for: .small)
        label.numberOfLines = 1
        return label
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let elements: ContextMenuHelper.Elements!
    private var imageViewWidth: NSLayoutConstraint?
    private var imageViewHeight: NSLayoutConstraint?
    private let onSelection: ((ImageContextAction) -> Void)!

    private var dataSource: [ImageContextAction] {
        return ImageContextAction.allCases
    }

    init(
        elements: ContextMenuHelper.Elements,
        onSelection: @escaping ((ImageContextAction) -> Void)
    ) {
        self.elements = elements
        self.onSelection = onSelection
        self.baseDomainLabel.text = elements.image?.baseDomain ?? ""
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        view.isOpaque = false
        modalPresentationStyle = .overCurrentContext
        modalTransitionStyle = .crossDissolve
        tableView.dataSource = self
        tableView.delegate = self
        configureViews()
        setActions()
        downloadAndSetImage(elements.image)
        Haptics.longPress()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }

}

extension ImageContextMenu {
    private func configureViews() {
        view.addSubviews(blurEffectView, imageContainerView, tableView, loadingView)
        blurEffectView.makeAllEdges(equalTo: view)
        imageContainerView.makeEdges(
            .leading, greaterThanOrequalTo: view,
            withOffset: ImageContextUX.itemSpacing)
        imageContainerView.makeEdges(
            .trailing, lessThanOrEqualTo: view,
            withOffset: -ImageContextUX.itemSpacing)
        imageContainerView.makeCenterX(equalTo: view)
        imageContainerView.heightAnchor.constraint(
            greaterThanOrEqualToConstant: 100
        ).isActive = true
        imageContainerView.widthAnchor.constraint(
            greaterThanOrEqualToConstant: 100
        ).isActive = true
        imageContainerView.bottomAnchor.constraint(
            equalTo: view.centerYAnchor,
            constant: ImageContextUX.itemHeight
        ).isActive = true
        imageContainerView.topAnchor.constraint(
            greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor,
            constant: ImageContextUX.itemSpacing
        ).isActive = true
        tableView.makeEdges(.trailing, equalTo: imageContainerView)
        tableView.makeWidth(equalToConstant: ImageContextUX.itemWidth)
        tableView.topAnchor.constraint(
            equalTo: imageContainerView.bottomAnchor,
            constant: ImageContextUX.itemSpacing
        ).isActive = true
        loadingView.makeCenter(equalTo: view)
        loadingView.makeHeight(equalToConstant: 100)
        loadingView.makeWidth(equalToConstant: 100)
        configureImageContainerView()
        configureLoadingView()
    }

    private func configureImageContainerView() {
        imageContainerView.addSubviews(imageView, baseDomainLabel)
        imageView.makeEdges([.leading, .trailing, .top], equalTo: imageContainerView)
        imageView.bottomAnchor.constraint(
            equalTo: baseDomainLabel.topAnchor
        ).isActive = true
        baseDomainLabel.makeEdges(
            [.leading, .trailing], equalTo: imageContainerView,
            withOffset: 2 * ImageContextUX.itemSpacing)
        baseDomainLabel.makeEdges(.bottom, equalTo: imageContainerView)
        baseDomainLabel.makeHeight(equalToConstant: 40)
    }

    private func configureLoadingView() {
        loadingView.addSubviews(loadingIndicator)
        loadingIndicator.makeAllEdges(equalTo: loadingView)
    }

    private func setActions() {
        blurEffectView.isUserInteractionEnabled = true
        blurEffectView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(onBlurViewTap)))
    }
}

extension ImageContextMenu {
    fileprivate func downloadAndSetImage(_ url: URL?) {
        loadingIndicator.startAnimating()
        SDWebImageManager.shared.loadImage(with: url, progress: nil) {
            [weak self] image, _, _, _, _, _ in
            guard let self = self, let image = image else { return }
            self.imageView.image = image
            self.imageView.heightAnchor.constraint(
                equalTo: self.imageView.widthAnchor,
                multiplier: image.size.height / image.size.width
            ).isActive = true
            self.loadingIndicator.stopAnimating()
            self.loadingView.removeFromSuperview()
            self.imageContainerView.isHidden = false
            self.tableView.isHidden = false
        }
    }
}

extension ImageContextMenu {
    @objc private func onBlurViewTap() {
        dismiss(animated: true)
    }
}

extension ImageContextMenu: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =
            tableView.dequeueReusableCell(withIdentifier: "ContextMenuItem", for: indexPath)
            as? ImageContextMenuTableViewCell
        cell?.configure(with: dataSource[indexPath.item])
        return cell!
    }
}

extension ImageContextMenu: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.onSelection(self.dataSource[indexPath.item])
        }
    }
}

private class SelfSizingTableView: UITableView {

    override var intrinsicContentSize: CGSize {
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }

    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
}

private class ImageContextMenuTableViewCell: UITableViewCell {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureViews()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureViews()
    }
}

extension ImageContextMenuTableViewCell {
    func configure(with action: ImageContextAction) {
        titleLabel.text = action.title
    }
}

extension ImageContextMenuTableViewCell {
    private func configureViews() {
        backgroundColor = .clear
        contentView.addSubview(titleLabel)
        titleLabel.makeEdges(
            .leading, equalTo: contentView, withOffset: 2 * ImageContextUX.itemSpacing)
        titleLabel.makeEdges(
            .trailing, equalTo: contentView, withOffset: 2 * -ImageContextUX.itemSpacing)
        titleLabel.makeEdges(
            .top, equalTo: contentView, withOffset: ImageContextUX.itemSpacing)
        titleLabel.makeEdges(
            .bottom, equalTo: contentView, withOffset: -ImageContextUX.itemSpacing)
    }
}
