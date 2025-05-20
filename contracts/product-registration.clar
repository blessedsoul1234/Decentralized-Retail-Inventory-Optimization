;; Product Registration Contract
;; Records merchandise details and manages product catalog

(define-data-var admin principal tx-sender)

;; Product data structure
(define-map products
  { product-id: uint }
  {
    name: (string-utf8 100),
    category: (string-utf8 50),
    price: uint,
    sku: (string-utf8 50),
    active: bool
  }
)

;; Product inventory across stores
(define-map product-inventory
  { product-id: uint, store-id: uint }
  {
    quantity: uint,
    min-threshold: uint,
    max-capacity: uint
  }
)

;; Get admin
(define-read-only (get-admin)
  (var-get admin)
)

;; Change admin
(define-public (set-admin (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (ok (var-set admin new-admin))
  )
)

;; Register a new product
(define-public (register-product
  (product-id uint)
  (name (string-utf8 100))
  (category (string-utf8 50))
  (price uint)
  (sku (string-utf8 50))
)
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-none (map-get? products { product-id: product-id })) (err u100))
    (map-set products
      { product-id: product-id }
      {
        name: name,
        category: category,
        price: price,
        sku: sku,
        active: true
      }
    )
    (ok true)
  )
)

;; Update product details
(define-public (update-product
  (product-id uint)
  (name (string-utf8 100))
  (category (string-utf8 50))
  (price uint)
  (sku (string-utf8 50))
  (active bool)
)
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (map-get? products { product-id: product-id })) (err u404))
    (map-set products
      { product-id: product-id }
      {
        name: name,
        category: category,
        price: price,
        sku: sku,
        active: active
      }
    )
    (ok true)
  )
)

;; Get product details
(define-read-only (get-product (product-id uint))
  (map-get? products { product-id: product-id })
)

;; Set initial inventory for a product at a store
(define-public (set-product-inventory
  (product-id uint)
  (store-id uint)
  (quantity uint)
  (min-threshold uint)
  (max-capacity uint)
)
  (begin
    (asserts! (is-eq tx-sender (var-get admin)) (err u403))
    (asserts! (is-some (map-get? products { product-id: product-id })) (err u404))
    (map-set product-inventory
      { product-id: product-id, store-id: store-id }
      {
        quantity: quantity,
        min-threshold: min-threshold,
        max-capacity: max-capacity
      }
    )
    (ok true)
  )
)

;; Get product inventory at a store
(define-read-only (get-product-inventory (product-id uint) (store-id uint))
  (map-get? product-inventory { product-id: product-id, store-id: store-id })
)

;; Check if product is active
(define-read-only (is-product-active (product-id uint))
  (default-to false (get active (map-get? products { product-id: product-id })))
)
