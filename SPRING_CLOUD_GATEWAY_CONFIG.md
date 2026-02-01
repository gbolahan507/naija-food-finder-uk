# Spring Cloud Gateway Configuration

## Overview
Spring Cloud Gateway acts as the single entry point for all client requests, providing routing, load balancing, security, and cross-cutting concerns.

## Architecture Position
```
Client Apps (Flutter/Web) → Spring Cloud Gateway → Microservices
                                     ↓
                            [Eureka Service Discovery]
                                     ↓
                              [Redis (Rate Limiting)]
```

## Complete Implementation

### 1. Dependencies (pom.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0">
    <modelVersion>4.0.0</modelVersion>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>3.2.0</version>
    </parent>

    <groupId>com.fintech</groupId>
    <artifactId>api-gateway</artifactId>
    <version>1.0.0</version>

    <properties>
        <java.version>17</java.version>
        <spring-cloud.version>2023.0.0</spring-cloud.version>
    </properties>

    <dependencies>
        <!-- Spring Cloud Gateway -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-gateway</artifactId>
        </dependency>

        <!-- Service Discovery -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-netflix-eureka-client</artifactId>
        </dependency>

        <!-- Redis for Rate Limiting -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-data-redis-reactive</artifactId>
        </dependency>

        <!-- Circuit Breaker -->
        <dependency>
            <groupId>org.springframework.cloud</groupId>
            <artifactId>spring-cloud-starter-circuitbreaker-reactor-resilience4j</artifactId>
        </dependency>

        <!-- Security -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-security</artifactId>
        </dependency>

        <!-- JWT -->
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-api</artifactId>
            <version>0.11.5</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-impl</artifactId>
            <version>0.11.5</version>
        </dependency>
        <dependency>
            <groupId>io.jsonwebtoken</groupId>
            <artifactId>jjwt-jackson</artifactId>
            <version>0.11.5</version>
        </dependency>

        <!-- Actuator for health checks -->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-actuator</artifactId>
        </dependency>
    </dependencies>

    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.cloud</groupId>
                <artifactId>spring-cloud-dependencies</artifactId>
                <version>${spring-cloud.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
</project>
```

### 2. Application Configuration (application.yml)

```yaml
server:
  port: 8080

spring:
  application:
    name: api-gateway

  cloud:
    gateway:
      # Global CORS Configuration
      globalcors:
        cors-configurations:
          '[/**]':
            allowedOrigins:
              - "http://localhost:3000"
              - "https://app.fintech.com"
            allowedMethods:
              - GET
              - POST
              - PUT
              - DELETE
              - PATCH
              - OPTIONS
            allowedHeaders: "*"
            allowCredentials: true
            maxAge: 3600

      # Route Definitions
      routes:
        # User Service Routes
        - id: user-service
          uri: lb://USER-SERVICE
          predicates:
            - Path=/api/auth/**, /api/users/**
          filters:
            - name: CircuitBreaker
              args:
                name: userServiceCircuitBreaker
                fallbackUri: forward:/fallback/user-service
            - name: RequestRateLimiter
              args:
                redis-rate-limiter.replenishRate: 100
                redis-rate-limiter.burstCapacity: 200
                key-resolver: "#{@userKeyResolver}"
            - RewritePath=/api/(?<segment>.*), /$\{segment}
            - name: Retry
              args:
                retries: 3
                statuses: BAD_GATEWAY,SERVICE_UNAVAILABLE
                methods: GET
                backoff:
                  firstBackoff: 50ms
                  maxBackoff: 500ms

        # Wallet Service Routes
        - id: wallet-service
          uri: lb://WALLET-SERVICE
          predicates:
            - Path=/api/wallet/**, /api/transactions/**
          filters:
            - name: CircuitBreaker
              args:
                name: walletServiceCircuitBreaker
                fallbackUri: forward:/fallback/wallet-service
            - name: RequestRateLimiter
              args:
                redis-rate-limiter.replenishRate: 50
                redis-rate-limiter.burstCapacity: 100
                key-resolver: "#{@userKeyResolver}"
            - AuthenticationFilter
            - RewritePath=/api/(?<segment>.*), /$\{segment}

        # Investment Service Routes
        - id: investment-service
          uri: lb://INVESTMENT-SERVICE
          predicates:
            - Path=/api/investments/**, /api/portfolio/**
          filters:
            - name: CircuitBreaker
              args:
                name: investmentServiceCircuitBreaker
                fallbackUri: forward:/fallback/investment-service
            - name: RequestRateLimiter
              args:
                redis-rate-limiter.replenishRate: 100
                redis-rate-limiter.burstCapacity: 150
                key-resolver: "#{@userKeyResolver}"
            - AuthenticationFilter
            - RewritePath=/api/(?<segment>.*), /$\{segment}

        # Analytics Service Routes
        - id: analytics-service
          uri: lb://ANALYTICS-SERVICE
          predicates:
            - Path=/api/analytics/**
          filters:
            - name: CircuitBreaker
              args:
                name: analyticsServiceCircuitBreaker
            - name: RequestRateLimiter
              args:
                redis-rate-limiter.replenishRate: 30
                redis-rate-limiter.burstCapacity: 60
                key-resolver: "#{@userKeyResolver}"
            - AuthenticationFilter
            - RewritePath=/api/(?<segment>.*), /$\{segment}

        # Notification Service Routes
        - id: notification-service
          uri: lb://NOTIFICATION-SERVICE
          predicates:
            - Path=/api/notifications/**
          filters:
            - AuthenticationFilter
            - RewritePath=/api/(?<segment>.*), /$\{segment}

      # Default Filters (applied to all routes)
      default-filters:
        - name: RequestTime
        - name: Retry
          args:
            retries: 2
            statuses: SERVICE_UNAVAILABLE

  # Redis Configuration
  redis:
    host: ${REDIS_HOST:localhost}
    port: ${REDIS_PORT:6379}
    password: ${REDIS_PASSWORD:}
    timeout: 2000ms

  # Security
  security:
    oauth2:
      resourceserver:
        jwt:
          issuer-uri: http://localhost:8081

# Eureka Configuration
eureka:
  client:
    serviceUrl:
      defaultZone: ${EUREKA_URL:http://localhost:8761/eureka/}
    fetch-registry: true
    register-with-eureka: true
  instance:
    prefer-ip-address: true
    lease-renewal-interval-in-seconds: 10

# Circuit Breaker Configuration
resilience4j:
  circuitbreaker:
    configs:
      default:
        registerHealthIndicator: true
        slidingWindowSize: 10
        minimumNumberOfCalls: 5
        permittedNumberOfCallsInHalfOpenState: 3
        automaticTransitionFromOpenToHalfOpenEnabled: true
        waitDurationInOpenState: 10s
        failureRateThreshold: 50
        eventConsumerBufferSize: 10
    instances:
      userServiceCircuitBreaker:
        baseConfig: default
      walletServiceCircuitBreaker:
        baseConfig: default
      investmentServiceCircuitBreaker:
        baseConfig: default
      analyticsServiceCircuitBreaker:
        baseConfig: default

  timelimiter:
    configs:
      default:
        timeoutDuration: 5s

# JWT Configuration
jwt:
  secret: ${JWT_SECRET}

# Logging
logging:
  level:
    root: INFO
    org.springframework.cloud.gateway: DEBUG
    org.springframework.security: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"

# Actuator
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics,prometheus,gateway
  endpoint:
    health:
      show-details: always
  metrics:
    export:
      prometheus:
        enabled: true
```

### 3. Main Application Class

```java
package com.fintech.gateway;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class ApiGatewayApplication {
    public static void main(String[] args) {
        SpringApplication.run(ApiGatewayApplication.class, args);
    }
}
```

### 4. Authentication Filter

```java
package com.fintech.gateway.filter;

import com.fintech.gateway.util.JwtUtil;
import io.jsonwebtoken.Claims;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.reactive.ServerHttpRequest;
import org.springframework.http.server.reactive.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Component
public class AuthenticationFilter extends AbstractGatewayFilterFactory<AuthenticationFilter.Config> {

    @Autowired
    private JwtUtil jwtUtil;

    public AuthenticationFilter() {
        super(Config.class);
    }

    @Override
    public GatewayFilter apply(Config config) {
        return (exchange, chain) -> {
            ServerHttpRequest request = exchange.getRequest();

            // Check if Authorization header exists
            if (!request.getHeaders().containsKey(HttpHeaders.AUTHORIZATION)) {
                return onError(exchange, "Missing authorization header", HttpStatus.UNAUTHORIZED);
            }

            String authHeader = request.getHeaders().get(HttpHeaders.AUTHORIZATION).get(0);

            if (authHeader == null || !authHeader.startsWith("Bearer ")) {
                return onError(exchange, "Invalid authorization header", HttpStatus.UNAUTHORIZED);
            }

            String token = authHeader.substring(7);

            try {
                // Validate token
                if (!jwtUtil.validateToken(token)) {
                    return onError(exchange, "Invalid token", HttpStatus.UNAUTHORIZED);
                }

                // Extract claims
                Claims claims = jwtUtil.getAllClaimsFromToken(token);
                String userId = claims.getSubject();
                String email = claims.get("email", String.class);
                String role = claims.get("role", String.class);

                // Add user info to request headers for downstream services
                ServerHttpRequest modifiedRequest = exchange.getRequest()
                    .mutate()
                    .header("X-User-Id", userId)
                    .header("X-User-Email", email)
                    .header("X-User-Role", role)
                    .build();

                return chain.filter(exchange.mutate().request(modifiedRequest).build());

            } catch (Exception e) {
                return onError(exchange, "Token validation failed: " + e.getMessage(),
                              HttpStatus.UNAUTHORIZED);
            }
        };
    }

    private Mono<Void> onError(ServerWebExchange exchange, String err, HttpStatus httpStatus) {
        ServerHttpResponse response = exchange.getResponse();
        response.setStatusCode(httpStatus);
        response.getHeaders().add("Content-Type", "application/json");

        String errorResponse = String.format(
            "{\"success\": false, \"error\": {\"message\": \"%s\"}}", err
        );

        return response.writeWith(
            Mono.just(response.bufferFactory().wrap(errorResponse.getBytes()))
        );
    }

    public static class Config {
        // Configuration properties if needed
    }
}
```

### 5. JWT Utility

```java
package com.fintech.gateway.util;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;

@Component
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secret;

    private SecretKey getSigningKey() {
        byte[] keyBytes = secret.getBytes(StandardCharsets.UTF_8);
        return Keys.hmacShaKeyFor(keyBytes);
    }

    public Claims getAllClaimsFromToken(String token) {
        return Jwts.parserBuilder()
            .setSigningKey(getSigningKey())
            .build()
            .parseClaimsJws(token)
            .getBody();
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public String getUserIdFromToken(String token) {
        return getAllClaimsFromToken(token).getSubject();
    }
}
```

### 6. User Key Resolver (for Rate Limiting)

```java
package com.fintech.gateway.config;

import org.springframework.cloud.gateway.filter.ratelimit.KeyResolver;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import reactor.core.publisher.Mono;

@Configuration
public class RateLimiterConfig {

    @Bean
    public KeyResolver userKeyResolver() {
        return exchange -> {
            // Extract user ID from header (set by AuthenticationFilter)
            String userId = exchange.getRequest().getHeaders().getFirst("X-User-Id");

            if (userId != null) {
                return Mono.just(userId);
            }

            // Fallback to IP address for unauthenticated requests
            String ipAddress = exchange.getRequest().getRemoteAddress() != null
                ? exchange.getRequest().getRemoteAddress().getAddress().getHostAddress()
                : "unknown";

            return Mono.just(ipAddress);
        };
    }

    @Bean
    public KeyResolver ipKeyResolver() {
        return exchange -> Mono.just(
            exchange.getRequest().getRemoteAddress() != null
                ? exchange.getRequest().getRemoteAddress().getAddress().getHostAddress()
                : "unknown"
        );
    }
}
```

### 7. Fallback Controller

```java
package com.fintech.gateway.controller;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/fallback")
public class FallbackController {

    @GetMapping("/user-service")
    public ResponseEntity<Map<String, Object>> userServiceFallback() {
        return buildFallbackResponse("User Service is currently unavailable");
    }

    @GetMapping("/wallet-service")
    public ResponseEntity<Map<String, Object>> walletServiceFallback() {
        return buildFallbackResponse("Wallet Service is currently unavailable");
    }

    @GetMapping("/investment-service")
    public ResponseEntity<Map<String, Object>> investmentServiceFallback() {
        return buildFallbackResponse("Investment Service is currently unavailable");
    }

    private ResponseEntity<Map<String, Object>> buildFallbackResponse(String message) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", false);

        Map<String, String> error = new HashMap<>();
        error.put("code", "SERVICE_UNAVAILABLE");
        error.put("message", message);

        response.put("error", error);

        return ResponseEntity
            .status(HttpStatus.SERVICE_UNAVAILABLE)
            .body(response);
    }
}
```

### 8. Custom Request Time Filter

```java
package com.fintech.gateway.filter;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.cloud.gateway.filter.GatewayFilterChain;
import org.springframework.cloud.gateway.filter.GlobalFilter;
import org.springframework.core.Ordered;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;
import reactor.core.publisher.Mono;

@Component
public class RequestTimeFilter implements GlobalFilter, Ordered {

    private static final Logger logger = LoggerFactory.getLogger(RequestTimeFilter.class);
    private static final String REQUEST_TIME_ATTRIBUTE = "requestTime";

    @Override
    public Mono<Void> filter(ServerWebExchange exchange, GatewayFilterChain chain) {
        exchange.getAttributes().put(REQUEST_TIME_ATTRIBUTE, System.currentTimeMillis());

        return chain.filter(exchange).then(
            Mono.fromRunnable(() -> {
                Long startTime = exchange.getAttribute(REQUEST_TIME_ATTRIBUTE);
                if (startTime != null) {
                    long duration = System.currentTimeMillis() - startTime;
                    String path = exchange.getRequest().getURI().getPath();
                    String method = exchange.getRequest().getMethod().toString();
                    int statusCode = exchange.getResponse().getStatusCode() != null
                        ? exchange.getResponse().getStatusCode().value()
                        : 0;

                    logger.info("Request: {} {} - Status: {} - Duration: {}ms",
                               method, path, statusCode, duration);
                }
            })
        );
    }

    @Override
    public int getOrder() {
        return Ordered.LOWEST_PRECEDENCE;
    }
}
```

### 9. CORS Configuration

```java
package com.fintech.gateway.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.reactive.CorsWebFilter;
import org.springframework.web.cors.reactive.UrlBasedCorsConfigurationSource;

import java.util.Arrays;
import java.util.Collections;

@Configuration
public class CorsConfig {

    @Bean
    public CorsWebFilter corsWebFilter() {
        CorsConfiguration corsConfig = new CorsConfiguration();
        corsConfig.setAllowedOrigins(Arrays.asList(
            "http://localhost:3000",
            "https://app.fintech.com"
        ));
        corsConfig.setMaxAge(3600L);
        corsConfig.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        corsConfig.setAllowedHeaders(Collections.singletonList("*"));
        corsConfig.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", corsConfig);

        return new CorsWebFilter(source);
    }
}
```

## Testing the Gateway

### 1. Health Check
```bash
curl http://localhost:8080/actuator/health
```

### 2. Test Authentication Flow
```bash
# Login (no auth required)
curl -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'

# Get user info (auth required)
curl http://localhost:8080/api/users/me \
  -H "Authorization: Bearer <access_token>"
```

### 3. Test Rate Limiting
```bash
# Send 101 requests quickly to trigger rate limit
for i in {1..101}; do
  curl http://localhost:8080/api/wallet/accounts \
    -H "Authorization: Bearer <token>"
done
```

### 4. Test Circuit Breaker
```bash
# Stop a service and watch the fallback trigger
docker stop wallet-service

curl http://localhost:8080/api/wallet/accounts \
  -H "Authorization: Bearer <token>"

# Should return fallback response
```

## Monitoring

### Prometheus Metrics
```bash
curl http://localhost:8080/actuator/prometheus
```

### Gateway Routes
```bash
curl http://localhost:8080/actuator/gateway/routes
```

## Key Features Summary

✅ **Service Discovery**: Automatically routes to healthy service instances via Eureka
✅ **Load Balancing**: Built-in client-side load balancing with Ribbon
✅ **Rate Limiting**: Redis-backed per-user rate limiting
✅ **Circuit Breaker**: Resilience4j for fault tolerance
✅ **JWT Authentication**: Centralized token validation
✅ **CORS Handling**: Configured for web and mobile clients
✅ **Request Logging**: Tracks request duration and status
✅ **Fallback Routes**: Graceful degradation when services are down
✅ **Retry Logic**: Automatic retries for transient failures
✅ **Path Rewriting**: Clean URL transformation

## Performance Considerations

1. **Redis Connection Pool**: Configure appropriately for high throughput
2. **WebFlux**: Non-blocking reactive gateway for better performance
3. **Connection Timeouts**: Set reasonable timeouts to prevent cascading failures
4. **Circuit Breaker Tuning**: Adjust based on your traffic patterns
5. **Rate Limit Tuning**: Balance between user experience and resource protection

This configuration provides a production-ready API Gateway that handles cross-cutting concerns while allowing your microservices to focus on business logic!
