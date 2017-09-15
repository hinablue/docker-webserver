FROM debian:latest

MAINTAINER Hina Chen <hina@hinablue.me>

ENV LANG=C.UTF-8

RUN set -x \
	&& apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y build-essential software-properties-common \
		apt-transport-https lsb-release ca-certificates \
		gnupg2 dirmngr wget curl dialog \
		graphviz-dev \
		libltdl-dev \
		libdjvulibre-dev \
		libbz2-dev \
		libfftw3-dev \
		libfontconfig1-dev \
		libfreetype6-dev \
		libjpeg-dev \
		liblqr-1-0-dev \
		liblzma-dev \
		libperl-dev \
		libopenexr-dev \
		libopenjp2-7-dev \
		libpng-dev \
		libpango1.0-dev \
		librsvg2-2 \
		librsvg2-dev \
		libtiff5-dev \
		libraw-dev \
		libwebp-dev \
		libwmf-dev \
		libxml2-dev

RUN set -x \
	&& wget http://www.imagemagick.org/download/ImageMagick-7.0.7-2.tar.gz \
	&& tar -xvf ImageMagick-7.0.7-2.tar.gz \
	&& cd ImageMagick-7.0.7-2 \
	&& ./configure --prefix=/usr \
		--sysconfdir=/etc \
		--enable-hdri \
		--with-modules \
		--with-perl \
		--with-gslib \
		--with-rsvg \
		--with-x=no \
		--with-autotrace=no \
		--with-djvu=yes \
		--with-dps=no \
		--with-flif=no \
		--with-fpx=no \
		--disable-static && make && make install

RUN set -x \
	&& wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg \
	&& echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list \
	&& wget http://nginx.org/keys/nginx_signing.key \
	&& apt-key add nginx_signing.key && rm nginx_signing.key \
	&& echo "deb http://nginx.org/packages/debian/ $(lsb_release -sc) nginx" > /etc/apt/sources.list.d/nginx.list \
	&& echo "deb-src http://nginx.org/packages/debian/ $(lsb_release -sc) nginx" >> /etc/apt/sources.list.d/nginx.list \
	&& wget https://repo.mysql.com/RPM-GPG-KEY-mysql \
	&& apt-key add RPM-GPG-KEY-mysql && rm RPM-GPG-KEY-mysql \
	&& echo "deb http://repo.mysql.com/apt/debian/ stretch mysql-5.7" > /etc/apt/sources.list.d/mysql.list \
	&& echo "deb-src http://repo.mysql.com/apt/debian/ stretch mysql-5.7" >> /etc/apt/sources.list.d/mysql.list \
	&& curl -s "https://packagecloud.io/install/repositories/phalcon/stable/script.deb.sh" | bash \
	&& apt-get update \
	&& apt-get install --no-install-recommends --no-install-suggests -y php7.1-common php7.1-fpm php7.1-cli \
		php7.1-mbstring php7.1-curl php7.1-mcrypt php7.1-intl php7.1-mysql \
		php7.1-memcached php7.1-xml php7.1-soap php7.1-bcmath php-imagick php-msgpack php-uuid \
		php7.1-phalcon nginx mysql-client \
	&& cd / && rm -rf ImageMagick-7.0.7* && rm -rf /var/lib/apt/lists/*

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY nginx/sites/default /etc/nginx/conf.d/default.conf
COPY php/www.conf /etc/php/7.1/fpm/pool.d/www.conf
COPY php/php-fpm.conf /etc/php/7.1/fpm/php-fpm.conf
COPY php/php.ini /etc/php/7.1/fpm/php.ini
COPY start.sh start.sh

CMD ["bash", "start.sh"]
