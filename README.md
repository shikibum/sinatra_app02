# sinatra_app02
Fjord Boot Campプラクティス「SinatraでシンプルなWebアプリを作ろう」の提出物
- 追加はPOSTメソッド、編集はPATCHメソッド、削除はDELETEメソッドで実装すること。
  - HTMLのformはPATCHやDELETEメソッドを使えないので変わりにMethodOverrideを使うこと。（_methodにDELETEとかを入れておくとそのメソッドとして処理してくれるやつ）
Class: Rack::MethodOverride
- データはファイルに保存すること。（DBを使わないこと）
