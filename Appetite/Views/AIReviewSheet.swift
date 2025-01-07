//
//  AIReviewSheet.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 1/4/25.
//

import SwiftUI

struct AIReviewSheet: View {
    @StateObject var vm = AIReviewSheetViewModel()
    let request:RequestModel
    var body: some View {
        NavigationStack{
            ScrollView{
                messageBubble(message: "私の言葉全部信用しちゃ、ダメだよ！！")
                
                if !vm.displayedText.isEmpty{
                    messageBubble(message: vm.displayedText)
                        .transition(.slide)
                        .animation(.spring, value: vm.displayedText.isEmpty)
                }else{
                    messageBubble(message: "....")
                }
                
            }
            .alert(isPresented: $vm.showAlert) {
                Alert(
                    title: Text("エラー"),
                    message: Text(vm.alertMessage),
                    dismissButton: .cancel()
                )
            }
            .onAppear {
                vm.makeRequest(request: request)
            }

            .navigationTitle("チャットアウンくん！！")
        }
    }
    private func messageBubble(message:String)->some View{
        HStack(alignment: .bottom, spacing: 8) {
            // Robot profile image
            Image(.robot) // Make sure to add your robot image to assets
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .padding(.bottom, 8)
            
            // Message bubble
            VStack(alignment: .leading, spacing: 4) {
                Text(message)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.blue)
                    )
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)

    }
}
