# Terraform の初期設定

以下のコマンドで Terraform を初期化し、

- prd
- stg
- dev

の 3 種類のワークスペースを作成する

```
make init
```

# main.tf

main.tf の以下の箇所をプロジェクト名に合わせて変更する
|項目|説明|例|
|---|---|---|
|bucket|tfstate ファイルを格納する S3 バケット<br>名前は一意でなければならない|${terraform-playground}-for-cicd|

# variables.tf

| 項目   | 説明                         | 例    |
| ------ | ---------------------------- | ----- |
| prefix | プロジェクトのプレフィックス | tf-pg |
