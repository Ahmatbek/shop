package kg.shop.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.List;

public final class Dtos {

    private Dtos() {
    }

    public record RegisterRequest(
            @NotBlank(message = "Введите имя") String name,
            @NotBlank(message = "Введите email") @Email(message = "Некорректный email") String email,
            @NotBlank(message = "Введите пароль") @Size(min = 6, message = "Пароль минимум 6 символов") String password) {
    }

    public record LoginRequest(
            @NotBlank(message = "Введите email") String email,
            @NotBlank(message = "Введите пароль") String password) {
    }

    public record AuthResponse(String token, String name, String email) {
    }

    public record CartLine(
            @NotNull(message = "productId обязателен") Long productId,
            @Min(value = 1, message = "Количество должно быть больше 0") int quantity) {
    }

    public record CheckoutRequest(
            @NotBlank(message = "Введите адрес доставки") String address,
            @NotEmpty(message = "Корзина пуста") @Valid List<CartLine> items) {
    }

    public record OrderItemResponse(Long productId, String productName, double price, int quantity) {
    }

    public record OrderResponse(Long id, Instant createdAt, double total, String address,
                                List<OrderItemResponse> items) {
    }
}
