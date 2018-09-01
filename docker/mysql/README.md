# MySQL Docker Image

> - MySQL は File の Permission が 777 の .cnf を読まない。
> - Windows からVirtualBox経由でマウントしているディレクトリ/ファイルはすべて 777 になる。
> - /etc/mysql/conf.d で volume 指定したファイルも 777 になる。

https://qiita.com/koyo-miyamura/items/4d1430b9086c5d4a58a5

という問題からDockerfileで my.cnf をCOPYして利用する。

そのため、素のmysqlイメージを使わずローカルのDockerfileからbuildする方法をとる。

