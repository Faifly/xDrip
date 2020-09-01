//
//  FoodTextInputTableViewCell.swift
//  xDrip
//
//  Created by Ivan Skoryk on 05.06.2020.
//  Copyright © 2020 Faifly. All rights reserved.
//

import UIKit

final class FoodTextInputTableViewCell: UITableViewCell {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var textField: UITextField!
    
    private var emojis = FoodEmojiDataSource()
    
    var didEditingChange: ((String?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        titleLabel.text = "edit_food_entry_type_of_food".localized
        textField.placeholder = "edit_food_entry_type_of_food_textfield_placeholder".localized
        textField.delegate = self
        
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
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
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
            layout.sectionFootersPinToVisibleBounds = true
        }
    }
    
    func configurate(with foodType: String?) {
        textField.text = foodType
    }
    
    @IBAction private func textFieldEditingChanged(_ sender: Any) {
        didEditingChange?(textField.text)
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

extension FoodTextInputTableViewCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension FoodTextInputTableViewCell: UICollectionViewDataSource {
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

extension FoodTextInputTableViewCell: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        textField.text?.append(emojis.sections[indexPath.section].items[indexPath.row])
        didEditingChange?(textField.text)
    }
}
