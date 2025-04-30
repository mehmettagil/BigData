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

