package com.scubapal.dive.shop;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.EntityGraph;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface DiveShopRepository extends JpaRepository<DiveShop, Long> {
    @EntityGraph(attributePaths = "diveLocation")
    Page<DiveShop> findAllByOrderByShopNameAsc(Pageable pageable);

    @EntityGraph(attributePaths = "diveLocation")
    @Query("""
            select shop from DiveShop shop
            left join shop.diveLocation location
            where lower(shop.shopName) like lower(concat('%', :term, '%'))
               or lower(coalesce(shop.description, '')) like lower(concat('%', :term, '%'))
               or lower(coalesce(shop.address.city, '')) like lower(concat('%', :term, '%'))
               or lower(coalesce(shop.address.state, '')) like lower(concat('%', :term, '%'))
               or lower(coalesce(shop.address.country, '')) like lower(concat('%', :term, '%'))
               or lower(coalesce(location.locationName, '')) like lower(concat('%', :term, '%'))
            order by shop.shopName asc
            """)
    Page<DiveShop> search(@Param("term") String term, Pageable pageable);
}
