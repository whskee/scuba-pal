UPDATE dive.dive_locations
   SET image_url = CASE location_name
       WHEN 'La Jolla Shores' THEN 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1200'
       WHEN 'Molokini Crater' THEN 'https://images.unsplash.com/photo-1518877593221-1f28583780b4?w=1200'
       WHEN 'USS Spiegel Grove' THEN 'https://images.unsplash.com/photo-1580019542155-247062e19ce4?w=1200'
       WHEN 'Blue Heron Bridge' THEN 'https://images.unsplash.com/photo-1682687220063-4742bd7fd538?w=1200'
       ELSE image_url
   END
 WHERE image_url IS NULL;

UPDATE dive.dive_shops
   SET image_url = CASE shop_name
       WHEN 'Pacific Kelp Divers' THEN 'https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=1200'
       WHEN 'Blue Horizon Charters' THEN 'https://images.unsplash.com/photo-1518877593221-1f28583780b4?w=1200'
       ELSE image_url
   END
 WHERE image_url IS NULL;
