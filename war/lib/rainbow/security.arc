(java-imports java.security MessageDigest)
(java-imports java.lang String)

(let c "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
  (def rand-string (n)
    (with (nc 62 s (newstring n) i 0)
      (while (< i n)
        (= (s i) (c (rand nc)))
        (++ i))
      s)))

(def sha1 (text)
  (with (txt      ((String new text) 'getBytes)
         digester (MessageDigest 'getInstance "SHA1"))
    ((String new (digester 'digest txt)) 'toString)))
