# Crescent

## About
マルコフ連鎖を使った人工無能です。
現在はCUIとTwitterのみ対応しています。

## Install
Ruby(rbenv)、PostgreSQLを入れた後bundle install。
また、PostgreSQLのユーザーも作成しておく。
その後、

    rake db:config // データベースの設定を入力
    rake db:create 
    rake db:table
    rake auth      // Twitterのアクセストークンを入力

たぶんこんな感じだったと思うけどそのうち詳しく書く

## Using
    ruby main.rb t // tはTwitter起動
たまに落ちるのでシェルのwhileで起こしてる