ALTER PROCEDURE [dbo].[PredictTipSingleMode] @passenger_count int = 0,
@trip_distance float = 0,
@trip_time_in_secs int = 0,
@pickup_latitude float = 0,
@pickup_longitude float = 0,
@dropoff_latitude float = 0,
@dropoff_longitude float = 0,
@modeler varchar(255) = ''
AS
BEGIN

  DECLARE @inquery nvarchar(max) = N'
  SELECT * FROM [dbo].[fnEngineerFeatures]( 
  @passenger_count,
@trip_distance,
@trip_time_in_secs,
@pickup_latitude,
@pickup_longitude,
@dropoff_latitude,
@dropoff_longitude)
	'
  DECLARE @lmodel2 varbinary(max) = (SELECT TOP 1
    model
  FROM nyc_taxi_models where modeler=@modeler);
  EXEC sp_execute_external_script @language = N'R',
                                  @script = N'

mod <- unserialize(as.raw(model));
print(summary(mod))
OutputDataSet<-rxPredict(modelObject = mod, data = InputDataSet, outData = NULL, 
          predVarNames = "Score", type = "response", writeModelVars = FALSE, overwrite = TRUE);
str(OutputDataSet)
print(OutputDataSet)
',
                                  @input_data_1 = @inquery,
                                  @params = N'@model varbinary(max),@passenger_count int,@trip_distance float,
@trip_time_in_secs int ,
@pickup_latitude float ,
@pickup_longitude float ,
@dropoff_latitude float ,
@dropoff_longitude float',
                                  @model = @lmodel2,
								    @passenger_count =@passenger_count ,
									@trip_distance=@trip_distance,
									@trip_time_in_secs=@trip_time_in_secs,
									@pickup_latitude=@pickup_latitude,
									@pickup_longitude=@pickup_longitude,
									@dropoff_latitude=@dropoff_latitude,
									@dropoff_longitude=@dropoff_longitude
  WITH RESULT SETS ((Score float));

END
