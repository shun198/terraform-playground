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
|key|tfstate<br>名前は一意でなければならない|${terraform-playground}.tfstate|
|dynamodb_table|tfstate ファイルをロックする ID を格納する DynamoDB のテーブル<br>名前は一意でなければならない|${terraform-playground}-tfstate-lock|

# variables.tf

| 項目                  | 説明                                           | 例                                          |
| --------------------- | ---------------------------------------------- | ------------------------------------------- |
| prefix                | プロジェクトのプレフィックス                   | tf-pg                                       |
| project               | プロジェクト名                                 | terraform-playground                        |
| owner                 | プロジェクトのオーナー                         | shun198                                     |
| ami_image_for_bastion | 踏み台サーバの ImageID                         | amzn2-ami-kernel-5.10-hvm-2.0.\*-x86_64-gp2 |
| bastion_key_name      | 踏み台サーバへアクセスするための key pair      | terraform-playground-key-pair               |
| ecr_image_app         | アプリケーションの image を格納する ECR の URI | ${プロジェクト名}-app                       |
| ecr_image_web         | Nginx の image を格納する ECR の URI           | ${プロジェクト名}-web                       |
