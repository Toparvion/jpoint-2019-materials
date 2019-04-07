## Примеры типичных исключений

### jaxb-compile

##### Ошибка
```text
TPayType.java:13: error: package javax.xml.bind.annotation does not exist
import javax.xml.bind.annotation.XmlType;
                                ^
```

##### Решение
```groovy
compile group: 'javax.xml.bind', name: 'jaxb-api'
```

### jaxb-runtime

##### Ошибка
```text
javax.xml.bind.JAXBException: Implementation of JAXB-API has not been found on module path or classpath.
...
Caused by: java.lang.ClassNotFoundException: com.sun.xml.internal.bind.v2.ContextFactory
```

##### Решение
```groovy
runtime group: 'org.glassfish.jaxb', name: 'jaxb-runtime'
```

