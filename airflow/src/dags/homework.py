from datetime import datetime

from airflow import DAG
from airflow.decorators import task
from airflow.operators.bash import BashOperator
from airflow.operators.python import PythonOperator
from airflow.operators.python_operator import BranchPythonOperator
from airflow.operators.dummy import DummyOperator
import pandas as pd
import requests

from pymongo.mongo_client import MongoClient
from pymongo.server_api import ServerApi

from datetime import datetime, timedelta
import psycopg2

collection_name = "mehmet_tagil"

# A DAG represents a workflow, a collection of tasks
with DAG(
    dag_id="homework",
    start_date=datetime(2022, 1, 1),
    catchup=False,
    schedule_interval="*/5 * * * *") as dag:

    client = MongoClient("mongodb+srv://cetingokhan:cetingokhan@cluster0.ff5aw.mongodb.net/?retryWrites=true&w=majority&appName=Cluster0")


    def generate_random_heat_and_humidity_data(dummy_record_count:int):
        import random
        import datetime
        from models.heat_and_humidity import HeatAndHumidityMeasureEvent
        records = []
        for i in range(dummy_record_count):
            temperature = random.randint(10, 40)
            humidity = random.randint(10, 100)
            timestamp = datetime.datetime.now()
            creator = collection_name
            record = HeatAndHumidityMeasureEvent(temperature, humidity, timestamp, creator)
            records.append(record)
        return records
    
    def save_data_to_mongodb(records, collection_name):
        db = client["bigdata_training"]
        collection = db[collection_name]
        for record in records:
            collection.insert_one(record.__dict__)


    def create_sample_data_on_mongodb():
        ###her dakika çalışacak ve sonrasında mongodb ye kayıt yapacak method içeriğini tamamlayınız
        records = generate_random_heat_and_humidity_data(10)
        # Eksik parçayı tamamlıyorum
        user_collection = f"user_coll_{collection_name}"
        save_data_to_mongodb(records, user_collection)
        return "Örnek user collection veri oluşturuldu ve MongoDB'ye kaydedildi"


    def copy_anomalies_into_new_collection():        
        # sample_coll collectionundan sıcaklığı 30 dan büyük olanları new(kendi adınıza bir collectionname) 
        # collectionuna kopyalayın(kendi creatorunuzu ekleyin)
        db = client["bigdata_training"]
        user_collection = db[f"user_coll_{collection_name}"]
        anomalies_collection = db[f"anomalies_{collection_name}"]
        
        # Sıcaklığı 30'dan büyük olan kayıtları bul
        anomalies = user_collection.find({"temperature": {"$gt": 30}})
        
        # Yeni koleksiyona kopyala ve creator'ı güncelle
        for anomaly in anomalies:
            new_record = {
                "temperature": anomaly["temperature"],
                "humidity": anomaly["humidity"],
                "timestamp": anomaly["timestamp"],
                "creator": collection_name,
            }
            anomalies_collection.insert_one(new_record)
            
        return "Anomaliler yeni koleksiyona kopyalandı"
        

    def insert_airflow_logs_into_mongodb():            
        conn = psycopg2.connect(
            host="postgres",
            port="5432",
            database="airflow",
            user="airflow",
            password="airflow"
        )

        # airflow veritababnındaki log tablosunda bulunan verilerin son 1 dakikasında oluşan event bazındaki kayıt sayısını 
        # mongo veritabanında oluşturacağınız"log_adınız" collectionına event adı ve kayıt sayısı bilgisi ile 
        # birlikte(güncel tarih alanına ekleyerek) yeni bir tabloya kaydedin.
        
        cursor = conn.cursor()
        one_minute_ago = datetime.now() - timedelta(minutes=1)
        
        # Son 1 dakikada oluşan eventleri sorgula - parametre kullanarak
        query = """
        SELECT event, COUNT(*) as record_count
        FROM log
        WHERE dttm >= %s
        GROUP BY event
        """
        
        cursor.execute(query, (one_minute_ago,))
        results = cursor.fetchall()
        
        # MongoDB'deki log koleksiyonuna kaydet
        db = client["bigdata_training"]
        log_collection = db[f"log_{collection_name}"]
        
        for result in results:
            event_name = result[0]
            record_count = result[1]
            log_entry = {
                "event_name": event_name,
                "record_count": record_count,
                "created_at": datetime.now(),
            }
            log_collection.insert_one(log_entry)
        
        cursor.close()
        conn.close()
        
        return "Airflow logları MongoDB'ye eklendi"

    def finalize_task():

        return "Tüm işlemler tamamlandı"
    

    

    # Görevleri tanımla
    dag_start = DummyOperator(task_id="start")
    
    task_create_sample_data = PythonOperator(
        task_id='create_sample_data',
        python_callable=create_sample_data_on_mongodb,
        dag=dag
    )
    
    task_copy_anomalies = PythonOperator(
        task_id='copy_anomalies_into_new_collection',
        python_callable=copy_anomalies_into_new_collection,
        dag=dag
    )
    
    task_insert_logs = PythonOperator(
        task_id='insert_airflow_logs_into_mongodb',
        python_callable=insert_airflow_logs_into_mongodb,
        dag=dag
    )
    
    task_finalize = PythonOperator(
        task_id='finaltask',
        python_callable=finalize_task,
        dag=dag
    )
    
    # Görev akışları
    dag_start >> task_create_sample_data >> task_copy_anomalies >> task_finalize
    dag_start >> task_insert_logs >> task_finalize 