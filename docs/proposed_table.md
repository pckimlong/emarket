# E-Commerce Multi-Shop Database Specification

This database structure is designed to be **database-agnostic** (compatible with PostgreSQL, MySQL, SQLite, Serverpod, or NoSQL document stores).

---

## 1. Store & Tenant Domain (`features/shop`)

### `shops`
Represents individual merchant stores or tenant vendors.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Unique identifier for the shop |
| `name` | String / Text | Required, Unique | Name of the shop |
| `description` | String / Text | Nullable | Detailed shop description |
| `logo_path` | String / Text | Nullable | Storage URL or file path for the logo |
| `is_active` | Boolean | Required, Default: `true` | Whether the shop is open for business |
| `settings` | JSON / Map | Required, Default: `{}` | Operational rules (business hours, delivery range, taxes) |
| `created_at` | DateTime | Required, Default: Current time | Timestamp of creation |
| `updated_at` | DateTime | Required, Default: Current time | Timestamp of last update |

---

### `staff`
Stores user profiles for platform administrators and shop employees (linked to the auth identity provider).

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Unique internal staff record ID |
| `auth_user_id` | ID | Required, Unique | External Auth ID (e.g. Supabase Auth / Firebase / JWT subject) |
| `email` | String / Text | Required, Unique | Staff email address |
| `phone_number` | String / Text | Nullable | Contact phone number |
| `first_name` | String / Text | Required | First name |
| `last_name` | String / Text | Nullable | Last name |
| `is_admin` | Boolean | Required, Default: `false` | Global Platform Super Admin flag (controls entire system) |
| `is_active` | Boolean | Required, Default: `true` | Account active flag |
| `last_login` | DateTime | Nullable | Last login timestamp |
| `created_at` | DateTime | Required, Default: Current time | Timestamp of creation |
| `updated_at` | DateTime | Required, Default: Current time | Timestamp of last update |

---

### `shop_members`
Junction table managing multi-tenant staff membership and Role-Based Access Control (RBAC) per shop.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Membership record ID |
| `staff_id` | ID | Required, Foreign Key → `staff(id)` | Associated staff member |
| `shop_id` | ID | Required, Foreign Key → `shops(id)` | Associated shop |
| `role` | String / Text | Required | Role: `'owner'`, `'manager'`, `'staff'`, or `'cashier'` |
| `permissions` | Array of String | Required, Default: `[]` | Fine-grained capabilities (e.g., `['products.edit', 'orders.fulfill']`) |
| `is_active` | Boolean | Required, Default: `true` | Whether this shop access is active |
| `created_at` | DateTime | Required, Default: Current time | Timestamp of assignment |
| `updated_at` | DateTime | Required, Default: Current time | Timestamp of last update |
| **Constraint** | Unique (`staff_id`, `shop_id`) | Prevents duplicate assignments |

---

## 2. Catalog Domain (`features/catalog`)

### `categories`
Hierarchical product categories scoped per shop.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Category ID |
| `shop_id` | ID | Required, Foreign Key → `shops(id)` | Owning shop |
| `parent_id` | ID | Nullable, Foreign Key → `categories(id)` | Parent category for nested subcategories |
| `name` | String / Text | Required | Category title |
| `description` | String / Text | Nullable | Category description |
| `image_path` | String / Text | Nullable | Banner or icon image URL |
| `display_order`| Integer | Required, Default: `0` | Sort order for display |
| `is_active` | Boolean | Required, Default: `true` | Category visibility flag |
| `created_at` | DateTime | Required, Default: Current time | Timestamp of creation |
| `updated_at` | DateTime | Required, Default: Current time | Timestamp of last update |
| **Constraint** | Unique (`shop_id`, `parent_id`, `name`) | Prevents duplicate sibling category names |

---

### `brands`
Brands or manufacturers managed within a shop.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Brand ID |
| `shop_id` | ID | Required, Foreign Key → `shops(id)` | Owning shop |
| `name` | String / Text | Required | Brand name (e.g., Apple, Nike) |
| `logo_path` | String / Text | Nullable | Brand logo URL |
| `is_active` | Boolean | Required, Default: `true` | Visibility flag |
| `created_at` | DateTime | Required, Default: Current time | Timestamp of creation |
| `updated_at` | DateTime | Required, Default: Current time | Timestamp of last update |
| **Constraint** | Unique (`shop_id`, `name`) | Prevents duplicate brand names per shop |

