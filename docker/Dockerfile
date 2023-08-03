FROM golang as go

#############
# Nginx Builder
#############

FROM debian:buster-slim as nginxbuilder

ARG OPENRESTY_VERSION=1.21.4.1
ARG LUA_VERSION=5.1.5
ARG LUAROCKS_VERSION=3.3.1

RUN apt-get update \
	&& apt-get install -y \
	build-essential \
	ca-certificates \
	libncurses-dev \
	libpcre3-dev \
	libreadline-dev \
	libssl-dev \
	openssl unzip \
	wget \
	zlib1g-dev \
	git

# Lua build
COPY ./scripts/build-lua /tmp/build-lua
RUN /tmp/build-lua

# Nginx build
COPY ./scripts/build-openresty /tmp/build-openresty
RUN /tmp/build-openresty

#############
# Final Image
#############

FROM debian:buster-slim
LABEL maintainer="Jamie Curnow <jc@jc21.com>"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG TARGETPLATFORM
RUN echo "debian:buster-slim, ${TARGETPLATFORM:-linux/amd64}" > /built-for-arch

# OpenResty uses LuaJIT which has a dependency on GCC
RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	apache2-utils \
	ca-certificates \
	curl \
	figlet \
	jq \
	libncurses6 \
	libpcre3 \
	libreadline7 \
	openssl \
	perl \
	tzdata \
	unzip \
	zlib1g \
	gettext \
	wget \
	xz-utils \
	gcc \
	g++ \
	make \
	git \
	sqlite3 \
	vim \
	dnsutils \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/cache/* /var/log/* /tmp/* /var/lib/dpkg/status-old

# Copy lua and luarocks builds from first image
COPY --from=nginxbuilder /tmp/lua /tmp/lua
COPY --from=nginxbuilder /tmp/luarocks /tmp/luarocks
COPY ./scripts/install-lua /tmp/install-lua

# Copy openresty build from first image
COPY --from=nginxbuilder /tmp/openresty /tmp/openresty
COPY ./scripts/install-openresty /tmp/install-openresty

ARG OPENRESTY_VERSION=1.21.4.1
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt \
	OPENRESTY_VERSION=${OPENRESTY_VERSION} \
	GOPATH=/opt/go \
	PATH="/usr/local/go/bin:$PATH:/opt/go/bin" \
	S6_BEHAVIOUR_IF_STAGE2_FAILS=1 \
	S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0 \
	S6_FIX_ATTRS_HIDDEN=1 \
	S6_KILL_FINISH_MAXTIME=10000 \
	S6_VERBOSITY=2

# Install openresty, lua, then clean up file system
RUN apt-get update \
	&& /tmp/install-lua \
	&& /tmp/install-openresty \
	&& apt-get autoremove -y \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /var/cache/* /var/log/* /tmp/* /var/lib/dpkg/status-old

# copy go from golang
COPY --from=go /usr/local/go /usr/local/go

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" \
	&& chmod -R 777 "$GOPATH" \
	&& echo "====> ${TARGETPLATFORM}: $(go version)"

# Gotools
RUN cd /usr && wget -O- -nv https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s v1.52.2
RUN go install github.com/kyoh86/richgo@latest \
	&& go install github.com/sonatype-nexus-community/nancy@latest \
	&& go install github.com/mfridman/tparse@latest \
	&& go install golang.org/x/vuln/cmd/govulncheck@latest \
	&& rm -rf /root/.cache/go-build

# Fix for golang dev:
RUN chown -R 1000:1000 /opt/go

# nodejs
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
	&& apt-get update \
	&& apt-get install -y --no-install-recommends nodejs \
	&& npm install --location=global yarn \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/*

# Task
RUN cd /usr \
	&& curl -sL https://taskfile.dev/install.sh | sh \
	&& cd /root

# s6 overlay
COPY scripts/install-s6 /tmp/install-s6
RUN /tmp/install-s6 && rm -rf /tmp/*

COPY docker/rootfs /

WORKDIR /root

CMD [ "/init" ]
EXPOSE 80/tcp

LABEL org.label-schema.schema-version="1.0" \
	org.label-schema.license="MIT" \
	org.label-schema.name="devserver" \
	org.label-schema.description="A prebuilt image for use in development of software" \
	org.label-schema.url="https://github.com/jc21/docker-devserver" \
	org.label-schema.vcs-url="https://github.com/jc21/docker-devserver.git" \
	org.label-schema.cmd="docker run --rm -ti jc21/devserver:latest"
