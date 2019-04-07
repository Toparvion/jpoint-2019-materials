package sample;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * @author Toparvion
 * @since Uprise
 */
@SpringBootApplication
public class SpringBootAppCds implements ApplicationRunner {
  private static final Logger log = LoggerFactory.getLogger(SpringBootAppCds.class);

  public static void main(String[] args) {
    SpringApplication.run(SpringBootAppCds.class, args);
  }
  
  @Override
  public void run(ApplicationArguments args) {
    String classPath = System.getProperty("java.class.path")
        .replaceAll(System.getProperty("path.separator"), "\n");
         
    log.info("Current classpath:\n{}", classPath);
  }
}
