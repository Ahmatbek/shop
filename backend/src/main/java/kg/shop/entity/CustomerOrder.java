package kg.shop.entity;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "orders")
public class CustomerOrder {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private AppUser user;

    private Instant createdAt = Instant.now();

    private double total;

    private String address;

    @OneToMany(mappedBy = "order", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<OrderItem> items = new ArrayList<>();

    protected CustomerOrder() {
    }

    public CustomerOrder(AppUser user, String address) {
        this.user = user;
        this.address = address;
    }

    public void addItem(OrderItem item) {
        items.add(item);
        item.setOrder(this);
        total += item.getPrice() * item.getQuantity();
    }

    public Long getId() { return id; }
    public AppUser getUser() { return user; }
    public Instant getCreatedAt() { return createdAt; }
    public double getTotal() { return total; }
    public String getAddress() { return address; }
    public List<OrderItem> getItems() { return items; }
}
