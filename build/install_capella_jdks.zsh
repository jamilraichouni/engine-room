#!/usr/bin/env zsh
(
    JVM_DIR=/usr/lib/jvm
    TMP_JDK=/tmp/jdk.tar.gz
    sudo mkdir -p $JVM_DIR
    cd $JVM_DIR
    for URL in \
       "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.6%2B10/OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.6_10.tar.gz" \
       "https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.11%2B9/OpenJDK17U-jdk_aarch64_linux_hotspot_17.0.11_9.tar.gz"
    do
      [[ -f $TMP_JDK ]] && rm $TMP_JDK
      curl -L -o $TMP_JDK $URL
      JDK_DIR_NAME=$(tar tf $TMP_JDK | head -n 1)
      [[ -d $JDK_DIR_NAME ]] && rm -rf $JDK_DIR_NAME
      tar xvzf $TMP_JDK
      rm $TMP_JDK
    done
)
