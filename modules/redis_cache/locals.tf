locals {
  redis_url = "rediss://:${azurerm_redis_cache.redis.primary_access_key}@${azurerm_redis_cache.redis.hostname}:@${azurerm_redis_cache.redis.ssl_port}"
}