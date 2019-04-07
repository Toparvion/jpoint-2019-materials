## Упомянуть в докладе
### Поклонникам Maven
##### https://dzone.com/articles/migrating-springboot-applications-to-latest-java-v
> if you are using Maven to build your source code, you need to
> upgrade the Maven Compiler plugin to > 3.5 version.

> Upgrade the Maven compiler plugin to 3.8.0 with ASM (Java bytecode
> library) or download gradle-5.0 distribution for Gradle projects

> Update the Maven Surefire plugin and Failsafe Plugins.

##### https://blog.codefx.org/java/java-11-migration-guide/
    > Maven: 3.5.0
     compiler plugin: 3.8.0
      surefire and failsafe: 2.22.0
      
### Сканы сборок

| Команда | Версия | Время | Ссылка
|---|---|---|---|
| `:alcatraz:dependencies` | 4.10.3 | 2.381s | https://scans.gradle.com/s/ny2stcojlv2j4 |
| `:alcatraz:dependencies` | 5.0 | 1m 49.164s | https://scans.gradle.com/s/4capfpqflryke/ |
| `:alcatraz:dependencies` | 5.1.1 | 12.905s | https://scans.gradle.com/s/fv3j6kg4wtrce |

### Совместимость Gradle и Java
| Gradle | Java | План | Факт | Примечание
|---|---|---|---|---|
| 4.x | 8 | OK | OK | [Gradle 4.x requires Java 7](https://docs.gradle.org/5.0/userguide/upgrading_version_4.html) 
| 4.x | 11 | OK | FAIL | Проверить!!!
| 5.x | 8 | OK | FAIL | Проверить!!! [Gradle 5 requires Java 8 to run](https://docs.gradle.org/5.0/userguide/upgrading_version_4.html)
| 5.x | 11 | OK | OK |

#### Полезные ссылки
* [Gradle Java 11 support (PR)](https://github.com/gradle/gradle/issues/5120)
* [Migrate Maven Projects to Java 11](https://winterbe.com/posts/2018/08/29/migrate-maven-projects-to-java-11-jigsaw/)
* Возможно, имеет отношение к тормозам сборки:    
  [Gradle 5.0-rc-4 exponential backoff makes IDE import very slow](https://github.com/gradle/gradle/issues/7787)
* [Allow matching repositories to dependencies](https://github.com/gradle/gradle/issues/1369)
* https://docs.gradle.org/5.1/userguide/declaring_repositories.html#sec::matching_repositories_to_dependencies 
* https://docs.gradle.org/5.1/release-notes.html#repository-to-dependency-matching 
   

### Выдержка из заявки в JIRA

#### Пояснения к проблеме
Судя по результатам проведенного анализа, источником проблемы была ошибка в Gradle версии 5.0, допущенная 
при оптимизации логики разрешения зависимостей. Ошибка приводила к тому, что зависимости с отладочными версиями 
(snapshot'ы) запрашивались множество раз из каждого репозитория Artifatory для многих Gradle-конфигураций 
(в том числе сгенерированных (detached)). Дело усугублялось тем, что Spring Boot Gradle Plugin в ходе выполнения 
практически любой задачи генерирует множество detached-конфигураций, умножая тем самым число обращений к Artifactory. 
При этом стандартные флаги управления изменяющимися зависимостями никак не влияли на поведение сборки.

Скан примера длительной сборки: https://scans.gradle.com/s/4capfpqflryke
В нем можно видеть, что поиск артефактов daotestkit* занял в сумме ≈160 секунд, что составило основную часть времени всей сборки.

#### Пояснения к решению
В Gradle версии 5.1 ошибка была исправлена, вероятно, в рамках добавления нового функционала по управлению областью применимости репозиториев.

Во вложении profile.zip находится отчет о профилировании сборки, выполненной по команде `gradle --no-daemon --profile clean test`
 в директории `/pub/home/upc/applications/upc2_micro/ci/` (на Gradle 5.1.1). Вся сборка заняла 7 минут 20 секунд.

Подробный скан выполнения полного листинга зависимостей микроервисного репозитория (gradle dependencies): https://scans.gradle.com/s/7oovz44w2cy26/ 

 Для сокращения риска возникновения проблем с разрешением snapshot-зависимостей в будущем, репозиторий `prepaid-card-libs` 
 в Artifactory был разделен на два: `prepaid-card-libs-snapshot` и `prepaid-card-libs-release` для отладочных и 
 стабильных версий соответственно. А корневой скрипт сборки был дополнен появившимся в Gradle 5.1. уточнением назначения репозитория:
```groovy
// Локальный репозиторий для стабильных (релизных) версий самописных библиотек и утилит,
// а также сторонних библиотек, которые невозможно выкачать из Интернета
maven { 
    url "http://angara.ftc.ru:8081/artifactory/prepaid-card-libs-release"
    mavenContent { releasesOnly() }            
}
// Локальный репозиторий для временных (отладочных) версий самописных библиотек и утилит, 
// а также сторонних библиотек, которые невозможно выкачать из Интернета
maven { 
    url "http://angara.ftc.ru:8081/artifactory/prepaid-card-libs-snapshot"
    mavenContent { snapshotsOnly() }
}
```

Оба новых репозитория настроены в Artifactory таким образом, чтобы принимать только соответствующие им 
по типу артефакты (релизные либо отладочные версии).

Таким образом, для устранения проблемы необходимо обновить Gradle до версии 5.1+.

 При планировании дальнейших обновлений необходимо учитывать нерекомендуемые возможности Gradle, которые мы используем, 
 но которые могут быть исключены в будущих версиях.