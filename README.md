
# View Filter Plugin

View Filter Plugin — это пользовательский плагин для Jenkins, который позволяет модифицировать внешний вид интерфейса Jenkins, добавляя собственные CSS, JavaScript и другие элементы.

## 📦 Содержание

- [Особенности](#особенности)
- [Установка](#установка)
- [Сборка](#сборка)
- [Тестирование](#тестирование)
- [Использование](#использование)
- [Разработка](#разработка)
- [Лицензия](#лицензия)

---

## ✨ Особенности

- Добавление собственных CSS для изменения внешнего вида Jenkins.
- Инъекция JavaScript для дополнительной функциональности.
- Простая интеграция с любым Jenkins сервером.

---

## 🚀 Установка

1. Перейдите в **Управление Jenkins → Управление плагинами → Установить с диска**.
2. Выберите файл `viewfilter.jpi`, который находится в папке `target` после сборки.
3. Нажмите **Установить без перезапуска** или **Установить и перезапустить** для активации плагина.

---

## 🛠️ Сборка

### Шаги для сборки плагина:

1. Убедитесь, что у вас установлены:
   - Java 11 или выше
   - Maven
2. Клонируйте репозиторий:
   ```bash
   git clone <URL вашего репозитория>
   cd viewfilter
   ```
3. Выполните сборку:
   ```bash
   mvn clean package
   ```
4. Скомпилированный плагин будет находиться в папке `target` с именем `viewfilter.jpi`.

---

## 🧪 Тестирование

Для запуска тестов используйте команду:
```bash
mvn test
```

Тесты проверяют:
- Корректность инъекции CSS/JS.
- Соответствие стандартам безопасности Jenkins.

---

## 💡 Использование

После установки плагин автоматически добавляет свои стили и скрипты на все страницы Jenkins. Вы можете настроить их, изменяя файлы в директории `src/main/resources`.

### Пример: Изменение цвета фона
1. Откройте файл `src/main/resources/io/jenkins/plugins/CustomPageDecorator/index.jelly`.
2. Добавьте или измените CSS:
   ```css
   body {
       background-color: #f0f0f0;
   }
   ```
3. Скомпилируйте и переустановите плагин.

---

## 📚 Разработка

### Локальный запуск Jenkins для тестирования:
1. Выполните команду:
   ```bash
   mvn jpi:run
   ```
2. Перейдите в браузере по адресу: [http://localhost:8080](http://localhost:8080).
3. Тестируйте плагин в локальной среде.

### Структура проекта:
- **`src/main/java`**: Исходный код плагина.
- **`src/main/resources`**: Шаблоны Jelly, CSS и JS.
- **`target`**: Результаты сборки.

---

## 📜 Лицензия

Проект распространяется под лицензией [MIT](https://opensource.org/license/mit/). Подробнее читайте в файле `LICENSE`.

---

## 🤝 Вклад

Добро пожаловать в сообщество разработчиков! Если вы хотите внести изменения или улучшения:
1. Сделайте форк репозитория.
2. Создайте ветку с названием вашей функции:
   ```bash
   git checkout -b feature/my-new-feature
   ```
3. Сделайте пул-реквест.

Ваш вклад очень ценен!
