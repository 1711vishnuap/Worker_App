-- =========================================================
-- SERVICE MARKETPLACE MVP - DATABASE SCHEMA
-- MySQL 8+
-- =========================================================
-- Run this whole file to create the database, all tables,
-- indexes, foreign keys, and seed the categories table.
-- =========================================================

CREATE DATABASE IF NOT EXISTS service_marketplace
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE service_marketplace;

-- Safer FK creation order (drop in reverse-dependency order if re-running)
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS work_status_history;
DROP TABLE IF EXISTS work_assignments;
DROP TABLE IF EXISTS works;
DROP TABLE IF EXISTS worker_categories;
DROP TABLE IF EXISTS workers;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- =========================================================
-- 1. USERS
-- Base identity table for BOTH customers and workers.
-- No passwords are stored anywhere — login is via Firebase
-- mobile OTP. firebase_uid is the only "credential" we keep,
-- and it is just an identifier, not a secret.
-- =========================================================
CREATE TABLE users (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    mobile_number   VARCHAR(15)     NOT NULL,
    name            VARCHAR(100)    NULL,
    user_type       ENUM('customer', 'worker') NOT NULL,
    firebase_uid    VARCHAR(128)    NOT NULL,
    fcm_token       VARCHAR(255)    NULL,
    is_active       TINYINT(1)      NOT NULL DEFAULT 1,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_users_mobile_number (mobile_number),
    UNIQUE KEY uq_users_firebase_uid (firebase_uid),
    INDEX idx_users_created_at (created_at)
) ENGINE=InnoDB;


-- =========================================================
-- 2. CATEGORIES
-- List of service types (Electrician, Plumber, etc.)
-- =========================================================
CREATE TABLE categories (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100)    NOT NULL,
    icon            VARCHAR(255)    NULL,
    is_active       TINYINT(1)      NOT NULL DEFAULT 1,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_categories_name (name)
) ENGINE=InnoDB;


