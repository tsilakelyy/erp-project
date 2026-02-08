package com.erp.repository;

import com.erp.domain.Article;
import com.erp.domain.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface ArticleRepository extends JpaRepository<Article, Long> {
    Optional<Article> findByCode(String code);
    List<Article> findByActifTrue();
    List<Article> findByActifTrueOrderByLibelle();
    List<Article> findByCategory(Category category);
    List<Article> findByCategory_Id(Long categoryId);
    
    // FETCH JOIN pour charger article avec sa catégorie
    @Query("SELECT DISTINCT a FROM Article a LEFT JOIN FETCH a.category WHERE a.actif = true ORDER BY a.libelle")
    List<Article> findAllActiveWithCategory();
    
    // FETCH JOIN pour charger article par ID avec sa catégorie
    @Query("SELECT a FROM Article a LEFT JOIN FETCH a.category WHERE a.id = :id")
    Optional<Article> findByIdWithCategory(@Param("id") Long id);
    
    // FETCH JOIN pour charger tous les articles avec leur catégorie
    @Query("SELECT DISTINCT a FROM Article a LEFT JOIN FETCH a.category ORDER BY a.libelle")
    List<Article> findAllWithCategory();
}