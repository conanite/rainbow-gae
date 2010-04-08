(map require-lib
  '(lib/html
    lib/srv
    lib/app
    lib/lib/parser))

(def file-join parts
  (apply + parts))

(def qualified-path (path)
  ((java-new "java.io.File" path) 'getAbsolutePath))
