package kg.shop.controller;

import jakarta.validation.Valid;
import kg.shop.dto.Dtos.CartLine;
import kg.shop.dto.Dtos.CheckoutRequest;
import kg.shop.dto.Dtos.OrderItemResponse;
import kg.shop.dto.Dtos.OrderResponse;
import kg.shop.entity.AppUser;
import kg.shop.entity.CustomerOrder;
import kg.shop.entity.OrderItem;
import kg.shop.entity.Product;
import kg.shop.repo.OrderRepository;
import kg.shop.repo.ProductRepository;
import kg.shop.repo.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;

@RestController
@RequestMapping("/api/orders")
public class OrderController {

    private final OrderRepository orders;
    private final ProductRepository products;
    private final UserRepository users;

    public OrderController(OrderRepository orders, ProductRepository products, UserRepository users) {
        this.orders = orders;
        this.products = products;
        this.users = users;
    }

    @PostMapping
    @Transactional
    public OrderResponse checkout(@Valid @RequestBody CheckoutRequest req, Authentication auth) {
        AppUser user = users.findByEmail(auth.getName())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Пользователь не найден"));

        CustomerOrder order = new CustomerOrder(user, req.address().trim());
        for (CartLine line : req.items()) {
            // The price is taken from the database, never from the client.
            Product p = products.findById(line.productId())
                    .orElseThrow(() -> new ResponseStatusException(
                            HttpStatus.BAD_REQUEST, "Товар " + line.productId() + " не найден"));
            order.addItem(new OrderItem(p.getId(), p.getName(), p.getPrice(), line.quantity()));
        }
        return toResponse(orders.save(order));
    }

    @GetMapping
    @Transactional(readOnly = true)
    public List<OrderResponse> myOrders(Authentication auth) {
        return orders.findByUserEmailOrderByCreatedAtDesc(auth.getName()).stream()
                .map(OrderController::toResponse)
                .toList();
    }

    private static OrderResponse toResponse(CustomerOrder o) {
        List<OrderItemResponse> items = o.getItems().stream()
                .map(i -> new OrderItemResponse(i.getProductId(), i.getProductName(), i.getPrice(), i.getQuantity()))
                .toList();
        return new OrderResponse(o.getId(), o.getCreatedAt(), o.getTotal(), o.getAddress(), items);
    }
}
