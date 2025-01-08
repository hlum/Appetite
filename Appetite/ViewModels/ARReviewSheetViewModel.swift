//
//  ARReviewSheetViewModel.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 1/7/25.
//

import Foundation

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
