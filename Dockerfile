FROM mvertes/alpine-mongo
RUN apk add --update curl perl make && \
    rm -rf /var/cache/apk/*
RUN cpan Mojolicious
COPY writer.sh /app/writer.sh
WORKDIR /app
CMD ./writer.sh
