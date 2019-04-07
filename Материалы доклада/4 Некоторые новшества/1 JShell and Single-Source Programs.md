### Основная идея пункта
Прототипировать в пределах IDE достаточно просто, причем так было уже давно.
Однако за ее пределами, особенно в условиях специфичного окружения, например, в контейнерах, 
прототипировать гораздо сложнее - приходится либо встраиваться в приложение и разворачивать его после 
каждой правки, либо писать отдельные мини-программки, которые затем так же повторно заливать после
каждой правки. Появление JShell немного улучшило ситуацию, но эта оболочка в голом виде не пригодна для
прототипирования в контексте Spring Boot приложения, так как в этом случае необходим class-path, который
зашит в uber-jar. Чтобы его извлечь, нужно распаковать архив приложения и по результатам распаковки 
составить значение опции class-path для JShell. Разумеется, это можно сделать, например, на Shell, однако
ничуть не хуже (а то и быстрее) это получится сделать на любимой Java. А чтобы такую программку было легко
запустить, ее можно оформить в виде Shebang-скрипта и запустить непосредственно перед вызовом JShell. 

### Задумки
* Например, можно писать скрипты на Java в качестве плагинов к Helm:  http://technosophos.com/2017/03/21/creating-a-helm-plugin.html
* В режиме verbose в JShell можно видеть выведенные типы переменных - это удобно, чтобы узнавать
получаемые типы в неочевидных кейсах, например, при смешивании `int/double/long/etc`
* Можно показать на примере, как прототипировать с помощью jshell в условиях зависимостей не только
от прикладного кода, но и от Spring Boot. Для этого:
    * привести пример выполнения простейшего выражения;
    * попытаться вызвать метод из прикладного класса, прописав для него импорт к build/classes;
    * показать ошибку разрешения зависимостей от SB;
    * показать, что разрешить такую зависимость можно только указанием точного пути к каждой jar'ке, 
      либо указанием `*`;
    * предложить использовать `springboot-jshell-adapter`, которым можно было бы формировать правильный classpath и 
      автоматически вызывать с ним jshell, чтобы внутри уже можно было свободно обращаться к любым классам проекта:
      как прикладным, так и библиотечным
* Учесть:
> The compiled classes are loaded by a custom class loader, that delegates to the application class loader.   
> (This implies that classes appearing on the application class path cannot refer to any classes declared in the 
source file.)      

### Поддержка jshell в IDEA
* Многого не хватает: https://youtrack.jetbrains.com/issue/IDEA-179252
* Неплохое описание применения голой оболочки: https://www.vojtechruzicka.com/jshell-repl/ 
* Основные отличия IDEA от голой оболочки:

    Аспект | IDEA | jShell
    --- | --- | ---
    Выполнение | весь скрипт целиком | только последнюю команду
    Поддержка команд `/` | нет | есть
    Добавление `import` | автоматически | вручную
    Добавлять в classpath | нельзя* | можно: `jshell> /env -class-path foo-1.0.0.jar` 
    
    Аспект | JShell Console | Java Scratch
    --- | --- | ---
    Подсказки и инспекции| урезанные | полноценные
    Проверяемые исключения| только `try/catch` | `try/catch` или `throws`
    Исполняемый контекст | фрагмент метода | весь класс
    Добавлять в classpath | нельзя* | можно
    ||
    
### Команды на развертывание скрипта-обёртки
```bash
$ ./gradlew regenerate -PjavaHome=/opt/java/openjdk
$ sudo docker cp jshellw alcatraz_11:/microservice/jshellw
$ sudo docker exec -w /microservice alcatraz_11 chmod +x jshellw
$ sudo docker exec -w /microservice alcatraz_11 ls -l jshellw 
# -rwxr-xr-x    1 1001     video         4914 Feb 11 03:21 jshellw
sudo docker exec -it -w /microservice alcatraz_11 ./jshellw alcatraz.jar
```    

TODO разобраться с ошибкой:
```text
upc@docker-sandbox:~/workspace$ sudo docker exec -it -w /microservice alcatraz_11 java --version
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport
openjdk 11.0.1 2018-10-16
OpenJDK Runtime Environment AdoptOpenJDK (build 11.0.1+13)
OpenJDK 64-Bit Server VM AdoptOpenJDK (build 11.0.1+13, mixed mode)

upc@docker-sandbox:~/workspace$ sudo docker exec -it -w /microservice alcatraz_11 ./jshellw alcatraz.jar
Picked up JAVA_TOOL_OPTIONS: -XX:+UseContainerSupport
Exception in thread "main" java.lang.IllegalArgumentException: error: release version 11 not supported
        at jdk.compiler/com.sun.tools.javac.main.Arguments.reportDiag(Arguments.java:891)
        at jdk.compiler/com.sun.tools.javac.main.Arguments.handleReleaseOptions(Arguments.java:311)
        at jdk.compiler/com.sun.tools.javac.main.Arguments.processArgs(Arguments.java:350)
        at jdk.compiler/com.sun.tools.javac.main.Arguments.init(Arguments.java:246)
        at jdk.compiler/com.sun.tools.javac.api.JavacTool.getTask(JavacTool.java:185)
        at jdk.compiler/com.sun.tools.javac.api.JavacTool.getTask(JavacTool.java:119)
        at jdk.compiler/com.sun.tools.javac.launcher.Main.compile(Main.java:364)
        at jdk.compiler/com.sun.tools.javac.launcher.Main.run(Main.java:176)
        at jdk.compiler/com.sun.tools.javac.launcher.Main.main(Main.java:119)
```

### Полезные ссылки
* [Статья от Н. Парлога](https://blog.codefx.org/java/scripting-java-shebang/)
* [Java SE 9 Tools Reference](https://docs.oracle.com/javase/9/tools/JSWOR.pdf)
* [Java SE 11 Tool Reference: java](https://docs.oracle.com/en/java/javase/11/tools/java.html)
* [JShell: A Comprehensive Guide to the Java REPL](https://www.infoq.com/articles/jshell-java-repl)
* [Заявка на поддержку Shebang Files в IDEA](https://youtrack.jetbrains.com/issue/IDEA-205455)
