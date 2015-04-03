FROM centos:latest
MAINTAINER Sho Mizutani <sho@fixture.jp>
RUN groupadd nginx && useradd -g nginx nginx
WORKDIR /usr/local/src
RUN yum -y install wget tar perl perl-devel readline-devel pcre-devel openssl-devel gcc make
RUN wget http://openresty.org/download/ngx_openresty-1.7.10.1.tar.gz
RUN tar vxzf ngx_openresty-1.7.10.1.tar.gz
WORKDIR /usr/local/src/ngx_openresty-1.7.10.1
RUN ./configure --prefix=/usr/local/openresty && gmake && gmake install
WORKDIR /usr/local/openresty/nginx
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
EXPOSE 80
ENTRYPOINT sbin/nginx -c conf/nginx.conf
