package com.scubapal.dive.shop;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.web.server.LocalServerPort;

import com.scubapal.shared.domain.address.Address;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class DiveShopPageControllerTest {

    @LocalServerPort
    private int port;

    @Autowired
    private DiveShopRepository diveShopRepository;

    @Test
    void shopsPageRendersForAnonymousVisitors() throws Exception {
        DiveShop shop = new DiveShop();
        shop.setShopName("Reef Supply");
        shop.setDescription("Local air fills and gear service.");
        shop.setAddress(new Address("1 Ocean Way", "Key Largo", "FL", "USA"));
        diveShopRepository.save(shop);

        HttpRequest request = HttpRequest.newBuilder(URI.create("http://localhost:" + port + "/shops")).GET().build();
        HttpResponse<String> response = HttpClient.newHttpClient().send(request, HttpResponse.BodyHandlers.ofString());

        assertEquals(200, response.statusCode());
        assertTrue(response.body().contains("Dive Shops"));
        assertTrue(response.body().contains("Reef Supply"));
        assertTrue(response.body().contains("/img/dive-location-placeholder.svg"));
    }
}
