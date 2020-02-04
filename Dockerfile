FROM ubuntu:18.04
LABEL maintainer="Paul Selibas <pselibas@gmail.com>"

ENV TENGINE_VERSION   2.3.2

RUN apt-get update -y && \
    apt-get install -y \
    curl \ 
    build-essential

RUN curl -o tengine.tar.gz https://github.com/alibaba/tengine/archive/${TENGINE_VERSION}.tar.gz

RUN tar -xzvf tengine.tar.gz

RUN cd tengine \
    && ./configure \
    && make \
    && make install

RUN apt-get remove --auto-remove build-essential
RUN apt-get purge --auto-remove build-essential

RUN rm -rf tengine/ && rm tengine.tar.gz

RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]