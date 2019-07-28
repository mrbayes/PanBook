FROM alpine:3.10

RUN apk add --no-cache texlive-full curl bash
RUN cd /tmp/ && curl -s -L https://github.com/jgm/pandoc/releases/download/2.7.3/pandoc-2.7.3-linux.tar.gz -o pandoc.tar.gz && tar -zxvf pandoc.tar.gz  && mv pandoc-2.7.3/bin/* /usr/local/bin && rm -fr /tmp/*
RUN cd /tmp/ && curl -s -L https://github.com/lierdakil/pandoc-crossref/releases/download/v0.3.4.1/linux-pandoc_2_7_2.tar.gz -o crossref.tar.gz && tar -zxvf crossref.tar.gz && mv pandoc-crossref /usr/local/bin && rm -fr /tmp/*

COPY tools/docker/texlive-fontconfig.conf /etc/fonts/conf.d/09-texlive-fonts.conf

RUN [ ! -d /usr/share/fonts ] && mkdir /usr/share/fonts
RUN curl -s -L https://github.com/adobe-fonts/source-han-serif/releases/download/1.001R/SourceHanSerif.ttc -o /usr/share/fonts/SourceHanSerif.ttc
RUN curl -s -L https://github.com/adobe-fonts/source-han-sans/releases/download/2.001R/SourceHanSans.ttc -o /usr/share/fonts/SourceHanSans.ttc
RUN fc-cache -sfv
RUN apk add --no-cache make
ENV PATH /PanBook:$PATH
RUN mkdir /data

# plot 相关组件
RUN curl -s -L https://github.com/akavel/ditaa/releases/download/g1.0.0/ditaa-linux-amd64 -o /usr/local/bin/ditaa && chmod +x /usr/local/bin/ditaa
RUN apk add --no-cache graphviz librsvg
RUN curl -s -L https://github.com/pandoc-ebook/goseq/releases/download/v1.0/goseq-linux-amd64 -o /usr/local/bin/goseq && chmod +x /usr/local/bin/goseq
RUN curl -s -L https://github.com/pandoc-ebook/asciitosvg/releases/download/v1.0/a2s-linux-amd64 -o /usr/local/bin/a2s && chmod +x /usr/local/bin/a2s

ENV TIMEZONE Asia/Shanghai
RUN apk add --no-cache tzdata git
RUN cp /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
RUN echo "${TIMEZONE}" > /etc/timezone

COPY . /PanBook/
RUN chmod +x /PanBook/panbook
WORKDIR /data

ENTRYPOINT ["panbook"]