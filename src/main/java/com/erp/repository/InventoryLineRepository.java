package com.erp.repository;

import com.erp.domain.Inventory;
import com.erp.domain.InventoryLine;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface InventoryLineRepository extends JpaRepository<InventoryLine, Long> {
    List<InventoryLine> findByInventaire(Inventory inventory);
}