---

### `products`
The base catalog items representing goods sold by a shop.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Product ID |
| `shop_id` | ID | Required, Foreign Key → `shops(id)` | Owning shop |
| `category_id` | ID | Nullable, Foreign Key → `categories(id)` | Category classification |
| `brand_id` | ID | Nullable, Foreign Key → `brands(id)` | Brand classification |
| `name` | String / Text | Required | Product name |
| `description` | String / Text | Nullable | Long-form product description |
| `base_price` | Decimal (10, 2)| Required, Must be > 0 | Default/fallback price |
| `cost_price` | Decimal (10, 2)| Nullable | Wholesale/cost price for profit analytics |
| `sku` | String / Text | Nullable | Global product SKU |
| `barcode` | String / Text | Nullable | EAN/UPC barcode string |
| `thumbnail_path` | String / Text | Nullable | Primary thumbnail URL |
| `image_paths` | Array of String | Required, Default: `[]` | Gallery photo URLs |
| `is_active` | Boolean | Required, Default: `true` | Whether visible to customers |
| `is_featured` | Boolean | Required, Default: `false` | Highlighted on store front |
| `track_inventory` | Boolean | Required, Default: `true` | Whether stock is enforced |
| `attributes` | JSON / Map | Required, Default: `{}` | Base product attributes specifications |
| `tags` | Array of String | Nullable | Search tags (e.g. `['summer', 'sale']`) |
| `created_at` | DateTime | Required, Default: Current time | Timestamp of creation |
| `updated_at` | DateTime | Required, Default: Current time | Timestamp of last update |
| **Constraint** | Unique (`shop_id`, `sku`) | Enforces unique SKU per shop |

---

### `product_variants`
Specific variations of a product (Size, Color, Material, etc.).

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Variant ID |
| `product_id` | ID | Required, Foreign Key → `products(id)` | Parent product |
| `name` | String / Text | Required | Variant display title (e.g. "Red / XL") |
| `sku` | String / Text | Nullable, Unique | Stock Keeping Unit specific to this variation |
| `price_adjustment`| Decimal (10, 2)| Required, Default: `0.00` | Price delta added to base price (+10 or -5) |
| `image_path` | String / Text | Nullable | Image specific to this variant color/option |
| `attributes` | JSON / Map | Required, Default: `{}` | Key-value options (e.g. `{"Color": "Red", "Size": "XL"}`) |
| `current_stock` | Integer | Required, Default: `0`, >= 0 | On-hand quantity |
| `low_stock_threshold`| Integer | Required, Default: `10` | Alert trigger for replenishment |
| `is_active` | Boolean | Required, Default: `true` | Visibility flag |
| `created_at` | DateTime | Required, Default: Current time | Timestamp of creation |
| `updated_at` | DateTime | Required, Default: Current time | Timestamp of last update |

---

## 3. Customer & Identity Domain (`features/customer`)

### `customers`
Buyer customer accounts linked to the auth system.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Customer ID |
| `auth_user_id` | ID | Required, Unique | External Auth ID |
| `phone_number` | String / Text | Nullable, Unique | Mobile contact |
| `email` | String / Text | Nullable, Unique | Customer email |
| `first_name` | String / Text | Nullable | First name |
| `last_name` | String / Text | Nullable | Last name |
| `profile_image_path`| String / Text| Nullable | Profile photo URL |
| `language` | String / Text | Required, Default: `'en'` | Preferred locale (`'en'`, `'km'`) |
| `status` | String / Text | Required, Default: `'active'` | Status: `'active'`, `'suspended'` |
| `notification_settings` | JSON / Map | Required | Push and email preferences |
| `created_at` | DateTime | Required, Default: Current time | Timestamp of creation |
| `updated_at` | DateTime | Required, Default: Current time | Timestamp of last update |

---

### `customer_addresses`
Saved shipping and delivery addresses for customers.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Address record ID |
| `customer_id` | ID | Required, Foreign Key → `customers(id)`| Owning customer |
| `label` | String / Text | Required | Label: `'home'`, `'work'`, `'other'` |
| `recipient_name`| String / Text | Nullable | Name of recipient |
| `phone_number` | String / Text | Required | Delivery contact number |
| `address_line` | String / Text | Required | Street, building, house number |
| `coordinates` | JSON / Map | Required | GPS location (e.g. `{"latitude": 11.55, "longitude": 104.92}`) |
| `delivery_notes`| String / Text | Nullable | Special delivery instructions |
| `is_default` | Boolean | Required, Default: `false` | Whether this is the default address |
| `created_at` | DateTime | Required, Default: Current time | Timestamp of creation |
| `updated_at` | DateTime | Required, Default: Current time | Timestamp of last update |

