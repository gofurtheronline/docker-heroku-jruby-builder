FROM heroku/cedar:14
MAINTAINER hone

RUN apt-get update && apt-get install default-jdk -y

RUN cd /opt && curl http://ftp.kddilabs.jp/infosystems/apache/maven/maven-3/3.2.1/binaries/apache-maven-3.2.1-bin.tar.gz -s -o - | tar xzf - && ln -s /opt/apache-maven-3.2.1/bin/mvn /usr/local/bin

# setup workspace
RUN rm -rf /tmp/workspace
RUN mkdir -p /tmp/workspace

# output dir is mounted
ADD build.sh /tmp/build.sh
CMD ["sh", "/tmp/build.sh", "/tmp/workspace", "/tmp/output", "/tmp/cache"]
