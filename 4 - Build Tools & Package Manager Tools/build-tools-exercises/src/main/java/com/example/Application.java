package com.example;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

import javax.annotation.PostConstruct;

@SpringBootApplication
public class Application {

    public static void main(String[] args)
    {
        SpringApplication.run(Application.class, args);
        // Code snippet for Exercise 6!
        // Code snippet to add inside Application.java on line 16

        Logger log = LoggerFactory.getLogger(Application.class);
        try {
            String one = args[0];
            String two = args[1];
            log.info("Application will start with the parameters {} and {}", one, two);
        } catch(Exception e) {
            log.info("No parameters provided");
        }
    }

    @PostConstruct
    public void init()
    {
        Logger log = LoggerFactory.getLogger(Application.class);
        log.info("Java app started");
    }

    public String getStatus() {
        return "OK";
    }

    public boolean getCondition(boolean condition) {
        return condition;
    }
}