---

### `wishlist_items`
Saved/favorited products for future purchase.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Wishlist entry ID |
| `customer_id` | ID | Required, Foreign Key → `customers(id)`| Customer |
| `product_id` | ID | Required, Foreign Key → `products(id)` | Saved product |
| `created_at` | DateTime | Required, Default: Current time | Timestamp added |
| **Constraint** | Unique (`customer_id`, `product_id`) | Prevents duplicate bookmarks |

---

## 4. Shopping Cart Domain (`features/cart`)

### `carts`
Active shopping basket container for a customer session.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Cart ID |
| `customer_id` | ID | Required, Unique, Foreign Key → `customers(id)` | Owning customer |
| `shop_id` | ID | Nullable, Foreign Key → `shops(id)` | Current active shop context (null if empty) |
| `created_at` | DateTime | Required, Default: Current time | Timestamp of creation |
| `updated_at` | DateTime | Required, Default: Current time | Timestamp of last update |

---

### `cart_items`
Individual line items inside an active cart.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Cart item ID |
| `cart_id` | ID | Required, Foreign Key → `carts(id)` | Parent cart |
| `product_id` | ID | Required, Foreign Key → `products(id)` | Selected product |
| `variant_id` | ID | Nullable, Foreign Key → `product_variants(id)` | Selected variant (if product has options) |
| `quantity` | Integer | Required, Default: `1`, Must be > 0 | Selected quantity |
| `created_at` | DateTime | Required, Default: Current time | Timestamp added |
| **Constraint** | Unique (`cart_id`, `product_id`, `variant_id`) | Merges quantities instead of duplicate rows |

---

## 5. Orders & Checkout Domain (`features/order`)

### `orders`
Finalized customer orders placed with a shop.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Order internal ID |
| `shop_id` | ID | Required, Foreign Key → `shops(id)` | Fulfilling shop |
| `customer_id` | ID | Nullable, Foreign Key → `customers(id)`| Buyer (nullable so deleted user preserves sales report) |
| `order_number`| String / Text | Required, Unique | Human-readable code (e.g. `ORD-2026-8891`) |
| `status` | String / Text | Required, Default: `'pending'` | Lifecycle: `'pending'`, `'confirmed'`, `'preparing'`, `'out_for_delivery'`, `'delivered'`, `'cancelled'` |
| `payment_method`| String / Text | Required, Default: `'cod'` | Method: `'cod'`, `'qr_payment'`, `'card'` |
| `payment_status`| String / Text | Required, Default: `'pending'` | Status: `'pending'`, `'paid'`, `'failed'`, `'refunded'` |
| `subtotal` | Decimal (10, 2)| Required, Must be >= 0 | Items gross total |
| `discount_total`| Decimal (10, 2)| Required, Default: `0.00` | Applied voucher/discount total |
| `delivery_fee` | Decimal (10, 2)| Required, Default: `0.00` | Shipping/delivery fee |
| `tax_amount` | Decimal (10, 2)| Required, Default: `0.00` | Applicable tax |
| `total_amount` | Decimal (10, 2)| Required | Net total (`subtotal - discount + delivery + tax`) |
| `currency` | String / Text | Required, Default: `'USD'` | Transaction currency |
| `delivery_phone`| String / Text | Required | Recipient contact phone |
| `delivery_address`| JSON / Map | Required | **Frozen snapshot** of full delivery address at checkout |
| `customer_notes`| String / Text | Nullable | Special customer order notes |
| `created_at` | DateTime | Required, Default: Current time | Timestamp placed |
| `updated_at` | DateTime | Required, Default: Current time | Timestamp of status update |

---

