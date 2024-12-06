package io.jenkins.plugins;

import hudson.Extension;  // Регистрация
import hudson.model.PageDecorator;  // Изменённый импорт
// import jenkins.model.PageDecorator;  // Импортируем PageDecorator (старая версия)

@Extension
public class CustomPageDecorator extends PageDecorator {
    public CustomPageDecorator() {
        super();
    }
}
