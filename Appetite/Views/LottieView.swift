//
//  LottieView.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/31/24.
//

import Lottie
import SwiftUI


struct LottieView:UIViewRepresentable{
    
    var name:String
    let loopMode:LottieLoopMode
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView(frame: .zero)
        
        let animationView = LottieAnimationView(name:name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play(){(finished) in
        }
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}
