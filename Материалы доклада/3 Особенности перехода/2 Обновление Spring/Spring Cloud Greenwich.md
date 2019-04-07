#### Spring Cloud Greenwich.RC2
Методу `feign.Response.Builder#build` понадобилось иметь заранее созданный запрос, поэтому построение ответа в тестах стало выглядеть так: 
```java
Response response = Response.builder()
    .request(REQUEST)  // добавка
    .status(STATUS)
    .reason(REASON)
    .headers(emptyMap())
    .build();
```

#### Заметка от Максима Гореликова
> @toparvion спецэффект в 2.c.ii, если еще не сталкивался  
> spring-cloud:Greenwich.RELEASE и spring boot 2.1.3   
> @EnabledBinding на классах автоконфигураций перестает работать 
> и если вдруг был свой стартер с привязкой к очерди через
> spring-cloud-stream(или integration), то сюрприз выходит
> :slightly_smiling_face:   
> решается так
> https://github.com/spring-cloud/spring-cloud-bus/commit/56775bc7dfc9aaec975d631d1e60d49a6203ad9b

#### К слову о warning'ах
Вот этот код нормально выглядит в `io.github.openfeign:feign-core:9.5.1`, 
но пожелтел в `io.github.openfeign:feign-core:10.1.0`:
```java
String message = format("---> %s %s", request.method(), request.url());
if (request.body() != null) {
  String bodyText = request.charset() != null ? new String(request.body(), request.charset()) : null;
  message = message + format(" %s", bodyText != null ? bodyText : "-");
}
```
Исправление:
```java
  var message = new StringBuilder(format("---> %s %s", request.httpMethod(), request.url()));

  if ((request.requestBody() != null) && (request.requestBody().length() > 0)) {
    String bodyText = request.requestBody().asString();
    message.append(' ')
           .append(bodyText);
  }
```

### Изменение в API OpenFeign
```text
original request is required
java.lang.IllegalStateException: original request is required
	at feign.Util.checkState(Util.java:127)
	at feign.Response.<init>(Response.java:48)
	at feign.Response.<init>(Response.java:38)
	at feign.Response$Builder.build(Response.java:133)
	at ftc.pc.soa.integration.sbp.houston.client.lkapi.LkApiErrorDecoderTest.decode(LkApiErrorDecoderTest.java:68)
```

#### Новые проекты в составе Spring Cloud
* [Spring Cloud GCP](https://spring.io/projects/spring-cloud-gcp)
* [Spring Cloud Kubernetes](https://spring.io/projects/spring-cloud-kubernetes#overview)
* [Доклад с JugNsk про Spring Cloud Kubernetes](https://youtu.be/qmerH25ttfQ)

#### Maintenance Mode
* [Modules In Maintenance Mode](https://cloud.spring.io/spring-cloud-netflix/multi/multi__modules_in_maintenance_mode.html)