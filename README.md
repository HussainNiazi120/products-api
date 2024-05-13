# Project Name: Amazon SP API Proxy for shopus.pk

## Description
This API acts as a proxy between the Amazon Selling Partner API (SP API) and shopus.pk (integration pending). It retrieves a list of products from the Amazon Catalog Items API based on keywords, serializes them to include only the required data, and returns the results in JSON format. Additionally, it performs the following tasks:

 - **Background Job for Product Creation**: Creates products in the local database as a background job while fetching data from Amazon. Ensures efficient data synchronization.
 - **Caching Mechanism**: Caches results to reduce the number of API hits in the future. Improves response time for subsequent requests.
 - **Product Retrieval by ASIN**: Allows fetching of a product by its ASIN (Amazon Standard Identification Number). Retrieves product details from the database and updates pricing using the Amazon Product Pricing API.
 - **Variations Support**: Enables fetching of variations for a product. The initial request typically returns a HTTP 202 (Accepted) status code, indicating that the request has been received but not yet acted upon. This is due to the potential need for multiple asynchronous API calls, particularly when dealing with a large number of variations. Subsequent requests are expedited as the data is fetched from the local database, leveraging the benefits of data persistence and minimizing network latency.

## Table of Contents
 - [Ruby Version](#ruby-version)
 - [System Dependencies](#system-dependencies)
 - [Configuration](#configuration)

## Ruby Version
ruby-3.3.1

## System Dependencies
Postgresql
Redis

## Configuration
Update refresh_token, client_id, client_secret, aws_access_key_id and aws_secret_access_key values in config/credentials/ with your working Amzazon SP API credentials