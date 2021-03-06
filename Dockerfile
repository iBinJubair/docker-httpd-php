#
# NOTE: THIS DOCKERFILE IS GENERATED MANAULY DEPENDING ON THESE DOCKERFILE
#	php:7.3-alpine			https://github.com/docker-library/php/tree/master/7.3
#
#	httpd:2.4-alpine		https://github.com/docker-library/httpd/blob/master/2.4/alpine/Dockerfile
#	wordpress:cli-php7.3		https://github.com/docker-library/wordpress/tree/master/php7.3
#	phpmyadmin:5.0-fpm-alpine	https://github.com/phpmyadmin/docker/tree/master/
#	composer:1.10			https://github.com/composer/docker
#

FROM httpd:2.4-alpine

# dependencies required for running "phpize"
# these get automatically installed and removed by "docker-php-ext-*" (unless they're already installed)
ENV PHPIZE_DEPS \
		autoconf \
		dpkg-dev dpkg \
		file \
		g++ \
		gcc \
		libc-dev \
		make \
		pkgconf \
		re2c

# persistent / runtime deps
RUN apk add --no-cache \
		ca-certificates \
		curl \
		tar \
		xz \
# https://github.com/docker-library/php/issues/494
		openssl

# ensure www-data user exists ### Already there
#	RUN set -eux; \
#		addgroup -g 82 -S www-data; \
#		adduser -u 82 -D -S -G www-data www-data
# 82 is the standard uid/gid for "www-data" in Alpine
# https://git.alpinelinux.org/aports/tree/main/apache2/apache2.pre-install?h=3.9-stable
# https://git.alpinelinux.org/aports/tree/main/lighttpd/lighttpd.pre-install?h=3.9-stable
# https://git.alpinelinux.org/aports/tree/main/nginx/nginx.pre-install?h=3.9-stable

ENV PHP_INI_DIR /usr/local/etc/php
RUN set -eux; \
	mkdir -p "$PHP_INI_DIR/conf.d"; \
