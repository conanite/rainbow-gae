(java-imports java.security MessageDigest)
(java-imports java.lang String)

(def sha1 (text)
  ((String new ((MessageDigest 'getInstance "SHA1") 'digest ((String new text) 'getBytes))) 'toString))




