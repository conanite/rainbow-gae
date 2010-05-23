
(def extract-arg-names (args)
  (flat:afnwith (args args o? nil)
    (if args
        (if atom.args
            args
            (let arg car.args
              (if atom.arg
                  (if (or no.o? (isnt arg 'o))
                      (cons arg (self cdr.args nil))
                      cadr.args)
                  (cons (self car.args t)
                        (self cdr.args nil))))))))

(unless (bound 'unsafe-def)
  (assign unsafe-def def)
  (mac def (name args . body)
    `(unsafe-def ,name ,args
       (on-err (fn (ex) (err:string "error in "
                                    ',name 
                                    (tostring:pr:list ,@(extract-arg-names args)) 
                                    "\n"
                                    (details ex)))
               (fn ()   ,@body)))))

;; security.arc
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

;; persistence.arc
(java-imports com.google.appengine.api.datastore
  Query Query$FilterOperator FetchOptions FetchOptions$Builder)

(def datastore () DatastoreServiceFactory.getDatastoreService)

(withs (operators (obj <  Query$FilterOperator.LESS_THAN
                       <= Query$FilterOperator.LESS_THAN_OR_EQUAL
                       =  Query$FilterOperator.EQUAL
                       >  Query$FilterOperator.GREATER_THAN_OR_EQUAL
                       >= Query$FilterOperator.GREATER_THAN
                       != Query$FilterOperator.NOT_EQUAL)
        prepare-query (fn (kind properties)
          (with (q (Query new kind)
                 pp (tuples properties 3))
            (each (k op v) pp
              (q 'addFilter k operators.op v))
            ((datastore) 'prepare q))))

  (def find-entities (kind . properties)
    (map arcify ((prepare-query kind properties) 'asList (fetch-options))))

  (def find-entity (kind . properties)
    (arcify ((prepare-query kind properties) 'asSingleEntity)))

  (def count-entities (kind . properties)
    ((prepare-query kind properties) 'countEntities))
)

(def get-entity (kind id)
  (arcify ((datastore) 'get (KeyFactory 'createKey kind id))))

(def fetch-options args
  (let builder (FetchOptions$Builder 'withLimit 100)
    (each (method opt) (pair args)
      (= builder (builder method opt)))
    builder))

(def new-entity (kind . props)
  (let e (Entity new kind)
    (each (k v) hsh
      (e 'setProperty k v))
    (arcify e)))

(def arcify (entity)
  (afn args
    (case car.args
      save     ((datastore) 'put entity)
      id       (entity!getKey 'getId)
      kind     (entity!getKey 'getKind)
      is-new   (is (self 'id) nil)
      delete   (unless (self 'is-new)
                 ((datastore) 'delete (list entity!getKey)))
               (aif cadr.args
                 (entity 'setProperty car.args cadr.args)
                 (entity 'getProperty car.args)))))

;;blog.arc

(java-imports java.util Date)

(def java-now () Date.new)

(def credentials-form (action return-to)
  (tag (form action action method "post")
    (tag (input type "hidden" name "return-to" value return-to))
    (tag p (pr "login:") 
           (tag (input name "login")))
    (tag p (pr "password:") 
           (tag (input type "password" name "password")))
    (tag p (tag (input type 'submit)))))

(def signup-form (return-to)
  (credentials-form "/new-user" return-to))

(def login-form (return-to)
  (credentials-form "/authenticate" return-to))

(def authenticate (req)
  (aif (find-entity "user" 'login    '= (arg req "login")
                           'password '= (sha1:arg req "password"))
    (with (token (rand-string 20))
      ((new-entity 'token 'cookie token 'user (it 'login)) 'save)
      (prcookie token)))
  (or (arg req "return-to")
      "/archive"))

(def authenticated-welcome-message (user)
  (nbsp)
  (tag b (pr "Hi, " (user "login")))
  (nbsp)
  (link "logout"))

(def welcome-message (user)
  (if user
    (authenticated-welcome-message user)
    (do
      (nbsp)
      (link "login")
      (nbsp)
      (link "signup" ))))

(def active-user (req)
  (aif (find-entity "token" 'cookie '= (alref req!cooks "user"))
    (find-entity "user" 'login '= (it 'user))))

(mac blogpage (user . body)
  `(whitepage
     (center
       (widtable 600
         (tag b (link "My Blog" "archive"))
         (welcome-message user)
         (br 3)
         ,@body
         (br 3)
         (w/bars (link "archive?reload=true")
                 (link "new post" "newpost")
                 (link "users")
                 (link "sessions"))))))

(mac blogop (name req user . body)
  `(defop ,name ,req
     (let ,user (active-user ,req)
       ,@body)))

(mac blogopr (name req user . body)
  `(defopr ,name ,req
     (let ,user (active-user ,req)
       (if ,user (do ,@body) "/not-authorised"))))

(blogop not-authorised req user
  (tag p "Not authorised. Try logging in or " 
         (tag (a href "/signup") "signing up")))

(blogop login req user
  (blogpage user (login-form "/archive")))

(blogop signup req user
  (blogpage user (signup-form "/archive")))

(defopr authenticate req (authenticate req))

(defopr logout req
  (prcookie "")
  "/archive")

(defopr new-user req
  (let user (obj login    (arg req "login")
                 password (sha1:arg req "password"))
    (persist (hash-to-entity user 'user))
    (authenticate req)))

(blogop newpost req user
  (blogpage user
    (if user
      (tag (form action "/create")
        (tag p (pr "title:") 
               (tag (input name "title")))
        (tag p (pr "content:")
               (tag (textarea name "content" rows 20 cols 80)))
        (tag p (pr "tags:")
               (tag (input name "tags")))
        (tag p (tag (input type 'submit))))
      (signup-form "/newpost"))))

(blogopr create req user
  ((new-entity 'article
    'created-at (java-now)
    'title      (arg req "title")
    'author     (user "login")
    'content    (arg req "content")
    'tags       (arg req "tags"))
    'save)
  "/archive")

(def show-article (article)
  (tag h3 
    (link (article 'title) "/article?id=#((article 'id))"))
  (tag small 
    (pr (article 'created-at))
    (aif (article 'author)
      (pr " by " it)))
  (tag p (pr-escaped (article 'content)))
  (tag p (link "delete" "/delete-article?id=#((article 'id))")))

(blogop article req user
  (blogpage user
    (let art (get-entity 'article (int:arg req "id"))
      (show-article art))))

(blogop archive req user
  (blogpage user
    (tag ul
      (each entity (find-entities 'article)
        (tag li (show-article entity))))))

(blogop users req user
  (blogpage user
    (tag ul
      (each entity (find-entities 'user)
        (tag li (pr (entity 'login)))))))

(blogop sessions req user
  (blogpage user
    (tag ul
      (each entity (find-entities 'token)
        (tag li 
          (pr (entity 'cookie))
          (nbsp)
          (pr (entity 'user)))))))

(blogopr delete-article req user
  ((get-entity 'article (int:arg req "id")) 'delete)
  "/archive")
