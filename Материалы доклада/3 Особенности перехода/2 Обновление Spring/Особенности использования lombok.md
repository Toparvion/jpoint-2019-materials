# Полезные материалы
* [Spring Boot 2.1 Release Notes / Lombok](https://github.com/spring-projects/spring-boot/wiki/Spring-Boot-2.1-Release-Notes#lombok)
* GH issue 1708: [extraPrivate=true from 1.16.22 breaks Jackson creator detection](https://github.com/rzwitserloot/lombok/issues/1708)
  * Ключевой [комментарий](https://github.com/rzwitserloot/lombok/issues/1708#issuecomment-394443173) 
* GH issue 1563: [1.16.20 @Data object no longer constructable for jackson?](https://github.com/rzwitserloot/lombok/issues/1563)
* https://projectlombok.org/changelog
* https://projectlombok.org/features/configuration


## Цепочка сбоя
1. Spring Boot втянул Lombok 1.18
2. Lombok избежал зависимости от "левых" модулей JDK
3. Lombok перестал генерировать `@ConstructorProperties`
4. Jackson не сумел сопоставить поля JSON с параметрами 
5. FAIL

## Связи версий
| SB | Lombok 
---|---
2.0 | 1.16.22  
2.1 | 1.18.0
