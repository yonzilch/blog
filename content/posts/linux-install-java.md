+++
title = "Linux 安装 Java 通法"
date = "2022-04-03"
+++

---

本文更新于2023/12/28：更换为最新的 Java 下载链接；

---

**本文以安装 JDK 8, JDK 17 为例**

### JDK 8:

首先，为 JDK 8 创建一个目录。

```
mkdir /usr/local/java-8
```

其次，下载 JDK 8

```
wget https://download.bell-sw.com/java/8u392+9/bellsoft-jdk8u392+9-linux-amd64.tar.gz
```

之后，使用[tar命令](http://www.runoob.com/linux/linux-comm-tar.html)将`bellsoft-jdk8u392+9-linux-amd64.tar.gz`文件解压缩到先前创建的目录：

```
tar -zxvf bellsoft-jdk8u392+9-linux-amd64.tar.gz -C /usr/local/java-8
```

最后，运行以下命令以创建新的替代方案：

```
update-alternatives --install "/usr/bin/java" "java" "/usr/local/java-8/jdk8u392/bin/java" 1500
update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/java-8/jdk8u392/bin/javac" 1500
```

### JDK 17

首先，为 JDK 17 创建一个目录。

```
mkdir /usr/local/java-17
```

其次，下载 JDK 17

```
wget https://download.bell-sw.com/java/17.0.9+11/bellsoft-jdk17.0.9+11-linux-amd64.tar.gz
```

之后，使用[tar命令](http://www.runoob.com/linux/linux-comm-tar.html)将`bellsoft-jdk17.0.9+11-linux-amd64.tar.gz`文件解压缩到先前创建的目录：

```
tar -zxvf bellsoft-jdk17.0.9+11-linux-amd64.tar.gz -C /usr/local/java-17
```

最后，运行以下命令以创建新的替代方案：

```
update-alternatives --install "/usr/bin/java" "java" "/usr/local/java-17/jdk-17.0.9/bin/java" 1600
update-alternatives --install "/usr/bin/javac" "javac" "/usr/local/java-17/jdk-17.0.9/bin/javac" 1600
```

DONE.

## 附录：

https://github.com/bell-sw/Liberica