# allow running as an arbitrary user (https://github.com/docker-library/php/issues/743)
	[ ! -d /var/www/html ]; \
	mkdir -p /var/www/html; \
	rm -rvf /var/www/html/*; \
	echo '<?php phpinfo(); ?>' > /var/www/html/index.php; \
	\
	chown -R www-data:www-data /var/www/; \
	find /var/www/ -type d -exec chmod 755 {} +; \
	find /var/www/ -type f -exec chmod 644 {} +

##<autogenerated>##
# ENV HTTPD_PREFIX /usr/local/apache2
# ENV HTTPD_ENVVARS ""

RUN apk add --no-cache \
		bash \
		less \
		git \
		msmtp \
		mysql-client \
		nano \
		openssh-client \
		rsync \
		sed \
		subversion \
		tzdata \
		unzip \
		zip; \
		ln -sf /usr/bin/msmtp /usr/sbin/sendmail; \
	\
	mkdir -p /usr/local/apache2/conf.d; \
	#sed -i 's|Group daemon|Group www-data|g' /usr/local/apache2/conf/httpd.conf; \
	#sed -i 's|User daemon|User www-data|g' /usr/local/apache2/conf/httpd.conf; \
	sed -i 's|LoadModule mpm_event_module modules/mod_mpm_event.so|#LoadModule mpm_event_module modules/mod_mpm_event.so|g' /usr/local/apache2/conf/httpd.conf; \
	sed -i 's|#LoadModule mpm_prefork_module modules/mod_mpm_prefork.so|LoadModule mpm_prefork_module modules/mod_mpm_prefork.so|g' /usr/local/apache2/conf/httpd.conf; \
	sed -i 's|#LoadModule expires_module modules/mod_expires.so|LoadModule expires_module modules/mod_expires.so|g' /usr/local/apache2/conf/httpd.conf; \
	sed -i 's|#LoadModule rewrite_module modules/mod_rewrite.so|LoadModule rewrite_module modules/mod_rewrite.so|g' /usr/local/apache2/conf/httpd.conf; \
	sed -i 's|DirectoryIndex index.html|DirectoryIndex index.php index.html index.htm home.php home.html home.htm|g' /usr/local/apache2/conf/httpd.conf; \
	sed -i 's|/usr/local/apache2/htdocs|/var/www/html|g' /usr/local/apache2/conf/httpd.conf; \
	\
	{ \
		echo '<FilesMatch \.php$>'; \
		echo '	SetHandler application/x-httpd-php'; \
		echo '</FilesMatch>'; \
		echo; \
		echo '<FilesMatch \.phps$>'; \
		echo '	SetHandler application/x-httpd-php-source'; \
		echo '</FilesMatch>'; \
		echo; \
		echo 'IncludeOptional /usr/local/apache2/conf.d/*.conf'; \

	} >> /usr/local/apache2/conf/httpd.conf

ENV PHP_EXTRA_BUILD_DEPS apache2-dev
ENV PHP_EXTRA_CONFIGURE_ARGS --with-apxs2 --disable-cgi
##</autogenerated>##

# Apply stack smash protection to functions using local buffers and alloca()
# Make PHP's main executable position-independent (improves ASLR security mechanism, and has no performance impact on x86_64)
# Enable optimization (-O2)
# Enable linker optimization (this sorts the hash buckets to improve cache locality, and is non-default)
# https://github.com/docker-library/php/issues/272
# -D_LARGEFILE_SOURCE and -D_FILE_OFFSET_BITS=64 (https://www.php.net/manual/en/intro.filesystem.php)
ENV PHP_CFLAGS="-fstack-protector-strong -fpic -fpie -O2 -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64"
ENV PHP_CPPFLAGS="$PHP_CFLAGS"
ENV PHP_LDFLAGS="-Wl,-O1 -pie"

ENV GPG_KEYS CBAF69F173A0FEA4B537F470D66C9593118BCCB6 F38252826ACD957EF380D39F2F7956BC5DA04B5D

ENV PHP_VERSION 7.3.20
ENV PHP_URL="https://www.php.net/distributions/php-7.3.20.tar.xz" PHP_ASC_URL="https://www.php.net/distributions/php-7.3.20.tar.xz.asc"
ENV PHP_SHA256="43292046f6684eb13acb637276d4aa1dd9f66b0b7045e6f1493bc90db389b888" PHP_MD5=""

RUN set -eux; \
	\
	apk add --no-cache --virtual .fetch-deps gnupg; \
	\
	mkdir -p /usr/src; \
	cd /usr/src; \
	\
	curl -fsSL -o php.tar.xz "$PHP_URL"; \
	\
	if [ -n "$PHP_SHA256" ]; then \
		echo "$PHP_SHA256 *php.tar.xz" | sha256sum -c -; \
	fi; \
	if [ -n "$PHP_MD5" ]; then \
		echo "$PHP_MD5 *php.tar.xz" | md5sum -c -; \
	fi; \
	\
	if [ -n "$PHP_ASC_URL" ]; then \
		curl -fsSL -o php.tar.xz.asc "$PHP_ASC_URL"; \
		export GNUPGHOME="$(mktemp -d)"; \
		for key in $GPG_KEYS; do \
			gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
		done; \
		gpg --batch --verify php.tar.xz.asc php.tar.xz; \
		gpgconf --kill all; \
		rm -rf "$GNUPGHOME"; \
	fi; \
	\
	apk del --no-network .fetch-deps

# COPY docker-php-source /usr/local/bin/
RUN set -eux; \
	curl -s -L -o /usr/local/bin/docker-php-source "https://raw.githubusercontent.com/docker-library/php/master/7.3/alpine3.12/cli/docker-php-source"; \
	chmod +x /usr/local/bin/docker-php-source

RUN set -eux; \
	apk add --no-cache --virtual .build-deps \
		$PHPIZE_DEPS \
		argon2-dev \
		coreutils \
		curl-dev \
		libedit-dev \
		libsodium-dev \
		libxml2-dev \
		openssl-dev \
		sqlite-dev \
		gnu-libiconv-dev \
		${PHP_EXTRA_BUILD_DEPS:-} \
	; \
	\
	# Proper iconv: replace binary and headers https://github.com/docker-library/php/issues/240
	mv /usr/bin/gnu-iconv /usr/bin/iconv; \
	mv /usr/include/gnu-libiconv/*.h /usr/include; \
	rm -rf /usr/include/gnu-libiconv; \
	\
	export CFLAGS="$PHP_CFLAGS" \
		CPPFLAGS="$PHP_CPPFLAGS" \
		LDFLAGS="$PHP_LDFLAGS" \
	; \
	docker-php-source extract; \
	cd /usr/src/php; \
	gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"; \
	./configure \
		--build="$gnuArch" \
		--with-config-file-path="$PHP_INI_DIR" \
		--with-config-file-scan-dir="$PHP_INI_DIR/conf.d" \
		\
# make sure invalid --configure-flags are fatal errors instead of just warnings
		--enable-option-checking=fatal \
		\
# https://github.com/docker-library/php/issues/439
		--with-mhash \
		\
# --enable-ftp is included here because ftp_ssl_connect() needs ftp to be compiled statically (see https://github.com/docker-library/php/issues/236)
		--enable-ftp \
# --enable-mbstring is included here because otherwise there's no way to get pecl to use it properly (see https://github.com/docker-library/php/issues/195)
		--enable-mbstring \
# --enable-mysqlnd is included here because it's harder to compile after the fact than extensions are (since it's a plugin for several extensions, not an extension in itself)
		--enable-mysqlnd \
# https://wiki.php.net/rfc/argon2_password_hash (7.2+)
		--with-password-argon2 \
# https://wiki.php.net/rfc/libsodium
		--with-sodium=shared \
# always build against system sqlite3 (https://github.com/php/php-src/commit/6083a387a81dbbd66d6316a3a12a63f06d5f7109)
		--with-pdo-sqlite=/usr \
		--with-sqlite3=/usr \
		--with-iconv=/usr \
		\
		--with-curl \
		--with-libedit \
		--with-openssl \
		--with-zlib \
		\
# bundled pcre does not support JIT on s390x
# https://manpages.debian.org/stretch/libpcre3-dev/pcrejit.3.en.html#AVAILABILITY_OF_JIT_SUPPORT
		$(test "$gnuArch" = 's390x-linux-musl' && echo '--without-pcre-jit') \
		\
		${PHP_EXTRA_CONFIGURE_ARGS:-} \
	; \
	make -j "$(nproc)"; \
	find -type f -name '*.a' -delete; \
	make install; \
	find /usr/local/bin /usr/local/sbin -type f -perm +0111 -exec strip --strip-all '{}' + || true; \
	make clean; \
	\
# https://github.com/docker-library/php/issues/692 (copy default example "php.ini" files somewhere easily discoverable)
	cp -v php.ini-* "$PHP_INI_DIR/"; \
	\
	cd /; \
	docker-php-source delete; \
	\
	runDeps="$( \
		scanelf --needed --nobanner --format '%n#p' --recursive /usr/local \
			| tr ',' '\n' \
			| sort -u \
			| awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' \
	)"; \
	apk add --no-cache $runDeps; \
	\
	apk del --no-network .build-deps; \
	\
# update pecl channel definitions https://github.com/docker-library/php/issues/443
	pecl update-channels; \
	rm -rf /tmp/pear ~/.pearrc; \
# smoke test
	php --version

# COPY docker-php-ext-* docker-php-entrypoint /usr/local/bin/
RUN set -eux; \
	curl -s -L -o /usr/local/bin/docker-php-entrypoint "https://raw.githubusercontent.com/docker-library/php/master/7.3/alpine3.12/cli/docker-php-entrypoint"; \
	curl -s -L -o /usr/local/bin/docker-php-ext-configure "https://raw.githubusercontent.com/docker-library/php/master/7.3/alpine3.12/cli/docker-php-ext-configure"; \
	curl -s -L -o /usr/local/bin/docker-php-ext-enable "https://raw.githubusercontent.com/docker-library/php/master/7.3/alpine3.12/cli/docker-php-ext-enable"; \
	curl -s -L -o /usr/local/bin/docker-php-ext-install "https://raw.githubusercontent.com/docker-library/php/master/7.3/alpine3.12/cli/docker-php-ext-install"; \
	chmod +x \
		/usr/local/bin/docker-php-entrypoint \
		/usr/local/bin/docker-php-ext-configure \
		/usr/local/bin/docker-php-ext-enable \
		/usr/local/bin/docker-php-ext-install \
	; \
	sed -i 's|set -- php|set -- httpd-foreground|g' /usr/local/bin/docker-php-entrypoint

# sodium was built as a shared module (so that it can be replaced later if so desired), so let's enable it too (https://github.com/docker-library/php/issues/598)
RUN docker-php-ext-enable sodium

# install the PHP extensions https://github.com/mlocati/docker-php-extension-installer
RUN set -eux; \
	curl -s -L -o /usr/local/bin/install-php-extensions "https://raw.githubusercontent.com/mlocati/docker-php-extension-installer/master/install-php-extensions"; \
	chmod +x /usr/local/bin/install-php-extensions; \
	install-php-extensions \
		bcmath \
		bz2 \
		calendar \
		exif \
		gd \
		gmp \
		igbinary \
		imagick \
		imap \
		intl \
		mysqli \
		opcache \
		pcntl \
		pdo_mysql \
		soap \
		sockets \
		uuid \
		xmlrpc \
		xsl \
		zip

# Install Composer & WP CLI
RUN set -eux; \
	curl -s -L -o /usr/local/bin/composer "https://getcomposer.org$(curl -s https://getcomposer.org/versions | grep -m 1 -o '/download/.*/composer.phar')"; \
	chmod +x /usr/local/bin/composer; \
	curl -s -L -o /usr/local/bin/wp "https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar"; \
	chmod +x /usr/local/bin/wp

ENTRYPOINT ["docker-php-entrypoint"]
##<autogenerated>##
# https://httpd.apache.org/docs/2.4/stopping.html#gracefulstop
STOPSIGNAL SIGWINCH

# COPY httpd-foreground /usr/local/bin/ ### Already there
WORKDIR /var/www/html

EXPOSE 80
CMD ["httpd-foreground"]
##</autogenerated>##
