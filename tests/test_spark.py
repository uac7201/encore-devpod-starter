from pyspark.sql import SparkSession


def test_local_spark():
    spark = (SparkSession.builder
             .appName("test-local")
             .master("local[1]")
             .getOrCreate())

    df = spark.createDataFrame([(1,)], ["x"])
    assert df.count() == 1
    spark.stop()
