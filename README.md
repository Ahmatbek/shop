# Shop: Flutter + Bloc + Spring Boot

Учебный проект (mid-term): мобильное приложение-магазин на Flutter с Bloc, которое общается с REST-сервером на Spring Boot.

| Требование | Где выполнено |
|---|---|
| Flutter | `mobile/` |
| Связь с сервером | `mobile/lib/data/shop_repository.dart` -> `backend/` (REST + JWT) |
| GitHub | см. раздел «Загрузка на GitHub» |
| State management: Bloc | `mobile/lib/blocs/` (`flutter_bloc`) |

## Функции

- регистрация и вход (JWT, токен сохраняется на устройстве)
- каталог товаров с поиском и фильтром по категориям
- корзина (+ / − / удалить)
- оформление заказа (цены считает сервер) и история заказов

## Структура

```
backend/                 Spring Boot 3, Java 21, JPA, H2, Spring Security + JWT
  src/main/java/kg/shop/
    controller/          AuthController, ProductController, OrderController
    security/            JwtService, JwtAuthFilter, SecurityConfig
    entity/ repo/ dto/ config/
mobile/                  Flutter
  lib/
    models/              Product, CartItem, Order, UserSession
    data/                ShopRepository (все HTTP-запросы в одном месте)
    blocs/               auth, products, cart, orders (events -> bloc -> states)
    screens/             login, home (каталог), cart, orders
  test/cart_bloc_test.dart
```

## Запуск бэкенда

Нужны Java 21 и Maven.

```bash
cd backend
mvn spring-boot:run
```

Сервер стартует на http://localhost:8080, при первом запуске создаёт 12 товаров. База H2 хранится в `backend/data/`.

Быстрая проверка:

```bash
curl http://localhost:8080/api/products
curl -X POST http://localhost:8080/api/auth/register -H "Content-Type: application/json" \
     -d '{"name":"Test","email":"test@mail.com","password":"123456"}'
```

API:

| Метод | URL | Доступ |
|---|---|---|
| POST | `/api/auth/register`, `/api/auth/login` | открыт |
| GET | `/api/products`, `/api/products/{id}` | открыт |
| POST | `/api/orders` | нужен `Authorization: Bearer <token>` |
| GET | `/api/orders` (заказы текущего пользователя) | нужен токен |

## Запуск приложения

Нужен Flutter SDK (3.19+).

```bash
cd mobile
flutter create --project-name shop_app --platforms=android,ios,web .
rm test/widget_test.dart        # (Windows: del test\widget_test.dart) тестовый файл-заготовку, он не подходит
flutter pub get
```

`flutter create .` не трогает уже существующие `lib/` и `pubspec.yaml`, а только добавляет папки `android/`, `ios/`, `web/`.

**Android:** сервер работает по http, поэтому в `android/app/src/main/AndroidManifest.xml` нужно добавить в тег `<application ...>` атрибут

```xml
android:usesCleartextTraffic="true"
```

а перед тегом `<application>` строку (нужна для release-сборки):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

Запуск:

```bash
flutter run                                   # эмулятор Android: сервер = 10.0.2.2:8080
flutter run -d chrome                         # web: сервер = localhost:8080
flutter run --dart-define=API_URL=http://192.168.1.10:8080   # реальный телефон: IP компьютера в Wi-Fi
```

Тесты Bloc корзины: `flutter test`.

## Как устроен Bloc в проекте

```
UI --Event--> Bloc --State--> UI
```

- `AuthBloc`: `LoginRequested`, `RegisterRequested`, `LogoutRequested` -> `Authenticated` / `Unauthenticated(error)`
- `ProductsBloc`: загрузка, поиск, фильтр категории (фильтрация считается в состоянии)
- `CartBloc`: корзина хранится на устройстве, итоговая сумма в состоянии
- `OrdersBloc`: оформление заказа на сервере и список заказов

Все HTTP-запросы идут через `ShopRepository`, Bloc-и ничего не знают про `http`.

## Загрузка на GitHub

```bash
cd shop            # корень проекта (где лежит этот README)
git init
git add .
git commit -m "Shop app: Flutter + Bloc + Spring Boot"
git branch -M main
git remote add origin https://github.com/<твой-логин>/<репозиторий>.git
git push -u origin main
```

## Что можно улучшить

- хранить токен в `flutter_secure_storage`
- заменить H2 на PostgreSQL (стек, который ты уже знаешь)
- добавить роль admin и CRUD товаров
- перенести секрет JWT в переменную окружения `JWT_SECRET`
