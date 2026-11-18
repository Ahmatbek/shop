package kg.shop.config;

import kg.shop.entity.Product;
import kg.shop.repo.ProductRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;
import java.util.Map;

@Configuration
public class DataSeeder {

    /** Product images live in src/main/resources/static/images and are served at /images/... */
    private static final Map<String, String> IMAGES = Map.ofEntries(
            Map.entry("Беспроводные наушники", "headphones"),
            Map.entry("Умные часы", "smartwatch"),
            Map.entry("Power bank 20000 mAh", "powerbank"),
            Map.entry("Механическая клавиатура", "keyboard"),
            Map.entry("Худи оверсайз", "hoodie"),
            Map.entry("Футболка базовая", "tshirt"),
            Map.entry("Джинсы прямого кроя", "jeans"),
            Map.entry("Кроссовки беговые", "sneakers"),
            Map.entry("Рюкзак городской", "backpack"),
            Map.entry("Термокружка 450 мл", "thermos"),
            Map.entry("Солнцезащитные очки", "sunglasses"),
            Map.entry("Книга «Чистый код»", "book")
    );

    @Bean
    CommandLineRunner seedProducts(ProductRepository repo) {
        return args -> {
            if (repo.count() > 0) {
                // Databases seeded earlier get the matching images too.
                for (Product product : repo.findAll()) {
                    String image = imageFor(product.getName());
                    if (image != null && !image.equals(product.getImageUrl())) {
                        product.setImageUrl(image);
                        repo.save(product);
                    }
                }
                return;
            }
            repo.saveAll(List.of(
                    p("Беспроводные наушники", "Bluetooth 5.3, до 24 часов работы с кейсом.", 3490, "Электроника"),
                    p("Умные часы", "Пульс, шагомер, уведомления, защита от воды.", 5990, "Электроника"),
                    p("Power bank 20000 mAh", "Быстрая зарядка 22.5 Вт, два USB-порта.", 2290, "Электроника"),
                    p("Механическая клавиатура", "Красные переключатели, подсветка RGB.", 4200, "Электроника"),
                    p("Худи оверсайз", "Плотный хлопок, унисекс, чёрный цвет.", 2800, "Одежда"),
                    p("Футболка базовая", "100% хлопок, белая, размеры S-XL.", 790, "Одежда"),
                    p("Джинсы прямого кроя", "Классические синие джинсы, средняя посадка.", 2400, "Одежда"),
                    p("Кроссовки беговые", "Лёгкие, амортизирующая подошва.", 4500, "Обувь"),
                    p("Рюкзак городской", "Отделение для ноутбука 15.6, водоотталкивающая ткань.", 1900, "Аксессуары"),
                    p("Термокружка 450 мл", "Держит тепло до 8 часов, нержавеющая сталь.", 690, "Аксессуары"),
                    p("Солнцезащитные очки", "UV400, лёгкая оправа.", 950, "Аксессуары"),
                    p("Книга «Чистый код»", "Роберт Мартин. Практика написания чистого кода.", 1500, "Книги")
            ));
        };
    }

    private static String imageFor(String name) {
        String slug = IMAGES.get(name);
        return slug == null ? null : "/images/" + slug + ".svg";
    }

    private static Product p(String name, String description, double price, String category) {
        return new Product(name, description, price, imageFor(name), category);
    }
}
