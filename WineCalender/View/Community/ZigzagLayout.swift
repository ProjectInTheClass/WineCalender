//
//  ZigzagLayout.swift
//  ResizableCollectionViewCell
//
//  Created by Susan Kim on 2021/10/28.
//

import UIKit

class ZigzagLayout: UICollectionViewLayout {
    override var collectionViewContentSize: CGSize {
        get {
            return CGSize(width: contentWidth, height: contentHeight)
        }
    }
    
    var layoutAttributes: [UICollectionViewLayoutAttributes] = []
    var contentWidth: CGFloat {
        set {
            columnWidth = newValue / CGFloat(self.columnCount)
        } get {
            return self.columnWidth * CGFloat(self.columnCount)
        }
    }
    
    var contentHeight: CGFloat = 0
    var columnWidth: CGFloat = 0
    var columnCount: Int = 2
    var cellInset: UIEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    var originY: [CGFloat] = []

    override func prepare() {
        super.prepare()
        
        guard let controller = collectionView?.dataSource as? Community, let collectionView = collectionView else { return }
        // offset
        originY = [CGFloat](repeating: 0, count: columnCount)
        contentHeight = 0
        
        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                // find min column
                let column = originY.enumerated().min { $0.element < $1.element }?.offset ?? 0
                let x = CGFloat(column) * columnWidth + cellInset.left
                let y = originY[column] + cellInset.top
                let width = columnWidth - cellInset.left - cellInset.right
                let height : CGFloat = controller.posts[indexPath.row].post.tastingNote.memo == nil ? 270 : 320
                attributes.frame = CGRect(x: x, y: y, width: width, height: height)
                originY[column] += height + cellInset.bottom
                if contentHeight < originY[column] {
                    contentHeight = originY[column]
                }
                layoutAttributes.append(attributes)
            }
        }
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleAttributes: [UICollectionViewLayoutAttributes] = []
        for attributes in layoutAttributes {
            if rect.intersects(attributes.frame) {
                visibleAttributes.append(attributes)
            }
        }
        return visibleAttributes
    }
}
