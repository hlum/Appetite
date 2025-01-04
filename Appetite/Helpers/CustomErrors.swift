//
//  CustomErrors.swift
//  Appetite
//
//  Created by Hlwan Aung Phyo on 12/25/24.
//

import Foundation
enum CustomErrors: Error, LocalizedError {
    
    // エラーケースを定義
    case NoDataFound
    case InvalidURL
    case LocationPermissionDenied

    // エラーのローカライズされた説明を提供
    var errorDescription: String? {
        switch self {
        case .NoDataFound:
            return NSLocalizedString(
                "データが見つかりませんでした。",
                comment: "データが見つからないエラー"
            )
        case .InvalidURL:
            return NSLocalizedString(
                "URLが無効です。",
                comment: "無効なURLエラー"
            )
        case .LocationPermissionDenied:
            return NSLocalizedString(
                "位置情報へのアクセス許可が拒否されました。",
                comment: "位置情報許可が拒否されたエラー"
            )
        }
    }
}

