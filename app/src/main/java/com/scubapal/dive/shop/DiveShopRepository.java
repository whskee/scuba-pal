package com.scubapal.dive.shop;

import java.util.List;

import org.springframework.data.domain.Sort;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DiveShopRepository extends JpaRepository<DiveShop, Long> {
    @Override
    @EntityGraph(attributePaths = "diveLocation")
    List<DiveShop> findAll(Sort sort);
}
