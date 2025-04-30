
-- 1.soru 5000 den az kapasiteli bölgeleri bulmak için 
SELECT regions.name, SUM(info.capacity) AS total_capacity
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info` AS info
LEFT JOIN `bigquery-public-data.san_francisco_bikeshare.bikeshare_regions` AS regions
ON info.region_id = regions.region_id
GROUP BY regions.name
HAVING SUM(info.capacity)<5000