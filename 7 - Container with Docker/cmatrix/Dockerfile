# Build Contianer Image
FROM alpine AS cmatrixbuilder
# Start with Alpine Linux as the base image for building

WORKDIR /usr/cmatrix
# Set the working directory for subsequent commands

RUN apk update --no-cache && \
    apk add git autoconf automake alpine-sdk ncurses-dev ncurses-static && \
    git clone https://github.com/abishekvashok/cmatrix.git . && \
    autoreconf -i && \
    mkdir -p /usr/lib/kbd/consolefonts /usr/share/consolefonts && \
    ./configure LDFLAGS="-static" && \
    make
# Update package list, install build dependencies, clone cmatrix source,
# configure and build the application

# cmatrix Container Image
FROM alpine
# Start a new build stage with a fresh Alpine Linux base

LABEL org.opencontainers.image.authors="Karan Thakkar"
LABEL org.opencontainers.image.description="Container image for https://github.com/abishekvashok/cmatrix"
# Add metadata labels to the image

RUN apk update --no-cache && \ 
    apk add ncurses-terminfo-base && \
    adduser -g "Thomas Anderson" -s /usr/sbin/nologin -D -H thomas
# Update packages, install ncurses, and create a non-root user

COPY --from=cmatrixbuilder /usr/cmatrix/cmatrix /cmatrix
# Copy the built cmatrix binary from the builder stage

USER thomas
# Switch to the non-root user for running the application

ENTRYPOINT [ "./cmatrix" ]
# Set the default command to run cmatrix

CMD [ "-ab", "-u", "2", "-C", "magenta" ]
# Set default arguments for cmatrix (can be overridden at runtime)