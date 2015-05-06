FROM ubuntu
MAINTAINER bn0ir <gblacknoir@gmail.com>

RUN apt-get update && \
	apt-get install -y \
		gcc \
		make \
		wget \
		libldap-dev \
		libxml2-dev \
		libssl-dev &&\
	apt-get clean && \
	rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /usr/local/src && \
	mkdir -p /data/ocspd

RUN useradd ocspd

RUN wget http://downloads.sourceforge.net/project/openca/libpki/releases/v0.8.8/sources/libpki-0.8.8.tar.gz && \
	echo "2432d8111593f5211be92a1bd280a962ab3f6eb3  libpki-0.8.8.tar.gz" > libpki-0.8.8.tar.gz.sha1 && \
	sha1sum -c libpki-0.8.8.tar.gz.sha1 && \
	tar -xzf libpki-0.8.8.tar.gz && \
	rm libpki-0.8.8.tar.gz && \
	rm libpki-0.8.8.tar.gz.sha1 && \
	cd libpki-0.8.8 && \
	./configure && \
	make && \
	make install && \
	ln -s /usr/lib64/libpki.so.88 /usr/lib/libpki.so.88
	cd ../ && \
	rm -rf libpki-0.8.8

RUN wget http://downloads.sourceforge.net/project/openca/openca-ocspd/releases/v3.1.1/sources/openca-ocspd-3.1.1.tar.gz && \
	echo "0cdaea9cf414498d8dec614ab92056a3761063ac  openca-ocspd-3.1.1.tar.gz" > openca-ocspd-3.1.1.tar.gz.sha1 && \
	sha1sum -c openca-ocspd-3.1.1.tar.gz.sha1 && \
	tar -xzf openca-ocspd-3.1.1.tar.gz && \
	rm openca-ocspd-3.1.1.tar.gz && \
	rm openca-ocspd-3.1.1.tar.gz.sha1 && \
	cd openca-ocspd-3.1.1 && \
	./configure --prefix=/usr/local/ocspd && \
	make && \
	make install && \
	cd ../ && \
	rm -rf openca-ocspd-3.1.1 && \
	rm -rf /usr/local/ocspd/etc/ocspd/pki/token.d/* && \
	rm -rf /usr/local/ocspd/etc/ocspd/ca.d/* && \
	rm /usr/local/ocspd/etc/ocspd/ocspd.xml

WORKDIR /usr/local/ocspd

ADD ./run_ocspd.sh /usr/local/ocspd/run_ocspd.sh

ADD ./ca.xml /usr/local/ocspd/etc/ocspd/ca.d/ca.xml
ADD ./ocspd.xml /usr/local/ocspd/etc/ocspd/ocspd.xml
ADD ./token.xml /usr/local/ocspd/etc/ocspd/pki/token.d/token.xml

CMD ["/usr/local/ocspd/run_ocspd.sh"]
