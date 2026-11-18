package kg.shop.repo;

import kg.shop.entity.CustomerOrder;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface OrderRepository extends JpaRepository<CustomerOrder, Long> {

    @EntityGraph(attributePaths = "items")
    List<CustomerOrder> findByUserEmailOrderByCreatedAtDesc(String email);
}
