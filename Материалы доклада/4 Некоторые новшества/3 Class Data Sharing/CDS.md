# Полезные материалы
Доклад Фолькера Сим*о*ниса:
* https://youtu.be/fqUG1rr-y78
* https://simonis.github.io/JBreak2018

Прочее:
* [JEP-310](https://openjdk.java.net/jeps/310)
* [Упоминание у Dave Syer](https://github.com/dsyer/spring-boot-allocations#java-10-features)
* [Еще одно упоминание у Dave Syer](https://spring.io/blog/2018/12/12/how-fast-is-spring#class-data-sharing)
* [Статья Н. Парлога](https://blog.codefx.org/java/application-class-data-sharing/)
* [Видосик от Oracle, 2016](https://www.youtube.com/watch?v=dRw77QDSL-A)

### Путевые заметки
AppCDS перешел в OpenJDK в версии 10.

У AppCDS несколько целей:
> Reduce footprint    
  Improve startup time.    
  Extend CDS 

, однако для нас при локальном запуске множества микросервисов наиболее важна только первая из них.

> Class data sharing is enabled by default. You can manually enable and disable this feature.

[Источник](https://docs.oracle.com/en/java/javase/11/vm/class-data-sharing.html#GUID-882DC523-706D-403E-8A06-FBBB0E1B2128)

#### Список и архив классов JDK

Можно показать файл `E:\Dist\jdk-11.0.1+13-win64\bin\server\classes.jsa` (17.3 МБ), который получится после выполнения
"голой" команды `java -Xshare:dump`. Вывод у нее примерно такой:
```text
narrow_klass_base = 0x0000000800000000, narrow_klass_shift = 3
Allocated temporary class space: 1073741824 bytes at 0x00000008c0000000
Allocated shared space: 3221225472 bytes at 0x0000000800000000
Loading classes to share ...
Loading classes to share: done.
Rewriting and linking classes ...
Rewriting and linking classes: done
Number of classes 1272
    instance classes   =  1211
    obj array classes  =    53
    type array classes =     8
Updating ConstMethods ... done.
Removing unshareable information ... done.
Scanning all metaspace objects ...
Allocating RW objects ...
Allocating RO objects ...
Relocating embedded pointers ...
Relocating external roots ...
Dumping symbol table ...
Relocating SystemDictionary::_well_known_klasses[] ...
Removing java_mirror ... done.
mc  space:      8416 [  0.0% of total] out of     65536 bytes [ 12.8% used] at 0x0000000800000000
rw  space:   4023520 [ 22.2% of total] out of   4063232 bytes [ 99.0% used] at 0x0000000800010000
ro  space:   7307224 [ 40.4% of total] out of   7340032 bytes [ 99.6% used] at 0x00000008003f0000
md  space:      2560 [  0.0% of total] out of     65536 bytes [  3.9% used] at 0x0000000800af0000
od  space:   6536632 [ 36.1% of total] out of   6553600 bytes [ 99.7% used] at 0x0000000800b00000
total    :  17878352 [100.0% of total] out of  18087936 bytes [ 98.8% used]
```

#### Список и архив прикладных классов 

Попытка запуска микросервиса с опциями `-XX:+UseAppCDS -XX:DumpLoadedClassList=classes.lst` для получения списка 
классов. В логе много записей вида:
```text
skip writing class java/lang/invoke/BoundMethodHandle$Species_LIILLL from source __JVM_DefineClass__ to classlist file
skip writing class com/sun/proxy/$Proxy32 from source __JVM_DefineClass__ to classlist file
```

Готовый файл `classes.lst` имеет размер 612 КБ и начинается со строк
```text
java/lang/Object
java/lang/String
java/io/Serializable
```
, а всего в нем `11 359` строк. Причем, это только запуск микросервиса, без единого HTTP запроса.

> CDS/AppCDS supports archiving classes from JAR files only.

[Источник](https://docs.oracle.com/en/java/javase/11/tools/java.html#GUID-31503FCE-93D0-4175-9B4F-F6A738B2F4C4)

#### Новшества Java 11 в отношении AppCDS
Источник: [Java 11 SE Tools Reference](https://docs.oracle.com/en/java/javase/11/tools/java.html#GUID-31503FCE-93D0-4175-9B4F-F6A738B2F4C4)

> In JDK 11, Class Data Sharing (CDS) has been improved to support archiving classes from the module path.

> In JDK 11 and later, using -XX:DumpLoadedClassList=<class_list_file> results a generated classlist with all classes 
(both system library classes and application classes) included. You no longer have to specify -XX:+UseAppCDS 
with -XX:DumpLoadedClassList to produce a complete class list.

> In JDK 11 and later, -XX:+UseAppCDS is obsolete and the behavior for a non-empty directory is based on the class 
types in the classlist

> In JDK 11 and later, because UseAppCDS is obsolete, SharedArchiveFile becomes a product flag by default. 
Specifying +UnlockDiagnosticVMOptions for SharedArchiveFile is no longer be needed in all configurations.

Еще опция `-Xshared` стала по умолчанию равна `auto`, сделано это в [JDK-8197967](https://bugs.openjdk.java.net/browse/JDK-8197967).

#### Остается не понятным
> In Windows applications, the memory footprint of a process, as measured by various tools, might appear to increase, 
because more pages are mapped to the process’s address space. This increase is offset by the reduced amount of memory 
(inside Windows) that is needed to hold portions on the runtime modular image. Reducing footprint remains a high priority.

[Источник](https://docs.oracle.com/en/java/javase/11/vm/class-data-sharing.html#GUID-2942983A-E83C-4DA3-A60C-60411D731D5A)

В [документации](https://docs.oracle.com/en/java/javase/11/vm/class-data-sharing.html#GUID-2942983A-E83C-4DA3-A60C-60411D731D5A) написано:
> AppCDS allows the built-in system class loader, built-in platform class loader, 
and **custom class loaders** to load the archived classes.

Однако в то же время есть заявка на улучшение этой функции [JDK-8192921](https://bugs.openjdk.java.net/browse/JDK-8192921).
Но самое главное, что при эксперименте на распакованном приложении с командой
```cmd
> java -Xshare:dump -XX:SharedArchiveFile=classes.jsa -XX:SharedClassListFile=classes.flat.list org.springframework.boot.loader.JarLauncher
```
результат оказался таким:
```text
narrow_klass_base = 0x0000000800000000, narrow_klass_shift = 3
Allocated temporary class space: 1073741824 bytes at 0x00000008c0000000
Allocated shared space: 3221225472 bytes at 0x0000000800000000
Loading classes to share ...
An error has occurred while processing class list file classes.flat.list 893:64.
AppCDS custom class loaders not supported on this platform:
ftc/pc/soa/proxy/restorun/Restorun id: 401473 super: 1 source: E:/Projects/upc2/microservices/restorun/build/libs/restorun.fat/BOOT-INF/lib/restorun-1.11.0.jar
                                                               ^
Error occurred during initialization of VM
class list format error.
``` 
Приведенный в ответе фрагмент принадлежит файлу, сгенерированному утилитой *cl4cds* из лога загрузки классов:
```cmd
> java -Xshare:off -Xlog:class+load=debug:file=classes.flat.log org.springframework.boot.loader.JarLauncher
```

#### Сложности применения AppCDS в IDEA
##### При запуске с `@argFiles`
На первых местах в файле аргументов для опции `-classpath` числятся пути к "голым" классам приложения:
```text
-classpath
E:\Projects\upc2\microservices\restorun\out\production\classes
E:\Projects\upc2\microservices\restorun\out\production\resources
...
```
*idea_arg_file2075115005*

А вот что будет, если в списке классов будет указана не пустая директория
```text
Rewriting and linking classes: done
Error: non-empty directory 'E:\Projects\upc2\microservices\restorun\out\production\classes'
Hint: enable -Xlog:class+path=info to diagnose the failure
Error occurred during initialization of VM
Cannot have non-empty directory in paths
```

##### При запуске с `JAR manifest`
При дампе классов (да и вообще при каждом запуске) IDEA генерирует JAR-манифест со случайным суффиксом, например, 
`classpath188984893.jar`. Соответственно, при последующем запуске, когда JVM попытается сравнить classpath запуска с 
classpath'ом архива, она не найдет совпадения и упадет с ошибкой (при условии, что `-Xshare:on`, не `auto`):
```text
java.exe -XX:SharedArchiveFile=restorun.jsa -Xshare:on \
         -classpath C:\Users\plizga\AppData\Local\Temp\classpath569529684.jar ...
Error occurred during initialization of VM
Unable to use shared archive.
An error has occurred while processing the shared archive file.
Required classpath entry does not exist: C:\Users\plizga\AppData\Local\Temp\classpath352013462.jar
```  
*(сравни числа в именах архивов)*

#### Вывод при старте с опцией `-X:log:class+path=info`
```text
[0.008s][info][class,path] bootstrap loader class path=E:\Projects\upc2\upc2-infra\tools\jdk-micros-win\lib\modules
[0.009s][info][class,path] opened: E:\Projects\upc2\upc2-infra\tools\jdk-micros-win\lib\modules
[0.015s][info][class,path] type=BOOT 
[0.015s][info][class,path] Expecting BOOT path=E:\Projects\upc2\upc2-infra\tools\jdk-micros-win\lib\modules
[0.015s][info][class,path] ok
[0.143s][info][class,path] checking shared classpath entry: E:\Projects\upc2\upc2-infra\tools\jdk-micros-win\lib\modules
[0.143s][info][class,path] ok
[0.143s][info][class,path] checking shared classpath entry: C:\Users\plizga\AppData\Local\Temp\classpath1710891657.jar
[0.143s][info][class,path] ok
```

### Эксперимент N
#### Порядок
1. Сгенерировать список классов
2. Запустить `dump` с таким classpath, из которого будут исключены не-JAR вхождения, т.е. останутся только JAR-ки библиотек
3. Запустить приложение с исходным classpath и включенным AppCDS

#### Результат
##### Прогон 1
1. Генерация прошла успешно (см. `experiment-n\classes.list`)  
   Поправленный classpath получился таким: `experiment-n\classpath4dump.cp`
2. Дамп прошел так:
```text
E:\Projects\upc2\microservices\restorun>E:\Projects\upc2\upc2-infra\tools\jdk-micros-win\bin\java.exe -Xshare:dump -XX:SharedClassListFile=classes.list -XX:SharedArchiveFile=classes.jsa  @classpath4dump.cp ftc.pc.soa.proxy.restorun.Restorun
narrow_klass_base = 0x0000000800000000, narrow_klass_shift = 3
Allocated temporary class space: 1073741824 bytes at 0x00000008c0000000
Allocated shared space: 3221225472 bytes at 0x0000000800000000
Loading classes to share ...
OpenJDK 64-Bit Server VM warning: Pre JDK 1.5 class not supported by CDS: 45.3 javax/management/remote/rmi/RMIServerImpl_Stub
Preload Error: Failed to load javax/management/remote/rmi/RMIServerImpl_Stub
OpenJDK 64-Bit Server VM warning: Pre JDK 1.5 class not supported by CDS: 45.3 javax/management/remote/rmi/RMIServerImpl_Stub
Preload Error: Failed to load javax/management/remote/rmi/RMIServerImpl_Stub
Preload Warning: Cannot find ftc/pc/soa/proxy/restorun/Restorun
... (множество похожих строк) ...
Preload Warning: Removed error class: com.sun.jersey.core.impl.provider.entity.XMLRootElementProvider$Text
Rewriting and linking classes: done
Number of classes 12224
    instance classes   = 12059
    obj array classes  =   157
    type array classes =     8
Updating ConstMethods ... done.
#
# A fatal error has been detected by the Java Runtime Environment:
#
#  Internal Error (c:/cygwin64/tmp/openjdk-jdk11u-windows-x64-hotspot/workspace/build/src/src/hotspot/share/memory/metaspaceShared.cpp:1624), pid=29252, tid=28712
#  guarantee(ik->loader_type() != 0) failed: Class loader type must be set for this class java/lang/invoke/BoundMethodHandle$Species_LLLLLLLLI
#
# JRE version: OpenJDK Runtime Environment (11.0.2+9) (build 11.0.2+9)
# Java VM: OpenJDK 64-Bit Server VM (11.0.2+9, interpreted mode, compressed oops, g1 gc, windows-amd64)
# No core dump will be written. Minidumps are not enabled by default on client versions of Windows
#
# An error report file with more information is saved as:
# E:\Projects\upc2\microservices\restorun\hs_err_pid29252.log
#
# If you would like to submit a bug report, please visit:
#   https://github.com/AdoptOpenJDK/openjdk-build/issues
#
```    
**Наблюдение**   
При генерации в логах было много записей вида  
`skip writing class java/lang/invoke/BoundMethodHandle$Species_LLLLLLLLII from source __JVM_DefineClass__ to classlist file`
, т.е. как раз упоминающих "виновный" класс.

##### Прогон 2
Дамп завершился успешно:
```text
Rewriting and linking classes: done
Number of classes 11978
    instance classes   = 11899
    obj array classes  =    71
    type array classes =     8
Updating ConstMethods ... done.
Removing unshareable information ... done.
Scanning all metaspace objects ...
Allocating RW objects ...
Allocating RO objects ...
Relocating embedded pointers ...
Relocating external roots ...
Dumping symbol table ...
Relocating SystemDictionary::_well_known_klasses[] ...
Removing java_mirror ... done.
mc  space:     13840 [  0.0% of total] out of     65536 bytes [ 21.1% used] at 0x0000000800000000
rw  space:  29181808 [ 23.1% of total] out of  29229056 bytes [ 99.8% used] at 0x0000000800010000
ro  space:  48902928 [ 38.7% of total] out of  48955392 bytes [ 99.9% used] at 0x0000000801bf0000
md  space:      2560 [  0.0% of total] out of     65536 bytes [  3.9% used] at 0x0000000804aa0000
od  space:  48053520 [ 38.0% of total] out of  48103424 bytes [ 99.9% used] at 0x0000000804ab0000
total    : 126154656 [100.0% of total] out of 126418944 bytes [ 99.8% used]
```

А вот запуск с classpath'ом, в конец которого были добавлены папки с классами приложения, провалился с этим:
```text
#
# A fatal error has been detected by the Java Runtime Environment:
#
#  EXCEPTION_ACCESS_VIOLATION (0xc0000005) at pc=0x000000007708a365, pid=26520, tid=20600
#
# JRE version: OpenJDK Runtime Environment (11.0.2+9) (build 11.0.2+9)
# Java VM: OpenJDK 64-Bit Server VM (11.0.2+9, mixed mode, sharing, tiered, compressed oops, g1 gc, windows-amd64)
# Problematic frame:
# C  [ntdll.dll+0x2a365]
#
# No core dump will be written. Minidumps are not enabled by default on client versions of Windows
#
# An error report file with more information is saved as:
# E:\Projects\upc2\microservices\restorun\hs_err_pid26520.log
#
# If you would like to submit a bug report, please visit:
#   https://github.com/AdoptOpenJDK/openjdk-build/issues
#
```

### Известные ограничения
* На JAR-файлы при запуске можно ссылаться исключительно так же, как они были указаны при дампе: [JDK-8211723](https://bugs.openjdk.java.net/browse/JDK-8211723)
* Не поддерживается динамическая архивация метаданных классов: [JDK-8207812](https://bugs.openjdk.java.net/browse/JDK-8207812)

##### Число классов, загруженных из `jrt:/`
Кол-во | Режим
 --- | ---
3319 | share-off 
2157 | share-auto
10 | app-share-boot-only

### OpenJDK 12
* [Обзор от Н. Парлога](https://blog.codefx.org/java/java-12-guide/#Default-CDS-Archives)
* [JEP-341](https://openjdk.java.net/jeps/341)
* [Обзор от А. Чирухина](https://habr.com/ru/company/jugru/blog/444434)