-- =========================================================
-- 3. WORKERS
-- Extra profile info for users where user_type = 'worker'.
-- One-to-one extension of the users table.
-- =========================================================
CREATE TABLE workers (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED    NOT NULL,
    is_available    TINYINT(1)      NOT NULL DEFAULT 1,
    current_lat     DECIMAL(10,7)   NULL,
    current_lng     DECIMAL(10,7)   NULL,
    rating          DECIMAL(3,2)    NOT NULL DEFAULT 0.00,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_workers_user_id (user_id),
    INDEX idx_workers_is_available (is_available),
    INDEX idx_workers_lat_lng (current_lat, current_lng),

    CONSTRAINT fk_workers_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;


-- =========================================================
-- 4. WORKER_CATEGORIES
-- Many-to-many: a worker can offer many categories,
-- a category can have many workers.
-- =========================================================
CREATE TABLE worker_categories (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    worker_id       INT UNSIGNED    NOT NULL,
    category_id     INT UNSIGNED    NOT NULL,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_worker_category (worker_id, category_id),
    INDEX idx_worker_categories_category_id (category_id),

    CONSTRAINT fk_wc_worker
        FOREIGN KEY (worker_id) REFERENCES workers(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_wc_category
        FOREIGN KEY (category_id) REFERENCES categories(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;


-- =========================================================
-- 5. WORKS
-- The core "job" entity created by a customer.
-- OTP is stored as a short-lived code + expiry, not a secret
-- that needs hashing (it's a hand-to-worker verification code,
-- not an authentication credential).
-- =========================================================
CREATE TABLE works (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    customer_id         INT UNSIGNED    NOT NULL,
    category_id         INT UNSIGNED    NOT NULL,
    accepted_worker_id  INT UNSIGNED    NULL,

    title               VARCHAR(150)    NOT NULL,
    description         TEXT            NULL,
    photo_url           VARCHAR(255)    NULL,

    customer_lat        DECIMAL(10,7)   NOT NULL,
    customer_lng        DECIMAL(10,7)   NOT NULL,

    status              ENUM(
                            'POSTED',
                            'NOTIFIED',
                            'ACCEPTED',
                            'WORKER_ON_THE_WAY',
                            'ARRIVED',
                            'STARTED',
                            'COMPLETED',
                            'CANCELLED'
                         ) NOT NULL DEFAULT 'POSTED',

    otp_code            VARCHAR(6)      NULL,
    otp_generated_at    TIMESTAMP       NULL,
    otp_expires_at      TIMESTAMP       NULL,
    otp_verified_at     TIMESTAMP       NULL,

    created_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                         ON UPDATE CURRENT_TIMESTAMP,

    INDEX idx_works_status (status),
    INDEX idx_works_category_id (category_id),
    INDEX idx_works_customer_id (customer_id),
    INDEX idx_works_accepted_worker_id (accepted_worker_id),
    INDEX idx_works_lat_lng (customer_lat, customer_lng),
    INDEX idx_works_created_at (created_at),
    INDEX idx_works_status_category (status, category_id),

    CONSTRAINT fk_works_customer
        FOREIGN KEY (customer_id) REFERENCES users(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_works_category
        FOREIGN KEY (category_id) REFERENCES categories(id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_works_accepted_worker
        FOREIGN KEY (accepted_worker_id) REFERENCES workers(id)
        ON DELETE SET NULL
) ENGINE=InnoDB;


-- =========================================================
-- 6. WORK_ASSIGNMENTS
-- Tracks which workers a given work was offered/notified to.
-- Used to implement "nearest worker first" and to stop
-- showing the work to others once someone accepts.
-- =========================================================
CREATE TABLE work_assignments (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    work_id         INT UNSIGNED    NOT NULL,
    worker_id       INT UNSIGNED    NOT NULL,
    distance_km     DECIMAL(6,2)    NULL,

    status          ENUM(
                        'NOTIFIED',
                        'ACCEPTED',
                        'REJECTED',
                        'EXPIRED'
                     ) NOT NULL DEFAULT 'NOTIFIED',

    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP
                                     ON UPDATE CURRENT_TIMESTAMP,

    UNIQUE KEY uq_work_worker (work_id, worker_id),
    INDEX idx_work_assignments_work_status (work_id, status),
    INDEX idx_work_assignments_worker_id (worker_id),

    CONSTRAINT fk_wa_work
        FOREIGN KEY (work_id) REFERENCES works(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_wa_worker
        FOREIGN KEY (worker_id) REFERENCES workers(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;


-- =========================================================
-- 7. WORK_STATUS_HISTORY
-- Append-only timeline of status changes for a work.
-- Powers the customer's "Work Tracking" screen.
-- =========================================================
CREATE TABLE work_status_history (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    work_id         INT UNSIGNED    NOT NULL,
    status          ENUM(
                        'POSTED',
                        'NOTIFIED',
                        'ACCEPTED',
                        'WORKER_ON_THE_WAY',
                        'ARRIVED',
                        'STARTED',
                        'COMPLETED',
                        'CANCELLED'
                     ) NOT NULL,
    changed_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_wsh_work_id (work_id),
    INDEX idx_wsh_changed_at (changed_at),

    CONSTRAINT fk_wsh_work
        FOREIGN KEY (work_id) REFERENCES works(id)
        ON DELETE CASCADE
) ENGINE=InnoDB;


-- =========================================================
-- 8. NOTIFICATIONS
-- In-app notification log (mirrors what's pushed via FCM).
-- =========================================================
CREATE TABLE notifications (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED    NOT NULL,
    work_id         INT UNSIGNED    NULL,
    title           VARCHAR(150)    NOT NULL,
    body            TEXT            NULL,
    is_read         TINYINT(1)      NOT NULL DEFAULT 0,
    created_at      TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    INDEX idx_notifications_user_id (user_id),
    INDEX idx_notifications_created_at (created_at),

    CONSTRAINT fk_notifications_user
        FOREIGN KEY (user_id) REFERENCES users(id)
        ON DELETE CASCADE,
    CONSTRAINT fk_notifications_work
        FOREIGN KEY (work_id) REFERENCES works(id)
        ON DELETE SET NULL
) ENGINE=InnoDB;


-- =========================================================
-- SEED DATA: 5 sample categories
-- =========================================================
INSERT INTO categories (name, icon) VALUES
    ('Electrician', 'electrician.png'),
    ('Plumber',     'plumber.png'),
    ('Carpenter',   'carpenter.png'),
    ('Cleaning',    'cleaning.png'),
    ('AC Repair',   'ac_repair.png');

-- =========================================================
-- DONE
-- =========================================================
