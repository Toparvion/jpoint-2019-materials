## Java 9
Флаг `-XX:+PrintGCDateStamps` отныне не дает запуститься приложению:
      
```text
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport
Unrecognized VM option 'PrintGCDateStamps'
Error: Could not create the Java Virtual Machine.
Error: A fatal exception has occurred. Program will exit.
```
Причина в том, что в 9-ой версии был переделан и унифицирован механизм логирования GC:
https://www.oracle.com/technetwork/java/javase/9-notes-3745703.html#JDK-8145092

Вместо нее и соседней `-XX:+PrintGCDetails` потребуется использовать `-Xlog:gc*`.

## Java 10
* У JDK10 HotSpot появилась новая опция `-XX:+UseContainerSupport` для поддержки работы внутри контейнеров: 
https://chriswhocodes.com/hotspot_options_jdk10.html?s=UseContainerSupport
* Ключевое слово `var`. Помимо лаконичности позволяет быстро
  "передумывать" и менять типы локальных переменных. Например, если было
  так:
  ```java
  var myFile = Paths.get("inner/dir/file.txt");
  ```
  , а потом вы внезапно передумали и решили представить этот путь
  обычной строкой, то можно сделать лишь одно изменение (дописать
  `toString()`):
  ```java
  var myFile = Paths.get("inner/dir/file.txt").toString();
  ```
  вместо двух, как было раньше: 
  ```java
  String myFile = Paths.get("inner/dir/file.txt").toString();
  ```

## Java 11
Рассказать о шифровании этапа рукопожатия в TLS 1.3