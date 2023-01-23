FROM golang:1.19-alpine3.17
RUN apk add git libwebp libwebp-dev alpine-sdk
RUN git clone https://github.com/tidbyt/pixlet &&\
    cd pixlet &&\
    make build &&\
    cp pixlet /bin/pixlet &&\
    cd / &&\
    rm -rf /pixlet /root/go /root/.cache/go-build &&\
    apk del alpine-sdk go

ADD pixlet-muni.star .
