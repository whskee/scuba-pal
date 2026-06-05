package com.scubapal.dive.shop;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional(readOnly = true)
public class DiveShopService {

    private final DiveShopRepository diveShopRepository;
    private final DiveShopMapper diveShopMapper;

    public DiveShopService(DiveShopRepository diveShopRepository, DiveShopMapper diveShopMapper) {
        this.diveShopRepository = diveShopRepository;
        this.diveShopMapper = diveShopMapper;
    }

    public Page<DiveShopResponse> search(String q, Pageable pageable) {
        String term = q == null ? "" : q.trim();
        Page<DiveShop> shops = term.isBlank()
                ? diveShopRepository.findAllByOrderByShopNameAsc(pageable)
                : diveShopRepository.search(term, pageable);
        return shops.map(diveShopMapper::toResponse);
    }
}
