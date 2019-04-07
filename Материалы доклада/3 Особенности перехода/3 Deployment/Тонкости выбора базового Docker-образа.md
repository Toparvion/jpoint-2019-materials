#### Почему не Amazon Corretto?
https://aws.amazon.com/ru/corretto/
* Для 11 есть только Preview (по состоянию на 16.02.19)
* Для 11 вообще нет официального Docker образа

Добавить сюда пунктик про ошибку запуска shebang-файла на `AdoptOpenJDK 11.0.1+13`

> If supported, the default for this flag is true, and container support is enabled by default. It can be disabled with -XX:-UseContainerSupport.

[Источник](https://docs.oracle.com/en/java/javase/11/tools/java.html#GUID-3B1CE181-CD30-4178-9602-230B800D4FAE)

* http://blog.gilliard.lol/2018/11/05/alpine-jdk11-images.html
* https://github.com/AdoptOpenJDK/openjdk-docker
* https://openjdk.java.net/projects/portola/
* https://jdk.java.net/11/