### `order_items`
Frozen historical snapshot of items purchased at the moment of order creation.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Order item ID |
| `order_id` | ID | Required, Foreign Key → `orders(id)` | Parent order |
| `product_id` | ID | Nullable, Foreign Key → `products(id)` | Original product reference |
| `variant_id` | ID | Nullable, Foreign Key → `product_variants(id)` | Original variant reference |
| `product_name` | String / Text | Required | **Frozen product title** at time of purchase |
| `variant_name` | String / Text | Nullable | **Frozen variant name** (e.g. "Black / 256GB") |
| `variant_attributes`| JSON / Map | Nullable | **Frozen option map** (e.g. `{"Color": "Black"}`) |
| `sku` | String / Text | Nullable | Frozen SKU code |
| `quantity` | Integer | Required, Must be > 0 | Quantity purchased |
| `unit_price` | Decimal (10, 2)| Required, Must be >= 0 | Price per unit charged |
| `discount_amount`| Decimal (10, 2)| Required, Default: `0.00` | Discount deducted per unit |
| `total_price` | Decimal (10, 2)| Required, Must be >= 0 | Total price (`unit_price * quantity`) |
| `created_at` | DateTime | Required, Default: Current time | Timestamp of creation |

---

## 6. Marketing Domain (`features/marketing`)

### `promotions`
Marketing campaigns, vouchers, and discounts.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Promotion ID |
| `shop_id` | ID | Required, Foreign Key → `shops(id)` | Owning shop |
| `name` | String / Text | Required | Campaign name |
| `description` | String / Text | Nullable | Terms & details |
| `type` | String / Text | Required | Type: `'percentage'`, `'fixed_amount'`, `'buy_x_get_y'` |
| `value` | Decimal (10, 2)| Nullable | Discount value (e.g., `15.00` for 15% or $15) |
| `buy_quantity` | Integer | Nullable | For BOGO deals (X items) |
| `get_quantity` | Integer | Nullable | For BOGO deals (Y items free) |
| `conditions` | JSON / Map | Required, Default: `{}` | Min spend, maximum discount cap, usage restrictions |
| `usage_limit` | Integer | Nullable | Maximum times promo can be redeemed |
| `usage_count` | Integer | Required, Default: `0` | Times already redeemed |
| `starts_at` | DateTime | Required | Scheduled launch time |
| `ends_at` | DateTime | Nullable | Expiration timestamp |
| `is_active` | Boolean | Required, Default: `true` | Enabled flag |
| `created_at` | DateTime | Required, Default: Current time | Timestamp of creation |
| `updated_at` | DateTime | Required, Default: Current time | Timestamp of last update |

---

### `promotion_products`
Junction mapping which specific products are covered under a promotion.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `promotion_id` | ID | Required, Foreign Key → `promotions(id)` | Applicable promotion |
| `product_id` | ID | Required, Foreign Key → `products(id)` | Applicable product |
| `created_at` | DateTime | Required, Default: Current time | Timestamp linked |
| **Constraint** | Primary Key (`promotion_id`, `product_id`) | Composite primary key |

---

### `banners`
Hero carousels and promotional sliders for customer frontends.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `id` | ID | Primary Key, Auto-generated | Banner ID |
| `shop_id` | ID | Required, Foreign Key → `shops(id)` | Associated shop (or null for platform banner) |
| `title` | String / Text | Nullable | Headline text |
| `subtitle` | String / Text | Nullable | Sub-headline text |
| `image_path` | String / Text | Required | Banner graphic URL |
| `action_type` | String / Text | Required | Action: `'product'`, `'category'`, `'promotion'`, `'url'` |
| `action_payload`| JSON / Map | Required, Default: `{}` | Parameters (e.g. `{"product_id": "..."}`) |
| `display_order` | Integer | Required, Default: `0` | Sequence in the slider |
| `starts_at` | DateTime | Required | Start displaying |
| `ends_at` | DateTime | Nullable | Stop displaying |
| `is_active` | Boolean | Required, Default: `true` | Active status |
| `created_at` | DateTime | Required, Default: Current time | Timestamp of creation |
| `updated_at` | DateTime | Required, Default: Current time | Timestamp of last update |

---

## 7. Platform Administration (`features/system`)

### `system_settings`
Global platform-wide system configuration.

| Column | Data Type | Modifiers / Constraints | Description |
| :--- | :--- | :--- | :--- |
| `key` | String / Text | Primary Key | Setting name (e.g., `'maintenance_mode'`, `'min_app_version'`) |
| `value` | String / Text | Required | Value string or JSON string |
| `created_at` | DateTime | Required, Default: Current time | Timestamp created |
| `updated_at` | DateTime | Required, Default: Current time | Timestamp updated |