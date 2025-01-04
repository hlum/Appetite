//
//  AIReviewSheet.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 1/4/25.
//

import SwiftUI
final class AIReviewSheetViewModel:ObservableObject{
    @Published private var timer: Timer?
    @Published var displayedText:String = ""
    
    @Published var showAlert:Bool = false
    @Published var alertMessage:String = ""
    
    func makeRequest(request:RequestModel){
        Task{
            do{
                let response = try await PerplexityAPIManager.shared.makeRequest(for: request)
                let review = response.choices[0].message.content
                makeTypingEffect(for: review)
                
            } catch let DecodingError.dataCorrupted(context) {
                showAlert(for: "Data corrupted: \(context.debugDescription)")
                print("Data corrupted: \(context)")
            } catch let DecodingError.keyNotFound(key, context) {
                showAlert(for: "Key '\(key.stringValue)' not found: \(context.debugDescription)")
                print("Key not found: \(key), \(context)")
            } catch let DecodingError.typeMismatch(type, context) {
                showAlert(for: "Type mismatch for type \(type): \(context.debugDescription)")
                print("Type mismatch: \(type), \(context)")
            } catch let DecodingError.valueNotFound(value, context) {
                showAlert(for: "Value '\(value)' not found: \(context.debugDescription)")
                print("Value not found: \(value), \(context)")
            } catch {
                showAlert(for: "Unknown error: \(error.localizedDescription)")
                print("Unknown error: \(error)")
            }
        }
    }
    
    private func makeTypingEffect(for text:String){
        var index = 0
        
        // Cancel any existing timer if it's running
        timer?.invalidate()
        
        DispatchQueue.main.async {
            
            
            self.timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) {[weak self] timer in
                if index < text.count {
                    self?.displayedText.append(text[text.index(text.startIndex, offsetBy: index)])
                    index += 1
                } else {
                    timer.invalidate()  // Stop the timer once the text is fully displayed
                }
            }
        }
    }
    
    private func showAlert(for message:String){
        DispatchQueue.main.async {
            self.showAlert = true
            self.alertMessage = message
        }
    }
}

struct AIReviewSheet: View {
    @StateObject var vm = AIReviewSheetViewModel()
    let request:RequestModel
    var body: some View {
        NavigationStack{
            ScrollView{
                messageBubble(message: "私の言葉全部信用しちゃ、ダメだよ！！")
                messageBubble(message: vm.displayedText)
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
