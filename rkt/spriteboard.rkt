#lang racket/base
(require racket/flonum
         racket/fixnum
         racket/match
         racket/math
         racket/contract/base
         racket/list
         mode-lambda
         (only-in mode-lambda/backend/lib
                  compute-nice-scale)
         lux)

(define (flsqr x)
  (fl* x x))
(define (fldist x1 x2 y1 y2)
  (flsqrt
   (fl+ (flsqr (fl- x1 x2))
        (flsqr (fl- y1 y2)))))

;; XXX this should not be mutable
(struct clickable (m-spr click! drag-drop! [alive? #:mutable]))
(define (click-click! o)
  ((clickable-click! o)))

(struct draggable ([x #:mutable] [y #:mutable] f-spr
                   drag-start! drag-stop!
                   drag-drop-v drag-drop!
                   alive?))
(define (drag-update-pos! m x y)
  (set-draggable-x! m x)
  (set-draggable-y! m y))
(define (drag-start! m)
  ((draggable-drag-start! m)))
(define (drag-stop! m)
  ((draggable-drag-stop! m)))
(define (drag-value m)
  ((draggable-drag-drop-v m)))

;; This is a type of sprite that is neither draggable nor clickable.
;; However, it is "dropable", in the sense that you can drop another
;; sprite onto it
(struct droppable (m-spr drag-drop! alive?))

;; backgroundable is just a static, "background" sprite with no
;; behavior, except that it can be deleted by setting alive? to #f
(struct backgroundable (m-spr alive?))

(define (object-drop! o v)
  (match o
    [(? clickable?)
     ((clickable-drag-drop! o) v)]
    [(? draggable?)
     ((draggable-drag-drop! o) v)]
    [(? droppable?)
     ((droppable-drag-drop! o) v)]))

(define (force-meta-spr m)
  (define v
    (if (procedure? m)
      (m)
      m))
  (define r
    (if (meta-sprite? v)
      (meta-sprite-sd v)
      v))
  (when (meta-sprite? v)
    (hash-set! c->ms r v))
  r)

(define (object-spr dragged? o)
  (match o
    [(? clickable?)
     (force-meta-spr (clickable-m-spr o))]
    [(? draggable?)
     (force-meta-spr
      ((draggable-f-spr o)
       dragged?
       (draggable-x o)
       (draggable-y o)))]
    [(? droppable?)
     (force-meta-spr (droppable-m-spr o))]
    [(? backgroundable?)
     (force-meta-spr (backgroundable-m-spr o))]))

(define (object-alive? o)
  (match o
    [(? clickable?)
     ((clickable-alive? o))]
    [(? draggable?)
     ((draggable-alive? o))]
    [(? droppable?) #t]
    [(? backgroundable?)
     ((backgroundable-alive? o))]))

(struct spriteboard (ignoring? orient metatree meta->tree) #:mutable)
(define (make-the-spriteboard)
  (spriteboard #f 'landscape null (make-hasheq)))

(define (spriteboard-ignore! sb i)
  (set-spriteboard-ignoring?! sb i))

(define (spriteboard-tree dragged-m sb)
  (match-define (spriteboard _ ot mt m->t) sb)
  (hash-clear! m->t)
  (for/list ([m (in-list mt)])
    (define t (object-spr (eq? dragged-m m) m))
    (hash-set! m->t m t)
    t))
(define (spriteboard-gc! sb)
  (match-define (spriteboard _ ot mt m->t) sb)
  (set-spriteboard-metatree!
   sb
   (for/fold ([mt null])
             ([m (in-list mt)])
     (if (object-alive? m)
       (cons m mt)
       mt))))

(define (spriteboard-clear! sb)
  (match-define (spriteboard _ ot mt m->t) sb)
  (spriteboard-orient! sb 'landscape)
  (hash-clear! m->t)
  (set-spriteboard-metatree! sb '()))

(define (spriteboard-add! sb o)
  (set-spriteboard-metatree!
   sb (cons o (spriteboard-metatree sb)))
  (spriteboard-gc! sb))

(define (spriteboard-clickable!
         sb
         #:sprite m-spr
         #:click! [click! void]
         #:drag-drop! [drag-drop! void]
         #:alive? [alive? (λ () #t)])
  (spriteboard-add!
   sb
   (clickable m-spr click! drag-drop! alive?)))

(define (spriteboard-draggable!
         sb
         #:init-x init-x
         #:init-y init-y
         #:sprite f-spr
         #:drag-start! [drag-start! void]
         #:drag-stop! [drag-stop! void]
         #:drag-drop-v [drag-drop-v void]
         #:drag-drop! [drag-drop! void]
         #:alive? [alive? (λ () #t)])
  (spriteboard-add!
   sb
   (draggable init-x init-y f-spr
              drag-start! drag-stop!
              drag-drop-v drag-drop!
              alive?)))

(define (spriteboard-droppable!
         sb
         #:sprite m-spr
         #:drag-drop! [drag-drop! void]
         #:alive? [alive? (λ () #t)])
  (spriteboard-add!
   sb
   (droppable m-spr drag-drop! alive?)))

(define (spriteboard-backgroundable!
         sb
         #:sprite m-spr
         #:alive? [alive? (λ () #t)])
  (spriteboard-add!
   sb
   (backgroundable m-spr alive?)))

(define c->ms (make-weak-hasheq))
(define (sprite-layer t)
  (match t
    [(cons a d)
     (max (sprite-layer a)
          (sprite-layer d))]
    [(? sprite-data?)
     (sprite-data-layer t)]
    [#f
     0]))

(define (sprite-data-bb csd t)
  (define t-idx (sprite-data-spr t))

  (define tcx (sprite-data-dx t))
  (define sw (fx->fl (sprite-width csd t-idx)))
  (define tw (fl* (sprite-data-mx t) sw))
  (define thw (fl/ tw 2.0))
  (define x-min (fl- tcx thw))
  (define x-max (fl+ tcx thw))

  (define tcy (sprite-data-dy t))
  (define sh (fx->fl (sprite-height csd t-idx)))
  (define th (fl* (sprite-data-my t) sh))
  (define thh (fl/ th 2.0))
  (define y-min (fl- tcy thh))
  (define y-max (fl+ tcy thh))

  (values x-min x-max y-min y-max))

(define (sprite-inside? csd t x y)
  (define-values
    (x-min x-max y-min y-max)
    (match t
      [(? pair?)
       (define ms (hash-ref c->ms t #f))
       (apply values
              (if ms (meta-sprite-dims ms)
                  (list 0.0 0.0 0.0 0.0)))]
      [(? sprite-data?)
       (sprite-data-bb csd t)]))

  (and (fl<= x-min x)
       (fl<= x x-max)
       (fl<= y-min y)
       (fl<= y y-max)))

(define (argmax* f l)
  (and (pair? l)
       (argmax f l)))

(define (make-spriteboard W H csd render initialize!)
  (define the-sb (make-the-spriteboard))
  (define (find-object not-o x y)
    (define m->t (spriteboard-meta->tree the-sb))
    (define cs
      (for/fold ([c empty])
                ([m (in-list (spriteboard-metatree the-sb))]
                 #:unless (eq? m not-o))
        (define t (hash-ref m->t m #f))
        (if (and t
                 (or (clickable? m) (draggable? m))
                 (sprite-inside? csd t x y))
          (cons (cons t m) c)
          c)))
    (cdr
     (or (argmax* (λ (t*m)
                    (sprite-layer (car t*m)))
                  cs)
         (cons #f #f))))

  (define drag-state #f)
  (define (drag-adjust-pos init-x drag-x x)
    (+ init-x (- x drag-x)))
  (define (drag-state-update-draggable! x y)
    (match-define (vector dragged-m init-x init-y drag-x drag-y) drag-state)

    (define nx (drag-adjust-pos init-x drag-x x))
    (define ny (drag-adjust-pos init-y drag-y y))

    (drag-update-pos! dragged-m nx ny)
    dragged-m)

  (struct app ()
    #:methods gen:word
    [(define (word-fps w) 30.0)
     (define (word-label w ft)
       (lux-standard-label "Spriteboard" ft))

     (define layer-cx (fx->fl (/ W 2)))
     (define layer-cy (fx->fl (/ H 2)))
     (define portrait-theta (fl/ pi 2.0))
     (define (word-output w)
       (define std-layer
         (layer layer-cx layer-cy
                #:theta
                (match (spriteboard-orient the-sb)
                  ['landscape 0.0]
                  ['portrait portrait-theta])))
       (define layer-c
         (make-vector 4 std-layer))
       (render layer-c '()
               (spriteboard-tree
                (and drag-state (vector-ref drag-state 0))
                the-sb)))

     (define scale 1.0)
     (define inset-left 0.0)
     (define inset-bot 0.0)
     (define (scale-click e)
       (match e
         [(vector 'resize _ _)
          e]
         [(vector label x y)
          (vector label
                  (fl/ (fl- x inset-left) scale)
                  (fl/ (fl- y inset-bot) scale))]))

     (define (maybe-rotate e)
       (match (spriteboard-orient the-sb)
         ['landscape
          e]
         ['portrait
          (match e
            [(vector 'resize _ _)
             e]
            [(vector label ox oy)
             ;; Translate to origin
             (define x (fl- ox layer-cx))
             (define y (fl- oy layer-cy))
             ;; Rotate back to landscape
             (define c (flcos (fl* -1.0 portrait-theta)))
             (define s (flsin (fl* -1.0 portrait-theta)))
             (define rx (fl- (fl* x c) (fl* y s)))
             (define ry (fl+ (fl* x s) (fl* y c)))
             ;; Translate back to center
             (define nx (fl+ rx layer-cx))
             (define ny (fl+ ry layer-cy))
             (vector label nx ny)])]))
     (define (word-event w e)
       (unless (spriteboard-ignoring? the-sb)
         (match (maybe-rotate (scale-click e))
           [(vector 'resize w h)
            (define act-W w)
            (define act-H h)
            (define sim-W W)
            (define sim-H H)
            (set! scale (compute-nice-scale 1.0 act-W sim-W act-H sim-H))
            (set! inset-left (fl/ (fl- (fx->fl act-W) (fl* scale (fx->fl sim-W))) 2.0))
            (set! inset-bot (fl/ (fl- (fx->fl act-H) (fl* scale (fx->fl sim-H))) 2.0))]
           [(vector 'down x y)
            (define target-m (find-object #f x y))
            (when target-m
              (cond
                [(clickable? target-m)
                 (click-click! target-m)]
                [(draggable? target-m)
                 (set! drag-state
                       (vector target-m
                               (draggable-x target-m) (draggable-y target-m)
                               x y))
                 (drag-state-update-draggable! x y)
                 (drag-start! target-m)]))]
           [(vector 'drag x y)
            (when drag-state
              (drag-state-update-draggable! x y))]
           [(vector 'up x y)
            (when drag-state
              (define dragged-m
                (drag-state-update-draggable! x y))
              (define target-m
                (find-object dragged-m
                             (draggable-x dragged-m)
                             (draggable-y dragged-m)))
              (when target-m
                (object-drop! target-m (drag-value dragged-m)))
              (drag-stop! dragged-m)
              (set! drag-state #f))])
         (spriteboard-gc! the-sb))
       w)
     (define (word-tick w)
       (collect-garbage 'incremental)
       w)])
  (initialize! the-sb)
  (app))

(struct meta-sprite (dims sd))

(define meta-sprite-data/c
  (or/c sprite-data?
        meta-sprite?
        (-> (or/c sprite-data? meta-sprite?))))

(define (meta-sprite* csd ov)
  (let loop ([x-min +inf.0]
             [x-max -inf.0]
             [y-min +inf.0]
             [y-max -inf.0]
             [v ov])
    (cond
      [(or (null? v) (not v))
       (meta-sprite (list x-min x-max y-min y-max) ov)]
      [else
       (define-values (tx-min tx-max ty-min ty-max) (sprite-data-bb csd (car v)))
       (loop (min x-min tx-min)
             (max x-max tx-max)
             (min y-min ty-min)
             (max y-max ty-max)
             (cdr v))])))

(define orientation/c
  (one-of/c 'portrait 'landscape))
(define (spriteboard-orient! sb n)
  (eprintf "sb orient is now ~v\n" n)
  (set-spriteboard-orient! sb n))

(define-syntax-rule (with-spriteboard-ignore sb . body)
  (let ([sb-i sb])
    (dynamic-wind
      (λ () (spriteboard-ignore! sb #t))
      (λ () . body)
      (λ () (spriteboard-ignore! sb #f)))))

(provide
 with-spriteboard-ignore
 (contract-out
  [meta-sprite?
   (-> any/c
       boolean?)]
  [meta-sprite
   (-> (list/c flonum? flonum? flonum? flonum?)
       any/c
       meta-sprite?)]
  [meta-sprite*
   (-> compiled-sprite-db? any/c
       meta-sprite?)]
  [spriteboard-ignore!
   (-> spriteboard? boolean?
       void?)]
  [spriteboard-clear!
   (-> spriteboard?
       void?)]
  [spriteboard-clickable!
   (->* (spriteboard?
         #:sprite meta-sprite-data/c)
        (#:click! (-> void?)
         #:drag-drop! (-> any/c void?)
         #:alive? (-> boolean?))
        void?)]
  [spriteboard-draggable!
   (->* (spriteboard?
         #:init-x flonum?
         #:init-y flonum?
         #:sprite (-> boolean? flonum? flonum? meta-sprite-data/c))
        (#:drag-start! (-> void?)
         #:drag-stop! (-> void?)
         #:drag-drop-v (-> any/c)
         #:drag-drop! (-> any/c void?)
         #:alive? (-> boolean?))
        void?)]
  [spriteboard-droppable!
   (->* (spriteboard?
         #:sprite meta-sprite-data/c)
        (#:drag-drop! (-> any/c void?)
         #:alive? (-> boolean?))
        void?)]
  [spriteboard-backgroundable!
   (->* (spriteboard?
         #:sprite meta-sprite-data/c)
        (#:alive? (-> boolean?))
        void?)]
  [orientation/c contract?]
  [spriteboard-orient
   (-> spriteboard?
       orientation/c)]
  [spriteboard-orient!
   (-> spriteboard?
       orientation/c
       void?)]
  [make-spriteboard
   (-> real? real? compiled-sprite-db? procedure? (-> spriteboard? void?)
       any/c)]))
