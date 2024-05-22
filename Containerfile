FROM alpine:3.20.0

RUN apk update \
    && apk add --no-cache curl git openssh-client\
    && rm -rf /var/cache/apk/*

CMD ["/bin/sh"]