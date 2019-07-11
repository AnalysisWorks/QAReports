#Using convolutions to detect anomalies

moving_average <- function(data, filter_size){
    as.data.frame(filter(data, rep(1,filter_size)/filter_size))
}

retrieve_anomalies <- function(data, filter_size, sigma){
    averages <- moving_average(data, filter_size)

    residuals <- data - averages

    standard_dev <- std(residuals)
}


