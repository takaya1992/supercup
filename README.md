# SuperCup Dance Stadium Tweet Counter

http://www.acecook.co.jp/dance/

Search "[#スーパーカップダンススタジアム](https://twitter.com/search?f=tweets&vertical=default&q=%23%E3%82%B9%E3%83%BC%E3%83%91%E3%83%BC%E3%82%AB%E3%83%83%E3%83%97%E3%83%80%E3%83%B3%E3%82%B9%E3%82%B9%E3%82%BF%E3%82%B8%E3%82%A2%E3%83%A0&src=tyah)" by Twitter

## DEVELOPMENT

### carton install

```console
$ docker-compose run --rm app carton install
```

### start

```console
$ docker-compose up 
```

### exec script

#### DBに登録したツイートの情報（RT、Likeなど）の更新

```console
$ docker-compose run --rm app carton exec -- perl -Ilib app.pl update_tweets
```

#### 検索

```console
$ docker-compose run --rm app carton exec -- perl -Ilib app.pl search_and_register
```

取れるだけ取る場合

```console
$ docker-compose run --rm app carton exec -- perl -Ilib app.pl search_and_register --force
```

#### IDのリストから登録

```console
$ docker-compose run --rm app carton exec -- perl -Ilib app.pl fetch_from_tweet_ids --file ./tweets.txt
```


### Backup DB

見えないプロンプトでパスワードを聞かれてるので、入力してEnterを押す。  
DumpファイルにもEnter押してねっていうのも出力されてしまっているので、手で消す。

```console
$ docker-compose exec db sh -c 'mysqldump -uroot -p --databases sun_moon' > db_dump.sql
```

【メモ】

パスワード入力なし運用はできる。

- https://qiita.com/yuya373/items/ef5ca2ceae52c8c85d76
- https://medium.com/@tomsowerby/mysql-backup-and-restore-in-docker-fcc07137c757

### Restore DB

```console
$ docker-compose run --rm db bash
docker $ mysql -uroot -p -h db sun_moon < /app/db_dump.sql
```


# TODO

- entrypoint.sh 等を作ってそこで `carton install` と plackup をする。
