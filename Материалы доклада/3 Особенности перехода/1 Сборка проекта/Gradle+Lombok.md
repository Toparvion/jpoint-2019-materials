## Основное новшество
Upgrading from 4.10 and earlier: 
[Potential breaking changes / Java builds](https://docs.gradle.org/5.0/userguide/upgrading_version_4.html#potential_breaking_changes)

> Gradle will no longer automatically apply annotation processors that
> are on the compile classpath — use
> `CompileOptions.annotationProcessorPath` instead.

* [Stop using annotation processors from the compile classpath](https://github.com/gradle/gradle/issues/6296)
* [Support annotationProcessor in IDEA](https://github.com/gradle/gradle/issues/6227) 
* https://plugins.gradle.org/plugin/io.freefair.lombok
 

## Варианты сочетаний

Подключатель | BOM | Результат | Листинг | Выбранная версия Lombok
--- | --- | --- | --- | ---
annotationProcessor | SpringBoot Plugin | OK   | 1 | 1.16.20
annotationProcessor | Gradle BOM import | FAIL | 2 | -
freefair plugin     | SpringBoot Plugin | OK   | 3 | 1.18.6   
freefair plugin     | Gradle BOM import | OK   | 4 | 1.18.6  

###### Примечание
Для плагина Freefair v3.2+ нужен Gradle v5.3+.

### Листинги выполнения команд Gradle
Проверочная команда:
```bash
$ gradle dependencyInsight --dependency lombok --configuration=annotationProcessor
```

#### Листинг 1
```text
> Task :dependencyInsight
org.projectlombok:lombok:1.16.20 (selected by rule)
   variant "runtime" [
      org.gradle.status   = release (not requested)
      org.gradle.usage    = java-runtime (not requested)
      org.gradle.category = library (not requested)
   ]

org.projectlombok:lombok -> 1.16.20
\--- annotationProcessor
```

#### Листинг 2
```text
> Task :dependencyInsight
org.projectlombok:lombok: FAILED
   Failures:
      - Could not find org.projectlombok:lombok:.

org.projectlombok:lombok FAILED
\--- annotationProcessor
```

#### Листинг 3
```text
> Task :dependencyInsight
org.projectlombok:lombok:1.18.6 (selected by rule)
   variant "runtime" [
      org.gradle.status   = release (not requested)
      org.gradle.usage    = java-runtime (not requested)
      org.gradle.category = library (not requested)
   ]

org.projectlombok:lombok:1.18.6
\--- annotationProcessor
```

#### Листинг 4
```text
> Task :dependencyInsight
org.projectlombok:lombok:1.18.6
   variant "runtime" [
      org.gradle.status   = release (not requested)
      org.gradle.usage    = java-runtime (not requested)
      org.gradle.category = library (not requested)
   ]

org.projectlombok:lombok:1.18.6
\--- annotationProcessor
```

## Полезные ссылки
* [SO: Unable to use Maven BOM in gradle 5 with annotationProcessor configuration](https://stackoverflow.com/questions/54524555/unable-to-use-maven-bom-in-gradle-5-with-annotationprocessor-configuration)
* https://plugins.gradle.org/plugin/io.freefair.lombok
* [Importing version recommendations from a Maven BOM](https://docs.gradle.org/5.0/userguide/managing_transitive_dependencies.html#sec:bom_import)
* [Fine-grained transitive dependency management](https://gradle.org/whats-new/gradle-5/#fine-grained-transitive-dependency-management)

## Полный текст скрипта сборки
```groovy
buildscript {
    ext {
        springBootVersion = '2.0.2.RELEASE'
    }
    repositories {
        mavenCentral()
        maven { url "https://plugins.gradle.org/m2/" }
    }
    dependencies {
        classpath "org.springframework.boot:spring-boot-gradle-plugin:${springBootVersion}"
        classpath "io.freefair.gradle:lombok-plugin:3.2.0"
    }
}

apply plugin: 'java'
apply plugin: 'eclipse'
apply plugin: 'project-report'
apply plugin: 'org.springframework.boot'
//apply plugin: 'io.spring.dependency-management'
//apply plugin: "io.freefair.lombok"

group = 'ru.toparvion.sample'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = 8

repositories {
    mavenCentral()
}

dependencies {
    implementation platform("org.springframework.boot:spring-boot-dependencies:2.0.2.RELEASE")
    annotationProcessor platform("org.springframework.boot:spring-boot-dependencies:2.0.2.RELEASE")
    compile('org.springframework.boot:spring-boot-starter-actuator')
    compile('org.springframework.boot:spring-boot-starter-integration')
    compile('org.springframework.boot:spring-boot-starter-web')
    compile('org.springframework.boot:spring-boot-starter-jdbc')
    compile("org.springframework.integration:spring-integration-jdbc")
    compile("org.telegram:telegrambots-abilities:3.6.1")
    compile("com.vdurmont:emoji-java:4.0.0")

    compileOnly('org.springframework.boot:spring-boot-configuration-processor')
    
    annotationProcessor('org.projectlombok:lombok')
    compileOnly('org.projectlombok:lombok')

    runtime("com.h2database:h2")
    runtime("org.postgresql:postgresql")

    testCompile('org.springframework.boot:spring-boot-starter-test')
}
```