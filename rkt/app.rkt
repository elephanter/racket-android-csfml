#lang racket/base
(printf "Starting")
(require racket/list)
(require r-cade)
(printf "After requiring rcade")

(define (game-loop)
  (for ([i (range 16)])
    (color i)
    (draw 0 i '(#xff))))

(printf "Before game loop")
(run game-loop 8 16)

