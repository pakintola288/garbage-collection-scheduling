;; Waste Collection Scheduler Smart Contract
;; Manages garbage collection routes, recycling programs, and service announcements

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-already-exists (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-invalid-input (err u104))
(define-constant err-route-full (err u105))
(define-constant err-already-collected (err u106))

;; Collection status constants
(define-constant status-scheduled u1)
(define-constant status-in-progress u2)
(define-constant status-completed u3)
(define-constant status-missed u4)
(define-constant status-rescheduled u5)

;; Data Variables
(define-data-var next-route-id uint u1)
(define-data-var next-schedule-id uint u1)
(define-data-var next-address-id uint u1)
(define-data-var next-program-id uint u1)
(define-data-var next-announcement-id uint u1)
(define-data-var next-collection-id uint u1)

;; Data Maps

;; Collection routes
(define-map routes
  uint
  {
    route-name: (string-ascii 100),
    zone-id: uint,
    max-stops: uint,
    current-stops: uint,
    vehicle-assigned: (string-ascii 50),
    crew-assigned: (string-ascii 100),
    is-active: bool,
    created-at: uint,
    created-by: principal
  }
)

;; Collection schedules
(define-map schedules
  uint
  {
    route-id: uint,
    address-id: uint,
    scheduled-date: uint,
    collection-type: (string-ascii 50),
    status: uint,
    notes: (string-ascii 200),
    created-at: uint
  }
)

;; Service addresses
(define-map addresses
  uint
  {
    street-address: (string-ascii 200),
    zone-id: uint,
    route-id: uint,
    is-active: bool,
    service-type: (string-ascii 50),
    registered-at: uint
  }
)

;; Recycling programs
(define-map recycling-programs
  uint
  {
    program-name: (string-ascii 100),
    program-type: (string-ascii 50),
    description: (string-ascii 300),
    is-active: bool,
    enrollment-count: uint,
    created-at: uint
  }
)

;; Program enrollments
(define-map program-enrollments
  { address-id: uint, program-id: uint }
  {
    enrolled-at: uint,
    is-active: bool,
    collections-count: uint
  }
)

;; Collection records
(define-map collections
  uint
  {
    schedule-id: uint,
    route-id: uint,
    address-id: uint,
    collected-at: uint,
    collected-by: principal,
    weight-kg: uint,
    collection-type: (string-ascii 50),
    notes: (string-ascii 200)
  }
)

;; Service announcements
(define-map announcements
  uint
  {
    title: (string-ascii 100),
    message: (string-ascii 500),
    announcement-type: (string-ascii 50),
    zone-id: uint,
    effective-date: uint,
    expiry-date: uint,
    is-active: bool,
    posted-by: principal,
    posted-at: uint
  }
)

;; Administrators
(define-map administrators principal bool)

;; Initialize contract owner as administrator
(map-set administrators contract-owner true)

;; Private Functions

(define-private (is-administrator (user principal))
  (default-to false (map-get? administrators user))
)

(define-private (get-next-route-id)
  (let ((current-id (var-get next-route-id)))
    (var-set next-route-id (+ current-id u1))
    current-id
  )
)

(define-private (get-next-schedule-id)
  (let ((current-id (var-get next-schedule-id)))
    (var-set next-schedule-id (+ current-id u1))
    current-id
  )
)

(define-private (get-next-address-id)
  (let ((current-id (var-get next-address-id)))
    (var-set next-address-id (+ current-id u1))
    current-id
  )
)

(define-private (get-next-program-id)
  (let ((current-id (var-get next-program-id)))
    (var-set next-program-id (+ current-id u1))
    current-id
  )
)

(define-private (get-next-announcement-id)
  (let ((current-id (var-get next-announcement-id)))
    (var-set next-announcement-id (+ current-id u1))
    current-id
  )
)

(define-private (get-next-collection-id)
  (let ((current-id (var-get next-collection-id)))
    (var-set next-collection-id (+ current-id u1))
    current-id
  )
)

;; Public Functions

;; Administrative Functions

