FROM mysql:5.7

# bashログイン時に日本語が使えない問題の解決
RUN apt-get update && apt-get install -y language-pack-ja-base language-pack-ja
ENV LANG ja_JP.UTF-8

ADD ./my.cnf /etc/mysql/my.cnf
RUN chmod 644 /etc/mysql/my.cnf


