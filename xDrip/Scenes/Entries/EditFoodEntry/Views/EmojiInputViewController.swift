//
//  EmojiInputViewController.swift
//  xDrip
//
//  Created by Ivan Skoryk on 05.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class EmojiInputViewController: UIInputViewController, UICollectionViewDelegateFlowLayout, NibLoadable {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var sectionIndex: UIStackView!

    weak var delegate: EmojiInputControllerDelegate?

    private var emojis: EmojiDataSource = FoodEmojiDataSource()
    
    required init() {
        super.init(nibName: Self.nibName, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        inputView = view as? UIInputView
        inputView?.allowsSelfSizing = true
        view.translatesAutoresizingMaskIntoConstraints = false

        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
            layout.sectionFootersPinToVisibleBounds = true
        }

        collectionView.register(
            UINib(nibName: EmojiInputHeaderView.className, bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: EmojiInputHeaderView.className
        )
        collectionView.register(
            UINib(nibName: EmojiInputCell.className, bundle: nil),
            forCellWithReuseIdentifier: EmojiInputCell.className
        )
        collectionView.register(
            UINib(nibName: EmojiInputFooterView.className, bundle: nil),
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: EmojiInputFooterView.className
        )
        
        setupSectionIndex()
    }

    private func setupSectionIndex() {
        sectionIndex.removeAllArrangedSubviews()

        for (idx, section) in emojis.sections.enumerated() {
            let button = UIButton(frame: .zero)
            button.tag = idx
            button.addTarget(self, action: #selector(indexTouched(_:)), for: .touchUpInside)
            button.setTitle(section.indexSymbol, for: .normal)
            if #available(iOS 13.0, *) {
                button.setTitleColor(.label, for: .normal)
            } else {
                button.setTitleColor(.black, for: .normal)
            }
            sectionIndex.addArrangedSubview(button)
        }
    }

    @IBOutlet private weak var deleteButton: UIButton! {
        didSet {
            if #available(iOS 13.0, *) {
                let image = UIImage(systemName: "delete.left", compatibleWith: traitCollection)
                deleteButton.setImage(image, for: .normal)
            }
        }
    }

    // MARK: - Actions

    @IBAction private func switchKeyboard(_ sender: Any) {
        delegate?.emojiInputControllerDidAdvanceToStandardInputMode(self)
    }

    @IBAction private func deleteBackward(_ sender: Any) {
        inputView?.playInputClick​()
        textDocumentProxy.deleteBackward()
    }

    @objc private func indexTouched(_ sender: UIButton) {
        collectionView.scrollToItem(at: IndexPath(item: 0, section: sender.tag), at: .left, animated: false)
    }
}

extension EmojiInputViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emojis.sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.sections[section].items.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            guard let cell = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: EmojiInputHeaderView.className,
                for: indexPath
            ) as? EmojiInputHeaderView else {
                return UICollectionReusableView()
            }
            
            cell.setLabel(emojis.sections[indexPath.section].title.localizedUppercase)
            
            return cell
        case UICollectionView.elementKindSectionFooter:
            let cell = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: EmojiInputFooterView.className,
                for: indexPath
            )
            
            return cell
        default:
            return UICollectionReusableView()
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(ofType: EmojiInputCell.self, for: indexPath)

        cell.setLabel(emojis.sections[indexPath.section].items[indexPath.row])

        return cell
    }
}

extension EmojiInputViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        inputView?.playInputClick​()
        textDocumentProxy.insertText(emojis.sections[indexPath.section].items[indexPath.row])
    }
}

protocol EmojiInputControllerDelegate: AnyObject {
    func emojiInputControllerDidAdvanceToStandardInputMode(_ controller: EmojiInputViewController)
}

extension UIInputView: UIInputViewAudioFeedback {
    public var enableInputClicksWhenVisible: Bool { return true }

    func playInputClick​() {
        let device = UIDevice.current
        device.playInputClick()
    }
}

private extension UIStackView {
    func removeAllArrangedSubviews() {
        for view in arrangedSubviews {
            view.removeFromSuperview()
        }
    }
}