(define-public (add-administrator (new-admin principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (ok (map-set administrators new-admin true))
  )
)

(define-public (remove-administrator (admin principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (asserts! (not (is-eq admin contract-owner)) err-unauthorized)
    (ok (map-delete administrators admin))
  )
)

;; Route Management Functions

(define-public (create-route (route-name (string-ascii 100)) (zone-id uint) (max-stops uint))
  (let
    (
      (route-id (get-next-route-id))
    )
    (asserts! (is-administrator tx-sender) err-unauthorized)
    (asserts! (> (len route-name) u0) err-invalid-input)
    (asserts! (> max-stops u0) err-invalid-input)
    (ok (map-set routes route-id {
      route-name: route-name,
      zone-id: zone-id,
      max-stops: max-stops,
      current-stops: u0,
      vehicle-assigned: "",
      crew-assigned: "",
      is-active: true,
      created-at: block-height,
      created-by: tx-sender
    }))
  )
)

(define-public (assign-vehicle-to-route (route-id uint) (vehicle (string-ascii 50)) (crew (string-ascii 100)))
  (let
    (
      (route-data (unwrap! (map-get? routes route-id) err-not-found))
    )
    (asserts! (is-administrator tx-sender) err-unauthorized)
    (ok (map-set routes route-id
      (merge route-data {
        vehicle-assigned: vehicle,
        crew-assigned: crew
      })
    ))
  )
)

(define-public (update-route-status (route-id uint) (is-active bool))
  (let
    (
      (route-data (unwrap! (map-get? routes route-id) err-not-found))
    )
    (asserts! (is-administrator tx-sender) err-unauthorized)
    (ok (map-set routes route-id
      (merge route-data { is-active: is-active })
    ))
  )
)

;; Address Management Functions

(define-public (register-service-address (street-address (string-ascii 200)) (zone-id uint) (route-id uint) (service-type (string-ascii 50)))
  (let
    (
      (address-id (get-next-address-id))
      (route-data (unwrap! (map-get? routes route-id) err-not-found))
    )
    (asserts! (is-administrator tx-sender) err-unauthorized)
    (asserts! (> (len street-address) u0) err-invalid-input)
    (asserts! (< (get current-stops route-data) (get max-stops route-data)) err-route-full)
    
    (map-set addresses address-id {
      street-address: street-address,
      zone-id: zone-id,
      route-id: route-id,
      is-active: true,
      service-type: service-type,
      registered-at: block-height
    })
    
    ;; Update route stop count
    (map-set routes route-id
      (merge route-data {
        current-stops: (+ (get current-stops route-data) u1)
      })
    )
    
    (ok address-id)
  )
)

(define-public (update-address-status (address-id uint) (is-active bool))
  (let
    (
      (address-data (unwrap! (map-get? addresses address-id) err-not-found))
    )
    (asserts! (is-administrator tx-sender) err-unauthorized)
    (ok (map-set addresses address-id
      (merge address-data { is-active: is-active })
    ))
  )
)

;; Schedule Management Functions

(define-public (schedule-collection (route-id uint) (address-id uint) (scheduled-date uint) (collection-type (string-ascii 50)) (notes (string-ascii 200)))
  (let
    (
      (schedule-id (get-next-schedule-id))
    )
    (asserts! (is-administrator tx-sender) err-unauthorized)
    (asserts! (is-some (map-get? routes route-id)) err-not-found)
    (asserts! (is-some (map-get? addresses address-id)) err-not-found)
    (ok (map-set schedules schedule-id {
      route-id: route-id,
      address-id: address-id,
      scheduled-date: scheduled-date,
      collection-type: collection-type,
      status: status-scheduled,
      notes: notes,
      created-at: block-height
    }))
  )
)

(define-public (update-schedule-status (schedule-id uint) (new-status uint))
  (let
    (
      (schedule-data (unwrap! (map-get? schedules schedule-id) err-not-found))
    )
    (asserts! (is-administrator tx-sender) err-unauthorized)
    (ok (map-set schedules schedule-id
      (merge schedule-data { status: new-status })
    ))
  )
)

(define-public (record-collection (schedule-id uint) (weight-kg uint) (notes (string-ascii 200)))
  (let
    (
      (schedule-data (unwrap! (map-get? schedules schedule-id) err-not-found))
      (collection-id (get-next-collection-id))
    )
    (asserts! (is-administrator tx-sender) err-unauthorized)
    (asserts! (not (is-eq (get status schedule-data) status-completed)) err-already-collected)
    
    ;; Record the collection
    (map-set collections collection-id {
      schedule-id: schedule-id,
      route-id: (get route-id schedule-data),
      address-id: (get address-id schedule-data),
      collected-at: block-height,
      collected-by: tx-sender,
      weight-kg: weight-kg,
      collection-type: (get collection-type schedule-data),
      notes: notes
    })
    
    ;; Update schedule status
    (map-set schedules schedule-id
      (merge schedule-data { status: status-completed })
    )
    
    (ok collection-id)
  )
)

;; Recycling Program Functions

(define-public (create-recycling-program (program-name (string-ascii 100)) (program-type (string-ascii 50)) (description (string-ascii 300)))
  (let
    (
      (program-id (get-next-program-id))
    )
    (asserts! (is-administrator tx-sender) err-unauthorized)
    (asserts! (> (len program-name) u0) err-invalid-input)
    (ok (map-set recycling-programs program-id {
      program-name: program-name,
      program-type: program-type,
      description: description,
      is-active: true,
      enrollment-count: u0,
      created-at: block-height
    }))
  )
)

(define-public (enroll-address-in-program (address-id uint) (program-id uint))
  (let
    (
      (program-data (unwrap! (map-get? recycling-programs program-id) err-not-found))
    )
    (asserts! (is-administrator tx-sender) err-unauthorized)
    (asserts! (is-some (map-get? addresses address-id)) err-not-found)
    (asserts! (is-none (map-get? program-enrollments { address-id: address-id, program-id: program-id })) err-already-exists)
    
    (map-set program-enrollments { address-id: address-id, program-id: program-id } {
      enrolled-at: block-height,
      is-active: true,
      collections-count: u0
    })
    
    (map-set recycling-programs program-id
      (merge program-data {
        enrollment-count: (+ (get enrollment-count program-data) u1)
      })
    )
    
    (ok true)
  )
)

(define-public (record-recycling-collection (address-id uint) (program-id uint) (weight-kg uint))
  (let
    (
      (enrollment-data (unwrap! (map-get? program-enrollments { address-id: address-id, program-id: program-id }) err-not-found))
      (collection-id (get-next-collection-id))
    )
    (asserts! (is-administrator tx-sender) err-unauthorized)
    (asserts! (get is-active enrollment-data) err-unauthorized)
    
    (map-set collections collection-id {
      schedule-id: u0,
      route-id: u0,
      address-id: address-id,
      collected-at: block-height,
      collected-by: tx-sender,
      weight-kg: weight-kg,
      collection-type: "recycling",
      notes: ""
    })
    
    (map-set program-enrollments { address-id: address-id, program-id: program-id }
      (merge enrollment-data {
        collections-count: (+ (get collections-count enrollment-data) u1)
      })
    )
    
    (ok collection-id)
  )
)

;; Announcement Functions

(define-public (post-service-announcement (title (string-ascii 100)) (message (string-ascii 500)) (announcement-type (string-ascii 50)) (zone-id uint) (effective-date uint) (expiry-date uint))
  (let
    (
      (announcement-id (get-next-announcement-id))
    )
    (asserts! (is-administrator tx-sender) err-unauthorized)
    (asserts! (> (len title) u0) err-invalid-input)
    (asserts! (> (len message) u0) err-invalid-input)
    (ok (map-set announcements announcement-id {
      title: title,
      message: message,
      announcement-type: announcement-type,
      zone-id: zone-id,
      effective-date: effective-date,
      expiry-date: expiry-date,
      is-active: true,
      posted-by: tx-sender,
      posted-at: block-height
    }))
  )
)

(define-public (deactivate-announcement (announcement-id uint))
  (let
    (
      (announcement-data (unwrap! (map-get? announcements announcement-id) err-not-found))
    )
    (asserts! (is-administrator tx-sender) err-unauthorized)
    (ok (map-set announcements announcement-id
      (merge announcement-data { is-active: false })
    ))
  )
)

;; Read-only Functions

(define-read-only (get-route-info (route-id uint))
  (ok (map-get? routes route-id))
)

(define-read-only (get-address-info (address-id uint))
  (ok (map-get? addresses address-id))
)

(define-read-only (get-schedule-info (schedule-id uint))
  (ok (map-get? schedules schedule-id))
)

(define-read-only (get-collection-info (collection-id uint))
  (ok (map-get? collections collection-id))
)

(define-read-only (get-program-info (program-id uint))
  (ok (map-get? recycling-programs program-id))
)

(define-read-only (get-enrollment-info (address-id uint) (program-id uint))
  (ok (map-get? program-enrollments { address-id: address-id, program-id: program-id }))
)

(define-read-only (get-announcement (announcement-id uint))
  (ok (map-get? announcements announcement-id))
)

(define-read-only (is-admin (user principal))
  (ok (is-administrator user))
)

(define-read-only (get-contract-owner)
  (ok contract-owner)
)


;; title: waste-collection-scheduler
;; version:
;; summary:
;; description:

;; traits
;;

;; token definitions
;;

;; constants
;;

;; data vars
;;

;; data maps
;;

;; public functions
;;

;; read only functions
;;

;; private functions
;;

