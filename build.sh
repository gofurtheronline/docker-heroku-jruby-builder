#!/bin/sh

workspace_dir=$1
output_dir=$2
cache_dir=$3

jruby_src_file="jruby-dist-$VERSION-src.zip"

cd $cache_dir
if [ -n "${GIT_URL:-}" ]; then
	git clone $GIT_URL release
	cd release
	git checkout ${GIT_TREEISH:-$VERSION}
	MAVEN_OPTS=-XX:MaxPermSize=768m ./mvnw install -Pdist
	cp maven/jruby-dist/target/jruby-dist-$VERSION-src.tar.gz $cache_dir/$jruby_src_file
	cd ..
else
	if [ ! -f $jruby_src_file ]; then
		echo "Downloading $jruby_src_file"
		curl -fs -O -L "https://repo1.maven.org/maven2/org/jruby/jruby-dist/$VERSION/$jruby_src_file"
	fi
fi

cd $workspace_dir
unzip $cache_dir/$jruby_src_file
cd jruby-$VERSION
if [ "$VERSION" = "1.7.5" ]; then
	package_file="/tmp/buildpack_*/vendor/package.rb"
	cp $package_file lib/ruby/shared/rubygems
fi


if echo "$VERSION" | grep -q "^1\.7\."; then
	echo "Upgrading to jruby-openssl 0.9.21"
	sed -i.bak s/0.9.19/0.9.21/g lib/pom.rb
	sed -i.bak s/0.9.19/0.9.21/g lib/pom.xml
fi

var=$(echo $RUBY_VERSION | awk -F"." '{print $1,$2,$3}')
set -- $var
major=$1
minor=$2
patch=$3

if [ -f mvnw ]; then
	./mvnw -Djruby.default.ruby.version=$major.$minor -Dmaven.repo.local=$cache_dir/.m2/repository -T4
else
	cd /opt
	curl http://apache.org/dist/maven/maven-3/3.3.1/binaries/apache-maven-3.3.1-bin.tar.gz -s -o - | tar xzmf -
	ln -s /opt/apache-maven-3.3.1/bin/mvn /usr/local/bin
	cd -
	mvn -Djruby.default.ruby.version=$major.$minor -Dmaven.repo.local=$cache_dir/.m2/repository -T4
fi
if [ $? -ne 0 ]; then
	exit $1
fi
rm bin/*.bat
rm bin/*.dll
rm bin/*.exe
rm -rf lib/target
if [ -d lib/jni ] ; then
	find lib/jni/* ! -name x86_64-Linux -print0 | xargs -0 rm -rf --
fi
#ln -s jruby bin/ruby
mkdir -p $output_dir
tar czf $output_dir/ruby-$RUBY_VERSION-jruby-$VERSION.tgz bin/ lib/
ls $output_dir
