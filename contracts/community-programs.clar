;; Community Programs Contract
;; Manages reading programs and community literature initiatives

;; Constants
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-PROGRAM-NOT-FOUND (err u501))
(define-constant ERR-ALREADY-ENROLLED (err u502))
(define-constant ERR-NOT-ENROLLED (err u503))
(define-constant ERR-INVALID-INPUT (err u504))
(define-constant ERR-PROGRAM-ENDED (err u505))

;; Data Variables
(define-data-var next-program-id uint u1)
(define-data-var next-achievement-id uint u1)

;; Data Maps
(define-map programs
  { program-id: uint }
  {
    organizer-store: uint,
    title: (string-ascii 200),
    description: (string-ascii 1000),
    program-type: (string-ascii 50),
    start-date: uint,
    end-date: uint,
    max-participants: uint,
    current-participants: uint,
    reading-goal: uint,
    reward-points: uint,
    status: (string-ascii 20),
    created-at: uint
  }
)

(define-map program-enrollments
  { program-id: uint, participant: principal }
  {
    enrolled-at: uint,
    books-read: uint,
    points-earned: uint,
    last-activity: uint,
    completion-status: (string-ascii 20)
  }
)

(define-map reading-logs
  { program-id: uint, participant: principal, book-title: (string-ascii 200) }
  {
    author: (string-ascii 100),
    pages: uint,
    rating: uint,
    review: (string-ascii 500),
    completed-at: uint
  }
)

(define-map achievements
  { achievement-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 200),
    requirement-type: (string-ascii 50),
    requirement-value: uint,
    points-reward: uint,
    badge-icon: (string-ascii 100)
  }
)

(define-map participant-achievements
  { participant: principal, achievement-id: uint }
  {
    earned-at: uint,
    program-id: uint
  }
)

;; Public Functions

;; Create a new community program
(define-public (create-program (organizer-store uint)
                              (title (string-ascii 200))
                              (description (string-ascii 1000))
                              (program-type (string-ascii 50))
                              (start-date uint)
                              (end-date uint)
                              (max-participants uint)
                              (reading-goal uint)
                              (reward-points uint))
  (let ((program-id (var-get next-program-id)))
    (asserts! (> (len title) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)
    (asserts! (> end-date start-date) ERR-INVALID-INPUT)
    (asserts! (> max-participants u0) ERR-INVALID-INPUT)
    (asserts! (> reading-goal u0) ERR-INVALID-INPUT)

    (map-set programs
      { program-id: program-id }
      {
        organizer-store: organizer-store,
        title: title,
        description: description,
        program-type: program-type,
        start-date: start-date,
        end-date: end-date,
        max-participants: max-participants,
        current-participants: u0,
        reading-goal: reading-goal,
        reward-points: reward-points,
        status: "active",
        created-at: block-height
      }
    )

    (var-set next-program-id (+ program-id u1))
    (ok program-id)
  )
)

;; Enroll in a program
(define-public (enroll-in-program (program-id uint))
  (let ((program (unwrap! (map-get? programs { program-id: program-id }) ERR-PROGRAM-NOT-FOUND)))
    (asserts! (is-eq (get status program) "active") ERR-INVALID-INPUT)
    (asserts! (< (get current-participants program) (get max-participants program)) ERR-INVALID-INPUT)
    (asserts! (is-none (map-get? program-enrollments { program-id: program-id, participant: tx-sender })) ERR-ALREADY-ENROLLED)
    (asserts! (> (get end-date program) block-height) ERR-PROGRAM-ENDED)

    (map-set program-enrollments
      { program-id: program-id, participant: tx-sender }
      {
        enrolled-at: block-height,
        books-read: u0,
        points-earned: u0,
        last-activity: block-height,
        completion-status: "active"
      }
    )

    (map-set programs
      { program-id: program-id }
      (merge program { current-participants: (+ (get current-participants program) u1) })
    )

    (ok true)
  )
)

;; Log a completed book
(define-public (log-book (program-id uint)
                        (book-title (string-ascii 200))
                        (author (string-ascii 100))
                        (pages uint)
                        (rating uint)
                        (review (string-ascii 500)))
  (let ((enrollment (unwrap! (map-get? program-enrollments { program-id: program-id, participant: tx-sender }) ERR-NOT-ENROLLED)))
    (asserts! (> (len book-title) u0) ERR-INVALID-INPUT)
    (asserts! (> (len author) u0) ERR-INVALID-INPUT)
    (asserts! (> pages u0) ERR-INVALID-INPUT)
    (asserts! (<= rating u5) ERR-INVALID-INPUT)

    (map-set reading-logs
      { program-id: program-id, participant: tx-sender, book-title: book-title }
      {
        author: author,
        pages: pages,
        rating: rating,
        review: review,
        completed-at: block-height
      }
    )

    (map-set program-enrollments
      { program-id: program-id, participant: tx-sender }
      (merge enrollment {
        books-read: (+ (get books-read enrollment) u1),
        points-earned: (+ (get points-earned enrollment) u10),
        last-activity: block-height
      })
    )

    (ok true)
  )
)

;; Create an achievement
(define-public (create-achievement (title (string-ascii 100))
                                  (description (string-ascii 200))
                                  (requirement-type (string-ascii 50))
                                  (requirement-value uint)
                                  (points-reward uint)
                                  (badge-icon (string-ascii 100)))
  (let ((achievement-id (var-get next-achievement-id)))
    (asserts! (> (len title) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)
    (asserts! (> requirement-value u0) ERR-INVALID-INPUT)

    (map-set achievements
      { achievement-id: achievement-id }
      {
        title: title,
        description: description,
        requirement-type: requirement-type,
        requirement-value: requirement-value,
        points-reward: points-reward,
        badge-icon: badge-icon
      }
    )

    (var-set next-achievement-id (+ achievement-id u1))
    (ok achievement-id)
  )
)

;; Award achievement to participant
(define-public (award-achievement (participant principal) (achievement-id uint) (program-id uint))
  (begin
    (asserts! (is-some (map-get? achievements { achievement-id: achievement-id })) ERR-INVALID-INPUT)
    (asserts! (is-some (map-get? program-enrollments { program-id: program-id, participant: participant })) ERR-NOT-ENROLLED)

    (map-set participant-achievements
      { participant: participant, achievement-id: achievement-id }
      {
        earned-at: block-height,
        program-id: program-id
      }
    )
    (ok true)
  )
)

;; Read-only Functions

;; Get program details
(define-read-only (get-program (program-id uint))
  (map-get? programs { program-id: program-id })
)

;; Get enrollment details
(define-read-only (get-enrollment (program-id uint) (participant principal))
  (map-get? program-enrollments { program-id: program-id, participant: participant })
)

;; Get reading log entry
(define-read-only (get-reading-log (program-id uint) (participant principal) (book-title (string-ascii 200)))
  (map-get? reading-logs { program-id: program-id, participant: participant, book-title: book-title })
)

;; Get achievement details
(define-read-only (get-achievement (achievement-id uint))
  (map-get? achievements { achievement-id: achievement-id })
)

;; Check if participant has achievement
(define-read-only (has-achievement (participant principal) (achievement-id uint))
  (is-some (map-get? participant-achievements { participant: participant, achievement-id: achievement-id }))
)

;; Get total programs
(define-read-only (get-total-programs)
  (- (var-get next-program-id) u1)
)
