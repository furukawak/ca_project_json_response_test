# 利用前に必要な作業手順
1. gem install bundler (※ このスクリプトで必要なgemをbundlerで管理するため)
2. bundle install

# 実行方法 1
目的: APIを叩いて、計算結果JSONファイルを取得する。
1. コンソールから"ruby start_test.rb"を実行する。
2. ディレクトリ"storage/out/YYYYMMDD_HHIISS/json"が作成され、JSONファイルが格納される。

# 実行方法 2
目的: 計算結果JSONファイルをCSVに変換する。
1. コンソールから"ruby start_convert.rb"を実行する。
2. ディレクトリ"storage/out/YYYYMMDD_HHIISS/csv"が作成され、CSVファイルが格納される。
※ ディレクトリ"storage/out/YYYYMMDD_HHIISS"以下に"csv"ディレクトリが存在しなかった場合にのみ実行される。

