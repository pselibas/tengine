FROM ubuntu:18.04
LABEL maintainer="Paul Selibas <pselibas@gmail.com>"

ENV TENGINE_VERSION   2.3.2

RUN apt-get update -y && apt-get -y install \
    curl \
    gcc \
    libc-dev \
    make \
    libpcre3-dev \
    zlib1g-dev \
    libssl-dev \
    libxslt1-dev \
    libgd-dev \
    libgeoip-dev 

ENV CONFIG "\
    --prefix=/usr/share/nginx \
    --conf-path=/etc/nginx/nginx.conf \
    --http-log-path=/var/log/nginx/access.log \
    --error-log-path=/var/log/nginx/error.log \
    --lock-path=/var/lock/nginx.lock \
    --pid-path=/run/nginx.pid \
    --http-client-body-temp-path=/var/lib/nginx/body \
    --http-fastcgi-temp-path=/var/lib/nginx/fastcgi \
    --http-proxy-temp-path=/var/lib/nginx/proxy \
    --http-scgi-temp-path=/var/lib/nginx/scgi \
    --http-uwsgi-temp-path=/var/lib/nginx/uwsgi \
    --with-debug \
    --with-pcre-jit \
    --with-ipv6 \
    --with-http_ssl_module \
    --with-http_stub_status_module \
    --with-http_realip_module \
    --with-http_auth_request_module \
    --with-http_addition_module \
    --with-http_dav_module \
    --with-http_geoip_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_image_filter_module \
    --with-http_v2_module \
    --with-http_sub_module \
    --with-http_xslt_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-threads \
    "

RUN curl -o tengine-${TENGINE_VERSION}.tar.gz https://tengine.taobao.org/download/tengine-${TENGINE_VERSION}.tar.gz
RUN tar -xzvf tengine-${TENGINE_VERSION}.tar.gz

RUN \
    cd tengine-${TENGINE_VERSION} \
    && ./configure $CONFIG --with-debug \
    && make \
    && make install \
    # forward request and error logs to docker log collector
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN mkdir /var/lib/nginx/

RUN rm -rf tengine-${TENGINE_VERSION}/ && rm tengine-${TENGINE_VERSION}.tar.gz
RUN apt-get remove -y gcc make 

EXPOSE 80 443

STOPSIGNAL SIGTERM

CMD ["/usr/share/nginx/sbin/nginx", "-g", "daemon off;"]