package io.jenkins.plugins;

import java.util.logging.Logger;  // Регистрация

import hudson.Extension;  // Изменённый импорт
import hudson.model.PageDecorator;

@Extension
public class CustomPageDecorator extends PageDecorator {
    private static final Logger LOGGER = Logger.getLogger(CustomPageDecorator.class.getName());
    
    public CustomPageDecorator() {
        super();
        LOGGER.info("CustomPageDecorator activated!");
        System.out.println("CustomPageDecorator constructor executed!");  // Дополнительно для диагностики
    }

    

}