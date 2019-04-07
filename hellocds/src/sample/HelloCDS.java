package sample;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author Toparvion
 * @since Uprise
 */
public class HelloCDS {
  private static final Logger log = LoggerFactory.getLogger(HelloCDS.class);
  
  public static void main(String[] args) {
    log.info("Hello, CDS!");
    log.info("Class path: {}", System.getProperty("java.class.path"));
  }
}
