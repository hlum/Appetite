# Appetite

## 作者
ラワンアウピョウ

## アプリ名
Appetite

## コンセプト
値段、場所、ジャンル、特定のフィルターで絞り込んで、食べに行きたいお店がすぐ見つかる。  
AIの評価を参考にお店を選べる。

## こだわったポイント
- AIボタンを自由にどこにでも配置できるようにしました。
- ユーザーの意図に応えられるよう設計しました（レストランプレビューのスワイプジェスチャー）。
- 検索範囲を現在表示しているマップの範囲内に指定できるようにしました。
- お店のジャンルによってマーカーのデザインを変えました。

## デザイン面でこだわったポイント
- Darkmode のデザインも工夫しました。
- レストランのプレビュー画面の移動をスムーズで快適に使えるように工夫しました。
- できるだけシンプルでわかりやすく、快適に使えるよう心がけて作りました。

## 開発環境
- Xcode 16.0

## 開発言語
- Swift 6.0

## 動作対象端末・OS
- 動作対象OS: iOS 17.0

## 開発期間
14日間

## アプリケーション機能

### 機能一覧
- 位置情報取得の許可が拒否された場合、アラートでユーザーを設定画面まで誘導する。
- インターネット接続がない場合も、アラートでユーザーに通知する。
- **レストラン検索**：ホットペッパーグルメサーチAPIを使用し、現在地周辺の飲食店を検索。
- **レストラン情報取得**：ホットペッパーグルメサーチAPIを使用して、飲食店の詳細情報を取得。
- レストラン周辺のストリートビューを表示。
- ルート案内（公共交通機関の場合はGoogle MapsまたはApple Mapsに誘導）。
- Perplexity APIを利用してレストランの評価を生成。
  
- **現在表示中のマップ範囲内で検索範囲を指定可能。**
- 
  ![](https://github.com/hlum/Appetite/blob/main/Simulator%20Screen%20Recording%20-%20iPhone%2016%20Pro%20-%202025-01-08%20at%2013.42.05%20(1)%20(1).gif)


### 画面一覧
- **検索画面**：条件を指定してレストランを検索。
- **一覧画面**：初回はユーザーの近くのレストラン一覧を表示、検索後は結果を一覧表示。
- **フィルター選択画面**：フィルターの選択や解除が可能。検索画面と同期して更新。
- **詳細画面**：お店の詳細情報を表示。
- **プレビュー画面**：お店の名前、営業時間、ジャンル、半径距離を表示。AI評価ボタンを自由に配置可能。
- **ストリートビュー画面**：お店周辺の風景を確認。
- **AI評価画面**：チャット形式でレストランの評価を表示（ユーザーからの入力は不可）。


#### プレビュー画面スワイプ機能
- **上**：詳細画面を表示（スワイプ中にシートが開くような演出）。
- **下**：プレビューを閉じ、選択中のレストランを解除。
- **左**：次のレストランへ移動。
- **右**：前のレストランへ戻る。

## 使用しているAPI・SDK・ライブラリ
- ホットペッパーグルメサーチAPI
- Pod
- Perplexity API
- SDWebImage
- Lottie

## アドバイスしてほしいポイント
- 検索結果を100件以上表示したいが、動作が重くなってしまう。改善方法についてのアドバイス。
- 詳細画面をもっとおしゃれに作りたい。
- 営業時間の表示をよりきれいにフォーマットしたい。
- コードの可読性やフォーマットについてアドバイスがほしい。
