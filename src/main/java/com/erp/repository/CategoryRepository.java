package com.erp.repository;

import com.erp.domain.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {
    Optional<Category> findByCode(String code);
    List<Category> findByActifTrue();
    List<Category> findAll();
}
