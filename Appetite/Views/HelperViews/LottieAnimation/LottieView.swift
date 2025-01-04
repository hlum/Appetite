//
//  LottieView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/31/24.
//

import Lottie
import SwiftUI

// In PaddingLabel class, adjust the horizontal padding:
class PaddingLabel: UILabel {
    var textInsets = UIEdgeInsets(top: 15, left: 25, bottom: 15, right: 25) // Added horizontal padding
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
    // Add this to ensure the intrinsic content size includes our padding
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + textInsets.left + textInsets.right,
                     height: size.height + textInsets.top + textInsets.bottom)
    }
}

struct LottieView: UIViewRepresentable {
    
    
    var name: String
    let loopMode: LottieLoopMode
    let labelText: String?
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        
        // Lottie animation view setup
        let animationView = LottieAnimationView(name: name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play() { finished in }
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        if labelText != nil{
            let label = PaddingLabel()
            label.text = labelText
            label.textColor = .systemWhite
            label.textAlignment = .center
            label.backgroundColor = .systemBlack
            label.font = .systemFont(ofSize: 15)
            label.layer.cornerRadius = 10
            label.layer.masksToBounds = true
            label.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(label)
            
            // Setting constraints for the label
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: animationView.bottomAnchor, constant: 2),
                label.centerXAnchor.constraint(equalTo: view.centerXAnchor), // Center horizontally
                label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        }
        
        // Setting constraints for the animation view
        NSLayoutConstraint.activate([
            animationView.topAnchor.constraint(equalTo: view.topAnchor),
            animationView.leftAnchor.constraint(equalTo: view.leftAnchor),
            animationView.rightAnchor.constraint(equalTo: view.rightAnchor),
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.8) // Adjust height if necessary
        ])
        view.backgroundColor = .clear
        return view

    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        // Update code if necessary
    }
}


