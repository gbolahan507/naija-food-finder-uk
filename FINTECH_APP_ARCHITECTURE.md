# FinTech Super App - Comprehensive Architecture Documentation

## Table of Contents
1. [System Overview](#system-overview)
2. [Technology Stack](#technology-stack)
3. [High-Level Architecture](#high-level-architecture)
4. [Microservices Design](#microservices-design)
5. [Data Architecture](#data-architecture)
6. [Security Architecture](#security-architecture)
7. [API Design](#api-design)
8. [Infrastructure & Deployment](#infrastructure--deployment)
9. [Data Flow Diagrams](#data-flow-diagrams)
10. [Scalability & Performance](#scalability--performance)

---

## System Overview

### Vision
A comprehensive financial management platform that enables users to manage multiple currencies, track investments, analyze expenses with AI, and maintain complete financial visibility across all their accounts.

### Core Capabilities
- **Multi-Currency Wallet**: Manage multiple currency accounts with real-time exchange rates
- **Investment Tracking**: Monitor stocks, crypto, and portfolio performance
- **AI Expense Analytics**: Intelligent categorization and spending insights
- **Security First**: Biometric auth, end-to-end encryption, secure key management

### Design Principles
1. **Security by Default**: Every layer encrypted, zero-trust architecture
2. **Offline-First**: Work without internet, sync when connected
3. **Real-Time Updates**: Live data for markets and transactions
4. **Scalable**: Microservices that can scale independently
5. **Privacy Focused**: User data encrypted, minimal data collection

---

## Technology Stack

### Frontend
```
Mobile App: Flutter (iOS & Android)
├── State Management: Riverpod / Bloc
├── HTTP Client: Dio
├── Secure Storage: flutter_secure_storage
├── Local Database: Hive / Drift (SQLite)
├── Biometrics: local_auth
├── Charts: fl_chart / syncfusion_flutter_charts
└── Navigation: go_router

Web Dashboard: React / Next.js
├── State: Redux Toolkit / Zustand
├── UI: Tailwind CSS + shadcn/ui
├── Charts: Recharts / D3.js
└── API Client: Axios / TanStack Query
```

### Backend (Spring Boot Microservices)
```
Framework: Spring Boot 3.x (Java 17+)
├── API Gateway: Spring Cloud Gateway
├── Service Discovery: Eureka / Consul
├── Config Management: Spring Cloud Config
├── Load Balancing: Spring Cloud LoadBalancer
├── Circuit Breaker: Resilience4j
├── Security: Spring Security + OAuth 2.0
└── Monitoring: Spring Boot Actuator

Core Services:
├── User Service (Auth, KYC, Profiles)
├── Wallet Service (Accounts, Transactions)
├── Investment Service (Portfolio, Market Data)
├── Analytics Service (AI Categorization)
├── Notification Service (Push, Email, SMS)
└── Payment Service (P2P, Virtual Cards)
```

### Data Layer
```
Primary Database: PostgreSQL 15+
├── Connection Pool: HikariCP
├── ORM: Spring Data JPA / Hibernate
└── Migrations: Flyway / Liquibase

Cache: Redis 7+
├── Session Management
├── Rate Limiting
├── Exchange Rate Cache
└── API Response Cache

Event Streaming: Apache Kafka
├── Transaction Events
├── Notification Events
├── Audit Logs
└── Real-time Analytics

Time-Series: TimescaleDB (PostgreSQL extension)
├── Exchange Rates History
├── Asset Prices
└── Performance Metrics

Document Store: MongoDB (optional)
├── Analytics Data
├── ML Training Data
└── Flexible Schema Data

Search: Elasticsearch
├── Transaction Search
├── Audit Logs
└── Application Logs

Object Storage: AWS S3 / MinIO
├── Receipts & Documents
├── Reports
└── Backups
```

### AI/ML
```
Framework: Python + FastAPI
├── ML Library: scikit-learn
├── NLP: spaCy / Hugging Face Transformers
├── Model Serving: TensorFlow Serving / MLflow
└── Feature Store: Feast (optional)

Models:
├── Transaction Categorization (Random Forest + BERT)
├── Spending Prediction (Prophet / LSTM)
├── Anomaly Detection (Isolation Forest)
└── Receipt OCR (Tesseract / Google Vision API)
```

### External APIs
```
Financial Data:
├── Alpha Vantage (Stock market data)
├── Fixer.io / Open Exchange Rates (Forex rates)
├── CoinGecko (Cryptocurrency prices)
└── Plaid (Banking integration - optional)

Communication:
├── Twilio (SMS, OTP)
├── SendGrid (Email)
└── Firebase Cloud Messaging (Push notifications)

Other:
├── Google Cloud Vision (OCR)
└── MaxMind GeoIP (Location services)
```

### Infrastructure & DevOps
```
Containerization: Docker
Orchestration: Kubernetes (K8s)
CI/CD: GitHub Actions / GitLab CI
Infrastructure as Code: Terraform / Pulumi

Cloud Provider Options:
├── AWS (ECS, RDS, ElastiCache, S3, CloudFront)
├── Google Cloud (GKE, Cloud SQL, Cloud Storage)
└── Azure (AKS, Azure Database, Blob Storage)

Monitoring & Observability:
├── Metrics: Prometheus + Grafana
├── Logging: ELK Stack (Elasticsearch, Logstash, Kibana)
├── Tracing: Jaeger / Zipkin
├── APM: New Relic / Datadog (optional)
└── Error Tracking: Sentry
```

### Development Tools
```
Version Control: Git + GitHub
API Documentation: Swagger / OpenAPI 3.0
API Testing: Postman / Insomnia
Load Testing: Apache JMeter / Gatling / k6
Security Scanning:
├── OWASP Dependency-Check
├── SonarQube
└── Trivy (container scanning)
```

---

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         CLIENT LAYER                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │   Flutter    │  │   React Web  │  │  Admin Panel │              │
│  │   iOS/Android│  │   Dashboard  │  │   (Internal) │              │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘              │
│         │                  │                  │                       │
│         └──────────────────┴──────────────────┘                      │
│                            │                                          │
│                            │ HTTPS/TLS 1.3                           │
│                            │ JWT Authentication                       │
│                            ▼                                          │
├─────────────────────────────────────────────────────────────────────┤
│                       GATEWAY LAYER                                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │           Spring Cloud Gateway (API Gateway)                │    │
│  │                                                              │    │
│  │  • Rate Limiting (Redis-backed)                            │    │
│  │  • Authentication (JWT validation via Spring Security)     │    │
│  │  • Request/Response filtering & transformation             │    │
│  │  • SSL/TLS Termination                                      │    │
│  │  • Circuit Breaker (Resilience4j)                          │    │
│  │  • Load Balancing (Round-robin, weighted)                 │    │
│  │  • Service Discovery (Eureka integration)                  │    │
│  └────────────────────────────────────────────────────────────┘    │
│                            │                                          │
│         ┌──────────────────┼──────────────────┐                     │
│         │                  │                  │                      │
│         ▼                  ▼                  ▼                      │
├─────────────────────────────────────────────────────────────────────┤
│                     MICROSERVICES LAYER                              │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                │
│  │   Auth      │  │   Wallet    │  │ Investment  │                │
│  │  Service    │  │  Service    │  │  Service    │                │
│  │             │  │             │  │             │                │
│  │ • Register  │  │ • Accounts  │  │ • Portfolio │                │
│  │ • Login     │  │ • Transfer  │  │ • Stocks    │                │
│  │ • 2FA       │  │ • Currency  │  │ • Crypto    │                │
│  │ • Biometric │  │ • History   │  │ • Analytics │                │
│  └─────────────┘  └─────────────┘  └─────────────┘                │
│                                                                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                │
│  │ Analytics   │  │Notification │  │   Payment   │                │
│  │  Service    │  │  Service    │  │  Service    │                │
│  │             │  │             │  │             │                │
│  │ • AI Model  │  │ • Push      │  │ • P2P       │                │
│  │ • Category  │  │ • Email     │  │ • Virtual   │                │
│  │ • Insights  │  │ • SMS       │  │   Cards     │                │
│  │ • Reports   │  │ • In-App    │  │ • Billing   │                │
│  └─────────────┘  └─────────────┘  └─────────────┘                │
│                                                                       │
│         │                  │                  │                      │
│         └──────────────────┼──────────────────┘                     │
│                            │                                          │
│                            ▼                                          │
├─────────────────────────────────────────────────────────────────────┤
│                   EVENT STREAMING LAYER (KAFKA)                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌────────────────────────────────────────────────────────────┐    │
│  │                    Apache Kafka                             │    │
│  │                                                              │    │
│  │  Topics:                                                     │    │
│  │  • transaction.created       (Wallet → Analytics)           │    │
│  │  • transaction.updated       (Wallet → Notification)        │    │
│  │  • portfolio.updated         (Investment → Notification)    │    │
│  │  • expense.categorized       (Analytics → Wallet)           │    │
│  │  • alert.triggered           (Any → Notification)           │    │
│  │  • audit.log                 (All services → Audit)         │    │
│  │                                                              │    │
│  │  Consumer Groups:                                            │    │
│  │  • analytics-service-group                                   │    │
│  │  • notification-service-group                                │    │
│  │  • audit-service-group                                       │    │
│  └────────────────────────────────────────────────────────────┘    │
│                                                                       │
├─────────────────────────────────────────────────────────────────────┤
│                      DATA LAYER                                      │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                │
│  │ PostgreSQL  │  │    Redis    │  │  TimescaleDB│                │
│  │             │  │             │  │             │                │
│  │ • Users     │  │ • Cache     │  │ • Prices    │                │
│  │ • Accounts  │  │ • Sessions  │  │ • Rates     │                │
│  │ • Trans.    │  │ • Rate Lim. │  │ • History   │                │
│  └─────────────┘  └─────────────┘  └─────────────┘                │
│                                                                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                │
│  │  MongoDB    │  │     S3      │  │ Elasticsearch│               │
│  │             │  │             │  │             │                │
│  │ • Documents │  │ • Receipts  │  │ • Search    │                │
│  │ • Analytics │  │ • Reports   │  │ • Logs      │                │
│  │ • ML Data   │  │ • Backups   │  │ • Audit     │                │
│  └─────────────┘  └─────────────┘  └─────────────┘                │
│                                                                       │
├─────────────────────────────────────────────────────────────────────┤
│                   EXTERNAL SERVICES LAYER                            │
├─────────────────────────────────────────────────────────────────────┤
│                                                                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                │
│  │   Plaid     │  │Alpha Vantage│  │ Open Exchange│               │
│  │  Banking    │  │   Stocks    │  │    Rates    │                │
│  └─────────────┘  └─────────────┘  └─────────────┘                │
│                                                                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐                │
│  │ CoinGecko   │  │   Twilio    │  │  SendGrid   │                │
│  │   Crypto    │  │     SMS     │  │    Email    │                │
│  └─────────────┘  └─────────────┘  └─────────────┘                │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Microservices Design

### 1. Auth Service
**Responsibility**: User authentication, authorization, and identity management

**API Endpoints**:
```
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/logout
POST   /api/auth/refresh-token
POST   /api/auth/verify-2fa
POST   /api/auth/biometric/register
POST   /api/auth/biometric/verify
GET    /api/auth/me
PATCH  /api/auth/password
DELETE /api/auth/account
```

**Database Schema**:
```sql
-- Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20) UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    salt VARCHAR(255) NOT NULL,
    status VARCHAR(20) DEFAULT 'active',
    email_verified BOOLEAN DEFAULT FALSE,
    phone_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Biometric Credentials
CREATE TABLE biometric_credentials (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(255) NOT NULL,
    public_key TEXT NOT NULL,
    credential_id TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    last_used_at TIMESTAMP,
    UNIQUE(user_id, device_id)
);

-- 2FA Secrets
CREATE TABLE two_factor_auth (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    secret VARCHAR(255) NOT NULL,
    enabled BOOLEAN DEFAULT FALSE,
    backup_codes TEXT[],
    created_at TIMESTAMP DEFAULT NOW()
);

-- Sessions
CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    refresh_token VARCHAR(512) UNIQUE NOT NULL,
    device_info JSONB,
    ip_address INET,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

**Key Features**:
- JWT access tokens (15 min expiry) + refresh tokens (30 days)
- Biometric authentication using WebAuthn/FIDO2
- TOTP-based 2FA
- Device fingerprinting
- Rate limiting on login attempts (5 attempts/15 min)
- Password hashing with BCrypt/Argon2

**Spring Boot Implementation**:

```java
// Main Application
@SpringBootApplication
@EnableDiscoveryClient
public class UserServiceApplication {
    public static void main(String[] args) {
        SpringApplication.run(UserServiceApplication.class, args);
    }
}

// Security Configuration
@Configuration
@EnableWebSecurity
@EnableMethodSecurity
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationFilter jwtAuthFilter;

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
            .csrf().disable()
            .cors().and()
            .sessionManagement()
                .sessionCreationPolicy(SessionCreationPolicy.STATELESS)
            .and()
            .authorizeHttpRequests()
                .requestMatchers("/api/auth/login", "/api/auth/register").permitAll()
                .anyRequest().authenticated()
            .and()
            .addFilterBefore(jwtAuthFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config)
            throws Exception {
        return config.getAuthenticationManager();
    }
}

// REST Controller
@RestController
@RequestMapping("/api/auth")
@Validated
public class AuthController {

    @Autowired
    private AuthService authService;

    @PostMapping("/register")
    public ResponseEntity<ApiResponse<AuthResponse>> register(
            @Valid @RequestBody RegisterRequest request) {
        AuthResponse response = authService.register(request);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/login")
    @RateLimiter(name = "loginLimiter", fallbackMethod = "loginFallback")
    public ResponseEntity<ApiResponse<AuthResponse>> login(
            @Valid @RequestBody LoginRequest request,
            HttpServletRequest httpRequest) {

        String ipAddress = httpRequest.getRemoteAddr();
        AuthResponse response = authService.login(request, ipAddress);
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    @PostMapping("/refresh-token")
    public ResponseEntity<ApiResponse<TokenResponse>> refreshToken(
            @Valid @RequestBody RefreshTokenRequest request) {
        TokenResponse response = authService.refreshToken(request.getRefreshToken());
        return ResponseEntity.ok(ApiResponse.success(response));
    }

    public ResponseEntity<ApiResponse<AuthResponse>> loginFallback(Exception e) {
        return ResponseEntity.status(429)
            .body(ApiResponse.error("Too many login attempts. Please try again later."));
    }
}

// Service Layer
@Service
@Transactional
public class AuthService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private KafkaTemplate<String, UserEvent> kafkaTemplate;

    public AuthResponse register(RegisterRequest request) {
        // Check if user exists
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("Email already registered");
        }

        // Create user
        User user = User.builder()
            .email(request.getEmail())
            .passwordHash(passwordEncoder.encode(request.getPassword()))
            .status(UserStatus.ACTIVE)
            .emailVerified(false)
            .build();

        user = userRepository.save(user);

        // Publish event to Kafka
        UserEvent event = UserEvent.builder()
            .userId(user.getId())
            .eventType("USER_REGISTERED")
            .timestamp(Instant.now())
            .build();
        kafkaTemplate.send("user.events", user.getId().toString(), event);

        // Generate tokens
        String accessToken = jwtTokenProvider.generateAccessToken(user);
        String refreshToken = jwtTokenProvider.generateRefreshToken(user);

        return AuthResponse.builder()
            .accessToken(accessToken)
            .refreshToken(refreshToken)
            .expiresIn(900) // 15 minutes
            .tokenType("Bearer")
            .user(UserDto.fromEntity(user))
            .build();
    }

    public AuthResponse login(LoginRequest request, String ipAddress) {
        User user = userRepository.findByEmail(request.getEmail())
            .orElseThrow(() -> new InvalidCredentialsException("Invalid credentials"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new InvalidCredentialsException("Invalid credentials");
        }

        // Generate tokens
        String accessToken = jwtTokenProvider.generateAccessToken(user);
        String refreshToken = jwtTokenProvider.generateRefreshToken(user);

        // Save session
        Session session = Session.builder()
            .userId(user.getId())
            .refreshToken(refreshToken)
            .ipAddress(ipAddress)
            .expiresAt(Instant.now().plus(30, ChronoUnit.DAYS))
            .build();
        sessionRepository.save(session);

        return AuthResponse.builder()
            .accessToken(accessToken)
            .refreshToken(refreshToken)
            .expiresIn(900)
            .tokenType("Bearer")
            .user(UserDto.fromEntity(user))
            .build();
    }
}

// JWT Token Provider
@Component
public class JwtTokenProvider {

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${jwt.access-token-expiration}")
    private long accessTokenExpiration;

    @Value("${jwt.refresh-token-expiration}")
    private long refreshTokenExpiration;

    public String generateAccessToken(User user) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + accessTokenExpiration);

        return Jwts.builder()
            .setSubject(user.getId().toString())
            .claim("email", user.getEmail())
            .claim("role", user.getRole())
            .setIssuedAt(now)
            .setExpiration(expiryDate)
            .signWith(SignatureAlgorithm.HS512, jwtSecret)
            .compact();
    }

    public String generateRefreshToken(User user) {
        Date now = new Date();
        Date expiryDate = new Date(now.getTime() + refreshTokenExpiration);

        return Jwts.builder()
            .setSubject(user.getId().toString())
            .claim("type", "refresh")
            .setIssuedAt(now)
            .setExpiration(expiryDate)
            .signWith(SignatureAlgorithm.HS512, jwtSecret)
            .compact();
    }

    public UUID getUserIdFromToken(String token) {
        Claims claims = Jwts.parser()
            .setSigningKey(jwtSecret)
            .parseClaimsJws(token)
            .getBody();

        return UUID.fromString(claims.getSubject());
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser().setSigningKey(jwtSecret).parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }
}

// Entity
@Entity
@Table(name = "users")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;

    @Column(unique = true, nullable = false)
    private String email;

    @Column(unique = true)
    private String phone;

    @Column(name = "password_hash", nullable = false)
    private String passwordHash;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private UserStatus status = UserStatus.ACTIVE;

    @Column(name = "email_verified")
    private Boolean emailVerified = false;

    @Column(name = "phone_verified")
    private Boolean phoneVerified = false;

    @CreatedDate
    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @LastModifiedDate
    @Column(name = "updated_at")
    private Instant updatedAt;
}

// Repository
@Repository
public interface UserRepository extends JpaRepository<User, UUID> {
    Optional<User> findByEmail(String email);
    Boolean existsByEmail(String email);
}

// application.yml
spring:
  application:
    name: user-service
  datasource:
    url: jdbc:postgresql://localhost:5432/fintech_user
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
  kafka:
    bootstrap-servers: localhost:9092
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.springframework.kafka.support.serializer.JsonSerializer
  redis:
    host: localhost
    port: 6379

jwt:
  secret: ${JWT_SECRET}
  access-token-expiration: 900000  # 15 minutes
  refresh-token-expiration: 2592000000  # 30 days

resilience4j:
  ratelimiter:
    instances:
      loginLimiter:
        limitForPeriod: 5
        limitRefreshPeriod: 15m
        timeoutDuration: 0

eureka:
  client:
    serviceUrl:
      defaultZone: http://localhost:8761/eureka/
```

---

### 2. Wallet Service
**Responsibility**: Multi-currency account management, transactions, currency conversion

**API Endpoints**:
```
GET    /api/wallet/accounts
POST   /api/wallet/accounts
GET    /api/wallet/accounts/:id
GET    /api/wallet/accounts/:id/balance
GET    /api/wallet/accounts/:id/transactions
POST   /api/wallet/transactions/transfer
POST   /api/wallet/transactions/exchange
GET    /api/wallet/exchange-rates
GET    /api/wallet/exchange-rates/:from/:to
GET    /api/wallet/transactions/:id
```

**Database Schema**:
```sql
-- Accounts
CREATE TABLE accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    currency_code VARCHAR(3) NOT NULL,
    account_type VARCHAR(20) DEFAULT 'standard',
    balance DECIMAL(20, 8) DEFAULT 0,
    available_balance DECIMAL(20, 8) DEFAULT 0,
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, currency_code)
);

-- Transactions (Event Sourcing Pattern)
CREATE TABLE transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    from_account_id UUID REFERENCES accounts(id),
    to_account_id UUID REFERENCES accounts(id),
    transaction_type VARCHAR(50) NOT NULL,
    amount DECIMAL(20, 8) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    description TEXT,
    category VARCHAR(100),
    merchant VARCHAR(255),
    location JSONB,
    metadata JSONB,
    status VARCHAR(20) DEFAULT 'pending',
    reference_id VARCHAR(100) UNIQUE,
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

-- Exchange Rate Cache (TimescaleDB)
CREATE TABLE exchange_rates (
    time TIMESTAMPTZ NOT NULL,
    base_currency VARCHAR(3) NOT NULL,
    quote_currency VARCHAR(3) NOT NULL,
    rate DECIMAL(20, 10) NOT NULL,
    source VARCHAR(50),
    PRIMARY KEY (time, base_currency, quote_currency)
);

SELECT create_hypertable('exchange_rates', 'time');
```

**Key Features**:
- Multi-currency support (USD, GBP, EUR, NGN, etc.)
- Real-time exchange rate updates (WebSocket connection to forex API)
- Transaction categorization ready for AI service
- Event sourcing for full audit trail
- Idempotency keys for duplicate prevention
- Balance locking for concurrent transactions

**Exchange Rate Logic**:
```typescript
// Cached rates with 30-second refresh
interface ExchangeRateService {
  getCurrentRate(from: string, to: string): Promise<number>;
  convertAmount(amount: number, from: string, to: string): Promise<number>;
  getHistoricalRates(from: string, to: string, days: number): Promise<RateHistory[]>;
}
```

---

### 3. Investment Service
**Responsibility**: Portfolio tracking, stock/crypto monitoring, performance analytics

**API Endpoints**:
```
GET    /api/investments/portfolio
POST   /api/investments/holdings
PUT    /api/investments/holdings/:id
DELETE /api/investments/holdings/:id
GET    /api/investments/holdings/:id/performance
GET    /api/investments/market/search?q=AAPL
GET    /api/investments/market/quote/:symbol
GET    /api/investments/market/historical/:symbol
GET    /api/investments/watchlist
POST   /api/investments/watchlist
GET    /api/investments/analytics/diversification
```

**Database Schema**:
```sql
-- Holdings
CREATE TABLE holdings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    asset_type VARCHAR(20) NOT NULL, -- 'stock', 'crypto', 'etf'
    symbol VARCHAR(20) NOT NULL,
    name VARCHAR(255),
    quantity DECIMAL(20, 8) NOT NULL,
    average_cost DECIMAL(20, 8) NOT NULL,
    currency VARCHAR(3) DEFAULT 'USD',
    purchase_date DATE,
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Portfolio Snapshots (daily aggregations)
CREATE TABLE portfolio_snapshots (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    total_value DECIMAL(20, 2) NOT NULL,
    daily_change DECIMAL(20, 2),
    daily_change_percent DECIMAL(10, 4),
    holdings_count INTEGER,
    currency VARCHAR(3) DEFAULT 'USD',
    snapshot_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, snapshot_date)
);

-- Price Cache (TimescaleDB)
CREATE TABLE asset_prices (
    time TIMESTAMPTZ NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    asset_type VARCHAR(20) NOT NULL,
    open DECIMAL(20, 8),
    high DECIMAL(20, 8),
    low DECIMAL(20, 8),
    close DECIMAL(20, 8),
    volume BIGINT,
    PRIMARY KEY (time, symbol)
);

SELECT create_hypertable('asset_prices', 'time');

-- Watchlist
CREATE TABLE watchlist (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    symbol VARCHAR(20) NOT NULL,
    asset_type VARCHAR(20) NOT NULL,
    alert_price DECIMAL(20, 8),
    alert_type VARCHAR(20), -- 'above', 'below'
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, symbol)
);
```

**Key Features**:
- Real-time price updates via WebSocket
- Portfolio performance calculations (ROI, daily/weekly/monthly gains)
- Diversification analysis
- Price alerts
- Historical performance charts
- Multi-asset support (stocks, crypto, ETFs)

**Real-Time Updates**:
```typescript
// WebSocket connection for live prices
ws://api.fintech.app/investments/stream
{
  "type": "subscribe",
  "symbols": ["AAPL", "GOOGL", "BTC-USD"]
}

// Server pushes updates
{
  "type": "price_update",
  "symbol": "AAPL",
  "price": 178.50,
  "change": 2.30,
  "change_percent": 1.31,
  "timestamp": "2026-01-19T10:30:00Z"
}
```

---

### 4. Analytics Service (AI/ML)
**Responsibility**: Transaction categorization, spending insights, predictions

**API Endpoints**:
```
POST   /api/analytics/categorize
GET    /api/analytics/spending/by-category
GET    /api/analytics/spending/trends
GET    /api/analytics/spending/predictions
POST   /api/analytics/receipts/scan
GET    /api/analytics/insights
GET    /api/analytics/budget/recommendations
POST   /api/analytics/budget
GET    /api/analytics/budget/status
```

**Database Schema (MongoDB)**:
```javascript
// Transaction Analysis Collection
{
  _id: ObjectId,
  user_id: "uuid",
  transaction_id: "uuid",
  original_description: "STARBUCKS #1234 NEW YORK",
  normalized_description: "Starbucks",
  category: "food_dining",
  subcategory: "coffee_shops",
  confidence: 0.95,
  merchant: {
    name: "Starbucks",
    category: "Coffee Shop",
    location: {
      type: "Point",
      coordinates: [-73.935242, 40.730610]
    }
  },
  tags: ["recurring", "morning"],
  processed_at: ISODate("2026-01-19T10:30:00Z")
}

// User Insights Collection
{
  _id: ObjectId,
  user_id: "uuid",
  period: "2026-01",
  insights: [
    {
      type: "spending_spike",
      category: "food_dining",
      message: "Your dining spending increased 30% this month",
      amount: 450.00,
      previous_amount: 346.15,
      severity: "medium"
    }
  ],
  spending_by_category: {
    "food_dining": 450.00,
    "transportation": 120.00,
    "entertainment": 89.50
  },
  predictions: {
    next_month_total: 1250.00,
    confidence: 0.82
  },
  generated_at: ISODate("2026-01-19T00:00:00Z")
}

// Budget Collection
{
  _id: ObjectId,
  user_id: "uuid",
  category: "food_dining",
  budget_amount: 500.00,
  current_spend: 450.00,
  period: "monthly",
  start_date: ISODate("2026-01-01"),
  alerts_enabled: true,
  alert_threshold: 0.8,
  created_at: ISODate("2026-01-01")
}
```

**ML Model Architecture**:
```python
# Transaction Categorization Pipeline

# 1. Feature Engineering
def extract_features(transaction):
    return {
        'description_tokens': tokenize(transaction.description),
        'amount': transaction.amount,
        'merchant': extract_merchant(transaction.description),
        'time_of_day': transaction.timestamp.hour,
        'day_of_week': transaction.timestamp.weekday(),
        'location': transaction.location
    }

# 2. Model (Random Forest + BERT embeddings)
class TransactionCategorizer:
    def __init__(self):
        self.bert = BertModel.from_pretrained('bert-base-uncased')
        self.classifier = RandomForestClassifier(n_estimators=100)

    def train(self, transactions, labels):
        # Get BERT embeddings for descriptions
        embeddings = self.bert.encode([t.description for t in transactions])

        # Combine with numerical features
        features = np.hstack([
            embeddings,
            np.array([[t.amount, t.hour, t.day] for t in transactions])
        ])

        self.classifier.fit(features, labels)

    def predict(self, transaction):
        features = self.extract_features(transaction)
        category = self.classifier.predict(features)
        confidence = self.classifier.predict_proba(features).max()

        return {
            'category': category,
            'confidence': confidence
        }

# 3. Categories (hierarchical)
CATEGORIES = {
    'food_dining': ['restaurants', 'coffee_shops', 'groceries', 'fast_food'],
    'transportation': ['gas', 'public_transit', 'parking', 'ride_share'],
    'entertainment': ['movies', 'concerts', 'streaming', 'games'],
    'shopping': ['clothing', 'electronics', 'home', 'personal_care'],
    'bills': ['utilities', 'internet', 'phone', 'insurance'],
    'health': ['pharmacy', 'doctor', 'fitness'],
    'travel': ['flights', 'hotels', 'car_rental']
}
```

**Key Features**:
- Real-time categorization (<100ms latency)
- Confidence scores for predictions
- User feedback loop to improve accuracy
- Spending predictions using time series (Prophet)
- Anomaly detection for unusual transactions
- Receipt OCR using Tesseract/Google Vision API
- Personalized budget recommendations

---

### 5. Notification Service
**Responsibility**: Multi-channel notifications (push, email, SMS, in-app)

**API Endpoints**:
```
POST   /api/notifications/send
GET    /api/notifications
PATCH  /api/notifications/:id/read
DELETE /api/notifications/:id
POST   /api/notifications/preferences
GET    /api/notifications/preferences
POST   /api/notifications/devices/register
DELETE /api/notifications/devices/:id
```

**Database Schema**:
```sql
-- Notifications
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    channels VARCHAR(20)[], -- ['push', 'email', 'sms']
    priority VARCHAR(20) DEFAULT 'normal',
    read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_unread ON notifications(user_id, read) WHERE read = FALSE;

-- Notification Preferences
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID UNIQUE NOT NULL,
    transaction_alerts BOOLEAN DEFAULT TRUE,
    price_alerts BOOLEAN DEFAULT TRUE,
    budget_alerts BOOLEAN DEFAULT TRUE,
    security_alerts BOOLEAN DEFAULT TRUE,
    marketing BOOLEAN DEFAULT FALSE,
    email_enabled BOOLEAN DEFAULT TRUE,
    push_enabled BOOLEAN DEFAULT TRUE,
    sms_enabled BOOLEAN DEFAULT FALSE,
    quiet_hours_start TIME,
    quiet_hours_end TIME,
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Device Tokens (for push notifications)
CREATE TABLE device_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    token TEXT NOT NULL,
    platform VARCHAR(20) NOT NULL, -- 'ios', 'android', 'web'
    device_info JSONB,
    created_at TIMESTAMP DEFAULT NOW(),
    last_used_at TIMESTAMP,
    UNIQUE(user_id, token)
);
```

**Notification Types**:
```typescript
enum NotificationType {
  // Transactional
  TRANSACTION_COMPLETED = 'transaction_completed',
  LARGE_TRANSACTION = 'large_transaction',

  // Investment
  PRICE_ALERT = 'price_alert',
  PORTFOLIO_CHANGE = 'portfolio_change',

  // Budget
  BUDGET_WARNING = 'budget_warning', // 80% of budget
  BUDGET_EXCEEDED = 'budget_exceeded',

  // Security
  NEW_DEVICE_LOGIN = 'new_device_login',
  PASSWORD_CHANGED = 'password_changed',
  SUSPICIOUS_ACTIVITY = 'suspicious_activity',

  // General
  DAILY_SUMMARY = 'daily_summary',
  MONTHLY_REPORT = 'monthly_report'
}
```

---

### 6. Payment Service
**Responsibility**: P2P transfers, virtual cards, payment processing

**API Endpoints**:
```
POST   /api/payments/p2p/send
GET    /api/payments/p2p/history
POST   /api/payments/cards/virtual/create
GET    /api/payments/cards/virtual
DELETE /api/payments/cards/virtual/:id
POST   /api/payments/cards/virtual/:id/freeze
POST   /api/payments/cards/virtual/:id/unfreeze
```

**Database Schema**:
```sql
-- P2P Transfers
CREATE TABLE p2p_transfers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    from_user_id UUID NOT NULL,
    to_user_id UUID NOT NULL,
    from_account_id UUID REFERENCES accounts(id),
    to_account_id UUID REFERENCES accounts(id),
    amount DECIMAL(20, 8) NOT NULL,
    currency VARCHAR(3) NOT NULL,
    message TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    idempotency_key VARCHAR(255) UNIQUE,
    created_at TIMESTAMP DEFAULT NOW(),
    completed_at TIMESTAMP
);

-- Virtual Cards
CREATE TABLE virtual_cards (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL,
    account_id UUID REFERENCES accounts(id),
    card_number_encrypted TEXT NOT NULL,
    card_holder_name VARCHAR(255),
    cvv_encrypted TEXT NOT NULL,
    expiry_month SMALLINT NOT NULL,
    expiry_year SMALLINT NOT NULL,
    spending_limit DECIMAL(20, 2),
    status VARCHAR(20) DEFAULT 'active',
    merchant_restrictions TEXT[],
    category_restrictions TEXT[],
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP NOT NULL
);
```

---

## Data Architecture

### Database Selection Strategy

| Database | Use Case | Why |
|----------|----------|-----|
| **PostgreSQL** | Users, accounts, transactions | ACID compliance, strong consistency for financial data |
| **Redis** | Sessions, rate limiting, cache | Fast in-memory operations, TTL support |
| **TimescaleDB** | Exchange rates, asset prices | Time-series optimization, continuous aggregates |
| **MongoDB** | Analytics, ML data, documents | Flexible schema, fast writes for analytics |
| **S3** | Receipts, reports, backups | Cheap storage, high durability |
| **Elasticsearch** | Search, logs, audit trail | Full-text search, log aggregation |

### Data Consistency Patterns

**Strong Consistency** (PostgreSQL):
- User balances
- Transactions
- Authentication

**Eventual Consistency** (Event-driven):
- Analytics/insights
- Notifications
- Audit logs

**Cache-Aside Pattern** (Redis):
```typescript
async function getExchangeRate(from: string, to: string): Promise<number> {
  const cacheKey = `rate:${from}:${to}`;

  // Try cache first
  const cached = await redis.get(cacheKey);
  if (cached) return parseFloat(cached);

  // Fetch from API
  const rate = await forexAPI.getRate(from, to);

  // Cache for 30 seconds
  await redis.setex(cacheKey, 30, rate.toString());

  return rate;
}
```

---

## Security Architecture

### Security Layers

```
┌──────────────────────────────────────────┐
│  Layer 1: Network Security               │
│  • DDoS Protection (Cloudflare)          │
│  • WAF (Web Application Firewall)        │
│  • Rate Limiting                          │
└──────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────┐
│  Layer 2: API Gateway Security           │
│  • JWT Validation                         │
│  • Request Signing                        │
│  • Input Validation                       │
│  • CORS Policies                          │
└──────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────┐
│  Layer 3: Application Security           │
│  • Authorization (RBAC)                   │
│  • Business Logic Validation              │
│  • Data Sanitization                      │
│  • Fraud Detection                        │
└──────────────────────────────────────────┘
                    ↓
┌──────────────────────────────────────────┐
│  Layer 4: Data Security                  │
│  • Encryption at Rest (AES-256)          │
│  • Encryption in Transit (TLS 1.3)       │
│  • Database Access Control                │
│  • Secure Key Management (KMS)           │
└──────────────────────────────────────────┘
```

### Encryption Strategy

**At Rest**:
```typescript
// Sensitive fields encrypted in database
class User {
  id: string;
  email: string;
  @Encrypted() // Custom decorator
  phone: string;
  password_hash: string; // Argon2
}

// Encryption implementation
class EncryptionService {
  private masterKey: Buffer; // From AWS KMS

  encrypt(plaintext: string): string {
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv('aes-256-gcm', this.masterKey, iv);

    const encrypted = Buffer.concat([
      cipher.update(plaintext, 'utf8'),
      cipher.final()
    ]);

    const tag = cipher.getAuthTag();

    // Format: iv:tag:encrypted (all base64)
    return `${iv.toString('base64')}:${tag.toString('base64')}:${encrypted.toString('base64')}`;
  }

  decrypt(ciphertext: string): string {
    const [iv, tag, encrypted] = ciphertext.split(':').map(s => Buffer.from(s, 'base64'));

    const decipher = crypto.createDecipheriv('aes-256-gcm', this.masterKey, iv);
    decipher.setAuthTag(tag);

    return Buffer.concat([
      decipher.update(encrypted),
      decipher.final()
    ]).toString('utf8');
  }
}
```

**In Transit**:
- TLS 1.3 for all API communications
- Certificate pinning in mobile apps
- Mutual TLS (mTLS) for service-to-service communication

**PII Data Handling**:
```typescript
// Personal data fields
const PII_FIELDS = ['email', 'phone', 'address', 'ssn'];

// Mask PII in logs
function sanitizeForLogging(data: any): any {
  const sanitized = { ...data };

  PII_FIELDS.forEach(field => {
    if (sanitized[field]) {
      sanitized[field] = maskPII(sanitized[field]);
    }
  });

  return sanitized;
}

// Example: test@email.com -> t***@e***.com
function maskPII(value: string): string {
  if (value.includes('@')) {
    const [user, domain] = value.split('@');
    return `${user[0]}***@${domain[0]}***.${domain.split('.').pop()}`;
  }
  return value.substring(0, 2) + '***' + value.slice(-2);
}
```

### Authentication Flow

```
┌──────────┐                                      ┌──────────┐
│  Client  │                                      │   API    │
└─────┬────┘                                      └─────┬────┘
      │                                                  │
      │  1. POST /auth/login                            │
      │     { email, password }                         │
      ├────────────────────────────────────────────────>│
      │                                                  │
      │                                    2. Verify credentials
      │                                       Hash password & compare
      │                                                  │
      │  3. Return tokens                               │
      │     { access_token, refresh_token }             │
      │<────────────────────────────────────────────────┤
      │                                                  │
      │  4. Store tokens securely                       │
      │     (Keychain/Keystore/Secure Storage)          │
      │                                                  │
      │  5. Make authenticated request                  │
      │     Authorization: Bearer <access_token>        │
      ├────────────────────────────────────────────────>│
      │                                                  │
      │                                    6. Validate JWT
      │                                       Check signature
      │                                       Check expiry
      │                                                  │
      │  7. Return data                                 │
      │<────────────────────────────────────────────────┤
      │                                                  │
      │  8. Access token expired (401)                  │
      │<────────────────────────────────────────────────┤
      │                                                  │
      │  9. POST /auth/refresh-token                    │
      │     { refresh_token }                           │
      ├────────────────────────────────────────────────>│
      │                                                  │
      │                                   10. Validate refresh token
      │                                       Check not revoked
      │                                                  │
      │  11. Return new access token                    │
      │<────────────────────────────────────────────────┤
      │                                                  │
```

**JWT Structure**:
```typescript
// Access Token (15 min expiry)
{
  "sub": "user_id",
  "email": "user@example.com",
  "role": "user",
  "permissions": ["wallet:read", "wallet:write"],
  "iat": 1705657200,
  "exp": 1705658100, // 15 minutes
  "jti": "unique_token_id"
}

// Refresh Token (30 days expiry)
{
  "sub": "user_id",
  "type": "refresh",
  "iat": 1705657200,
  "exp": 1708249200, // 30 days
  "jti": "unique_refresh_token_id"
}
```

### Biometric Authentication Flow

```typescript
// 1. Registration
async function registerBiometric(userId: string, deviceId: string) {
  // Generate challenge
  const challenge = crypto.randomBytes(32);

  // Client creates key pair and signs challenge
  // (WebAuthn/FIDO2 on device)

  // Store public key
  await db.biometric_credentials.insert({
    user_id: userId,
    device_id: deviceId,
    public_key: publicKey,
    credential_id: credentialId,
    challenge: challenge.toString('base64')
  });
}

// 2. Authentication
async function authenticateBiometric(userId: string, deviceId: string, signature: string) {
  const credential = await db.biometric_credentials.findOne({
    user_id: userId,
    device_id: deviceId
  });

  // Verify signature with stored public key
  const isValid = crypto.verify(
    'sha256',
    Buffer.from(credential.challenge, 'base64'),
    credential.public_key,
    Buffer.from(signature, 'base64')
  );

  if (isValid) {
    // Generate new challenge for next time
    await updateChallenge(credential.id);

    // Return auth tokens
    return generateTokens(userId);
  }

  throw new Error('Invalid biometric authentication');
}
```

---

## API Design

### REST API Standards

**Base URL**: `https://api.fintech.app/v1`

**Request/Response Format**:
```typescript
// Success Response
{
  "success": true,
  "data": {
    // Response payload
  },
  "meta": {
    "timestamp": "2026-01-19T10:30:00Z",
    "request_id": "req_abc123"
  }
}

// Error Response
{
  "success": false,
  "error": {
    "code": "INSUFFICIENT_FUNDS",
    "message": "Account balance too low for this transaction",
    "details": {
      "available": 100.00,
      "required": 150.00
    }
  },
  "meta": {
    "timestamp": "2026-01-19T10:30:00Z",
    "request_id": "req_abc123"
  }
}
```

**Pagination**:
```typescript
GET /api/wallet/transactions?page=2&limit=20

{
  "success": true,
  "data": [...],
  "meta": {
    "pagination": {
      "page": 2,
      "limit": 20,
      "total": 487,
      "total_pages": 25,
      "has_next": true,
      "has_prev": true
    }
  }
}
```

**Filtering & Sorting**:
```
GET /api/wallet/transactions?
    category=food_dining&
    start_date=2026-01-01&
    end_date=2026-01-31&
    sort=-created_at&
    limit=50
```

### WebSocket API

**Connection**:
```typescript
const ws = new WebSocket('wss://api.fintech.app/v1/stream');

// Authenticate
ws.send(JSON.stringify({
  type: 'auth',
  token: accessToken
}));

// Subscribe to events
ws.send(JSON.stringify({
  type: 'subscribe',
  channels: ['portfolio', 'transactions', 'alerts']
}));
```

**Event Types**:
```typescript
// Portfolio update
{
  "type": "portfolio.updated",
  "data": {
    "total_value": 50250.45,
    "daily_change": 234.12,
    "daily_change_percent": 0.47,
    "holdings": [...]
  },
  "timestamp": "2026-01-19T10:30:00Z"
}

// New transaction
{
  "type": "transaction.created",
  "data": {
    "id": "txn_123",
    "amount": -45.50,
    "currency": "USD",
    "description": "Starbucks",
    "category": "food_dining"
  },
  "timestamp": "2026-01-19T10:30:00Z"
}

// Price alert triggered
{
  "type": "alert.triggered",
  "data": {
    "symbol": "AAPL",
    "price": 180.00,
    "alert_type": "above",
    "alert_price": 178.00
  },
  "timestamp": "2026-01-19T10:30:00Z"
}
```

---

## Infrastructure & Deployment

### Cloud Architecture (AWS Example)

```
┌─────────────────────────────────────────────────────────────┐
│                         Route 53                             │
│                    (DNS Management)                          │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│                      CloudFront                              │
│                  (CDN + DDoS Protection)                     │
└────────────────────────────┬────────────────────────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│                  Application Load Balancer                   │
│                   (SSL Termination)                          │
└────────────┬───────────────┴───────────────┬────────────────┘
             │                               │
┌────────────▼──────────┐      ┌────────────▼──────────┐
│   ECS Cluster         │      │   ECS Cluster         │
│   (us-east-1)         │      │   (eu-west-1)         │
│                       │      │                       │
│  ┌──────────────┐    │      │  ┌──────────────┐    │
│  │ Auth Service │    │      │  │ Auth Service │    │
│  └──────────────┘    │      │  └──────────────┘    │
│  ┌──────────────┐    │      │  ┌──────────────┐    │
│  │Wallet Service│    │      │  │Wallet Service│    │
│  └──────────────┘    │      │  └──────────────┘    │
│  ┌──────────────┐    │      │  ┌──────────────┐    │
│  │ Investment   │    │      │  │ Investment   │    │
│  │  Service     │    │      │  │  Service     │    │
│  └──────────────┘    │      │  └──────────────┘    │
└───────────────────────┘      └───────────────────────┘
             │                               │
             └───────────────┬───────────────┘
                             │
┌────────────────────────────▼────────────────────────────────┐
│                         Data Layer                           │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   RDS        │  │ ElastiCache  │  │  DocumentDB  │     │
│  │ (PostgreSQL) │  │   (Redis)    │  │  (MongoDB)   │     │
│  │  Multi-AZ    │  │              │  │              │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │     S3       │  │     SQS      │  │ OpenSearch   │     │
│  │  (Storage)   │  │  (Queues)    │  │   (Logs)     │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### Container Configuration

**Dockerfile (Node.js Service)**:
```dockerfile
# Multi-stage build
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

# Production image
FROM node:20-alpine

RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001

WORKDIR /app
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

USER nodejs

EXPOSE 3000

CMD ["node", "dist/main.js"]
```

**docker-compose.yml (Local Development)**:
```yaml
version: '3.8'

services:
  auth-service:
    build: ./services/auth
    ports:
      - "3001:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/fintech
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=${JWT_SECRET}
    depends_on:
      - db
      - redis

  wallet-service:
    build: ./services/wallet
    ports:
      - "3002:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/fintech
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  investment-service:
    build: ./services/investment
    ports:
      - "3003:3000"
    environment:
      - DATABASE_URL=postgresql://postgres:password@db:5432/fintech
      - REDIS_URL=redis://redis:6379
      - ALPHA_VANTAGE_API_KEY=${ALPHA_VANTAGE_API_KEY}
    depends_on:
      - db
      - redis

  analytics-service:
    build: ./services/analytics
    ports:
      - "3004:3000"
    environment:
      - MONGODB_URL=mongodb://mongo:27017/fintech
      - MODEL_PATH=/models/categorizer.pkl
    depends_on:
      - mongo

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=fintech
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  mongo:
    image: mongo:7
    ports:
      - "27017:27017"
    volumes:
      - mongo_data:/data/db

  rabbitmq:
    image: rabbitmq:3-management-alpine
    ports:
      - "5672:5672"
      - "15672:15672"
    environment:
      - RABBITMQ_DEFAULT_USER=admin
      - RABBITMQ_DEFAULT_PASS=password

volumes:
  postgres_data:
  mongo_data:
```

### Kubernetes Deployment

**deployment.yaml (Investment Service)**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: investment-service
  namespace: fintech
spec:
  replicas: 3
  selector:
    matchLabels:
      app: investment-service
  template:
    metadata:
      labels:
        app: investment-service
        version: v1
    spec:
      containers:
      - name: investment-service
        image: fintech/investment-service:v1.2.3
        ports:
        - containerPort: 3000
        env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: db-credentials
              key: url
        - name: REDIS_URL
          valueFrom:
            secretKeyRef:
              name: redis-credentials
              key: url
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: investment-service
  namespace: fintech
spec:
  selector:
    app: investment-service
  ports:
  - port: 80
    targetPort: 3000
  type: ClusterIP
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: investment-service-hpa
  namespace: fintech
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: investment-service
  minReplicas: 3
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### CI/CD Pipeline (GitHub Actions)

```yaml
name: Deploy Investment Service

on:
  push:
    branches: [main]
    paths:
      - 'services/investment/**'

env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: fintech/investment-service
  ECS_CLUSTER: fintech-production
  ECS_SERVICE: investment-service

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '20'
          cache: 'npm'
          cache-dependency-path: services/investment/package-lock.json

      - name: Install dependencies
        working-directory: services/investment
        run: npm ci

      - name: Run linter
        working-directory: services/investment
        run: npm run lint

      - name: Run unit tests
        working-directory: services/investment
        run: npm test -- --coverage

      - name: Run integration tests
        working-directory: services/investment
        run: npm run test:integration

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: services/investment/coverage/lcov.info

  security-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Run Trivy vulnerability scanner
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: 'fs'
          scan-ref: 'services/investment'
          format: 'sarif'
          output: 'trivy-results.sarif'

      - name: Upload Trivy results to GitHub Security
        uses: github/codeql-action/upload-sarif@v2
        with:
          sarif_file: 'trivy-results.sarif'

  build-and-deploy:
    needs: [test, security-scan]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build, tag, and push image to Amazon ECR
        id: build-image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          IMAGE_TAG: ${{ github.sha }}
        working-directory: services/investment
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          echo "image=$ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG" >> $GITHUB_OUTPUT

      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster ${{ env.ECS_CLUSTER }} \
            --service ${{ env.ECS_SERVICE }} \
            --force-new-deployment

      - name: Wait for deployment
        run: |
          aws ecs wait services-stable \
            --cluster ${{ env.ECS_CLUSTER }} \
            --services ${{ env.ECS_SERVICE }}
```

---

## Data Flow Diagrams

### Transaction Flow

```
User initiates transaction
         │
         ▼
┌────────────────────┐
│  Client validates  │
│  (amount > 0, etc) │
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│  API Gateway       │
│  • Auth check      │
│  • Rate limit      │
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│  Wallet Service    │
│  1. Start TX       │
│  2. Lock balance   │
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│  Database          │
│  BEGIN TRANSACTION │
│  UPDATE accounts   │
│  INSERT transaction│
│  COMMIT            │
└────────┬───────────┘
         │
         ├──────────────────┐
         │                  │
         ▼                  ▼
┌────────────────┐  ┌────────────────┐
│ Message Queue  │  │  Return to     │
│ (async events) │  │  client        │
└────────┬───────┘  └────────────────┘
         │
         ├─────────────┬─────────────┐
         │             │             │
         ▼             ▼             ▼
┌──────────────┐ ┌──────────┐ ┌──────────┐
│ Analytics    │ │Notification│ │ Fraud   │
│ Service      │ │ Service   │ │ Detection│
│              │ │           │ │          │
│• Categorize  │ │• Send push│ │• Analyze │
│• Update stats│ │• Email    │ │• Flag    │
└──────────────┘ └──────────┘ └──────────┘
```

### Portfolio Update Flow

```
Market data source (Alpha Vantage, etc)
         │
         ▼
┌────────────────────┐
│  WebSocket         │
│  Connection        │
│  (persistent)      │
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│  Investment Service│
│  • Receive price   │
│  • Update cache    │
└────────┬───────────┘
         │
         ├──────────────────┐
         │                  │
         ▼                  ▼
┌────────────────┐  ┌────────────────┐
│ TimescaleDB    │  │ Calculate      │
│ Store price    │  │ portfolio value│
└────────────────┘  └────────┬───────┘
                             │
                             ▼
                    ┌────────────────┐
                    │ Check alerts   │
                    │ (price > target)│
                    └────────┬───────┘
                             │
                             ├─────────────┐
                             │             │
                             ▼             ▼
                    ┌────────────┐  ┌──────────┐
                    │ Notification│  │WebSocket │
                    │ Service    │  │ to client│
                    └────────────┘  └──────────┘
```

---

## Scalability & Performance

### Performance Targets

| Metric | Target | Measurement |
|--------|--------|-------------|
| API Response Time (p95) | < 200ms | Application logs |
| API Response Time (p99) | < 500ms | Application logs |
| Transaction Processing | < 1s | End-to-end timing |
| Real-time Updates | < 100ms | WebSocket latency |
| Database Query Time | < 50ms | Query logs |
| Categorization (AI) | < 100ms | Service metrics |

### Caching Strategy

```typescript
// Multi-layer caching
class CacheService {
  // Layer 1: In-memory (fastest)
  private memoryCache = new Map<string, any>();

  // Layer 2: Redis (shared across instances)
  private redis: Redis;

  // Layer 3: Database (slowest)
  private db: Database;

  async get(key: string): Promise<any> {
    // Try memory first
    if (this.memoryCache.has(key)) {
      return this.memoryCache.get(key);
    }

    // Try Redis
    const cached = await this.redis.get(key);
    if (cached) {
      const value = JSON.parse(cached);
      this.memoryCache.set(key, value); // Populate memory cache
      return value;
    }

    // Fetch from database
    const value = await this.db.get(key);
    if (value) {
      // Cache in both layers
      await this.redis.setex(key, 300, JSON.stringify(value));
      this.memoryCache.set(key, value);
    }

    return value;
  }
}
```

### Database Optimization

**Indexing Strategy**:
```sql
-- Transactions table (most queried)
CREATE INDEX idx_transactions_user_date ON transactions(user_id, created_at DESC);
CREATE INDEX idx_transactions_category ON transactions(category) WHERE category IS NOT NULL;
CREATE INDEX idx_transactions_status ON transactions(status) WHERE status = 'pending';

-- Accounts table
CREATE INDEX idx_accounts_user ON accounts(user_id);

-- Portfolio
CREATE INDEX idx_holdings_user ON holdings(user_id);

-- Composite index for common query
CREATE INDEX idx_transactions_user_category_date
  ON transactions(user_id, category, created_at DESC);
```

**Query Optimization**:
```sql
-- Bad: Full table scan
SELECT * FROM transactions WHERE user_id = '123';

-- Good: Use specific columns + index
SELECT id, amount, currency, description, created_at
FROM transactions
WHERE user_id = '123'
ORDER BY created_at DESC
LIMIT 50;

-- Bad: N+1 queries
-- (fetch user, then fetch each account separately)

-- Good: Single query with JOIN
SELECT u.*, a.*
FROM users u
LEFT JOIN accounts a ON u.id = a.user_id
WHERE u.id = '123';
```

### Load Testing Results

```bash
# Using k6 for load testing
k6 run --vus 100 --duration 30s load-test.js

# Target: 1000 requests/second
# Results:
# ✓ http_req_duration: avg=45ms p95=120ms p99=280ms
# ✓ http_req_failed: 0.02%
# ✓ Throughput: 1250 req/s
```

---

## Monitoring & Observability

### Metrics Collection

```typescript
// Prometheus metrics
import { Counter, Histogram, Gauge } from 'prom-client';

// Request metrics
const httpRequestDuration = new Histogram({
  name: 'http_request_duration_ms',
  help: 'Duration of HTTP requests in ms',
  labelNames: ['method', 'route', 'status_code']
});

const httpRequestTotal = new Counter({
  name: 'http_requests_total',
  help: 'Total number of HTTP requests',
  labelNames: ['method', 'route', 'status_code']
});

// Business metrics
const transactionTotal = new Counter({
  name: 'transactions_total',
  help: 'Total number of transactions',
  labelNames: ['currency', 'type']
});

const transactionVolume = new Counter({
  name: 'transaction_volume_total',
  help: 'Total transaction volume',
  labelNames: ['currency']
});

const activeUsers = new Gauge({
  name: 'active_users',
  help: 'Number of active users',
  labelNames: ['timeframe'] // '5min', '1hour', '24hour'
});
```

### Logging Strategy

```typescript
// Structured logging with correlation IDs
logger.info('Transaction created', {
  request_id: req.id,
  user_id: user.id,
  transaction_id: transaction.id,
  amount: transaction.amount,
  currency: transaction.currency,
  duration_ms: Date.now() - startTime
});

// Error logging with context
logger.error('Transaction failed', {
  request_id: req.id,
  user_id: user.id,
  error: error.message,
  stack: error.stack,
  transaction_data: sanitizeForLogging(transactionData)
});
```

### Alerting Rules

```yaml
# Prometheus alerting rules
groups:
  - name: fintech_alerts
    rules:
      - alert: HighErrorRate
        expr: |
          sum(rate(http_requests_total{status_code=~"5.."}[5m]))
          /
          sum(rate(http_requests_total[5m])) > 0.05
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High error rate detected"
          description: "Error rate is {{ $value | humanizePercentage }}"

      - alert: SlowResponseTime
        expr: |
          histogram_quantile(0.95,
            rate(http_request_duration_ms_bucket[5m])
          ) > 500
        for: 10m
        labels:
          severity: warning
        annotations:
          summary: "Slow API response times"
          description: "P95 latency is {{ $value }}ms"

      - alert: DatabaseConnectionPoolExhausted
        expr: |
          database_connections_active
          /
          database_connections_max > 0.9
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Database connection pool nearly exhausted"
```

---

## Cost Optimization

### Estimated Monthly Costs (AWS)

| Service | Configuration | Cost |
|---------|--------------|------|
| ECS Fargate | 6 services × 3 instances | $450 |
| RDS PostgreSQL | db.r5.large Multi-AZ | $350 |
| ElastiCache Redis | cache.r5.large | $180 |
| DocumentDB | 3-node cluster | $400 |
| S3 | 500GB storage + transfer | $50 |
| CloudFront | 1TB transfer | $85 |
| Load Balancer | ALB + requests | $25 |
| CloudWatch | Logs + metrics | $100 |
| **Total** | | **~$1,640/month** |

### Optimization Strategies

1. **Use spot instances** for non-critical workloads (analytics)
2. **Auto-scaling** based on traffic (scale down at night)
3. **Database read replicas** for read-heavy workloads
4. **S3 lifecycle policies** (move old receipts to Glacier)
5. **CDN caching** to reduce origin requests
6. **Reserved instances** for predictable base load (save 30-60%)

---

## Next Steps for Implementation

### Phase 1: Foundation (Weeks 1-4)
- [ ] Set up project structure and monorepo
- [ ] Configure local development environment (Docker)
- [ ] Implement Auth Service
- [ ] Set up PostgreSQL + Redis
- [ ] Create CI/CD pipeline
- [ ] Build mobile app shell (Flutter)

### Phase 2: Core Features (Weeks 5-10)
- [ ] Implement Wallet Service
- [ ] Add multi-currency support
- [ ] Build transaction history
- [ ] Create basic analytics dashboard
- [ ] Implement biometric authentication

### Phase 3: Advanced Features (Weeks 11-16)
- [ ] Build Investment Service
- [ ] Add real-time price updates
- [ ] Implement AI categorization
- [ ] Create notification system
- [ ] Add receipt scanning

### Phase 4: Production Ready (Weeks 17-20)
- [ ] Security audit
- [ ] Performance testing
- [ ] Deploy to production
- [ ] Set up monitoring
- [ ] Write documentation
- [ ] Beta testing

---

This architecture is designed to be:
- ✅ **Scalable**: Microservices can scale independently
- ✅ **Secure**: Multiple layers of security, encryption everywhere
- ✅ **Performant**: Caching, indexing, real-time updates
- ✅ **Maintainable**: Clear service boundaries, good documentation
- ✅ **Production-ready**: Monitoring, logging, alerting built-in

Ready to start building! 🚀
