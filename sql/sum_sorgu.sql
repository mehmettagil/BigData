    select SUM(capacity) AS total_capacity from ⁠ bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info ⁠


    --  join ile tabloları birleştirmek için
    SELECT regions.name, SUM(info.capacity) AS total_capacity
    FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info` AS info
    LEFT JOIN `bigquery-public-data.san_francisco_bikeshare.bikeshare_regions` AS regions
    ON info.region_id = regions.region_id
    GROUP BY regions.name

    -- Soru 2.
    -- Aşağıda taslağı hazırlanmış olan sorguyu talep edilenlerle tamamlayınız.

    -- t ile (
    -- -- `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips`
    -- -- tablodan cinsiyeti (member_gender) sadece Kadın ve Erkek olan kullanıcılar için,
    -- -- cinsiyet, başlangıç istasyonu, bitiş istasyonu bazında ortalama yolculuk süresi(duration_sec) hesaplanmalı
    -- )
    -- Sorgunun sonucu aşağıdaki gibi olmalı(//T//'den *'yi seçin);
    -- başlangıç istasyonu id,
    -- başlangıç istasyonu kısa kodu(bikeshare_station_info tablo short_name),
    -- bitiş istasyonu kimliği,
    -- bitiş istasyonu kısa kodu(bikeshare_station_info tablo short_name),
    -- Kadın kullanıcıların ortalama seyahat süresi,
    -- Erkek kullanıcıların ortalama seyahat süresi

    hangi değerler var onun sorgusu
    SELECT member_gender, COUNT(*) AS count
    FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips`
    GROUP BY member_gender
    result== [{
    "member_gender": "Male",
    "count": "651771"
    }, {
    "member_gender": null,
    "count": "1084304"
    }, {
    "member_gender": "Female",
    "count": "199202"
    }, {
    "member_gender": "Other",
    "count": "12140"
    }]

    -- ortalama cinsiyete göre getirir

    SELECT
        member_gender,
        start_station_id,
        end_station_id,
        AVG(duration_sec) AS avg_duration
    FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips`
    WHERE member_gender = 'Male' OR member_gender = 'Female'  GROUP BY member_gender, start_station_id, end_station_id

SELECT
  trips.start_station_id,
  start_info.short_name AS start_short_name,
  trips.end_station_id,
  end_info.short_name AS end_short_name,
  trips.member_gender,
  AVG(trips.duration_sec) AS avg_duration
FROM `bigquery-public-data.san_francisco_bikeshare.bikeshare_trips` AS trips
LEFT JOIN `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info` AS start_info
  ON trips.start_station_id = start_info.station_id
LEFT JOIN `bigquery-public-data.san_francisco_bikeshare.bikeshare_station_info` AS end_info
  ON trips.end_station_id = end_info.station_id
WHERE trips.member_gender IN ('Male', 'Female')  
GROUP BY
  trips.member_gender,
  trips.start_station_id,
  trips.end_station_id,
  start_info.short_name,
  end_info.short_name

  -- int644 hatasu safe_cast kullandım
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