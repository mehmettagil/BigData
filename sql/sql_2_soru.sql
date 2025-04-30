-- 2.soru 
-- CASE KOŞUL BAŞLATMA İÇİN kullandım

WITH t AS (
  SELECT
    start_station_id,
    end_station_id,
    AVG(CASE WHEN member_gender = 'Female' THEN duration_sec END) AS kadin_ortalama,
    AVG(CASE WHEN member_gender = 'Male' THEN duration_sec END) AS erkek_ortalama
  FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips`
  WHERE member_gender IN ('Female', 'Male')
  GROUP BY start_station_id, end_station_id
)
-- safecast kullanıyorum çünkü int644 hatası alıyorum safe_cast yapınca düzeldi
SELECT
  t.start_station_id,
  start_info.short_name AS baslangic_kodu,
  t.end_station_id,
  end_info.short_name AS bitis_kodu,
  t.kadin_ortalama,
  t.erkek_ortalama
FROM t
LEFT JOIN `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info` AS start_info
  ON SAFE_CAST(t.start_station_id AS STRING) = SAFE_CAST(start_info.station_id AS STRING)
LEFT JOIN `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info` AS end_info
  ON SAFE_CAST(t.end_station_id AS STRING) = SAFE_CAST(end_info.station_id AS STRING)