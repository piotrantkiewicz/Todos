import UIKit

struct ColorOption {
    let color: UIColor
    let isSelected: Bool
}

class ColorOptionCell: UICollectionViewCell {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var checkmarkView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        colorView.setCornerRadius(16)
    }

    func configure(with option: ColorOption) {
        colorView.backgroundColor = option.color
        checkmarkView.isHidden = !option.isSelected
    }
}
