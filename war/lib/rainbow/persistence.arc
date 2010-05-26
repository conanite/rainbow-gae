(java-imports com.google.appengine.api.datastore
  Query Query$SortDirection Query$FilterOperator
  FetchOptions FetchOptions$Builder
  DatastoreServiceFactory Entity)

(def datastore () DatastoreServiceFactory.getDatastoreService)

(def query-filter (operator)
  (fn (q fetch props) 
      (q 'add-filter car.props operator cadr.props)
      (build-query q fetch cddr.props)))

(assign query-builders (obj
  <    (query-filter Query$FilterOperator.LESS_THAN)
  <=   (query-filter Query$FilterOperator.LESS_THAN_OR_EQUAL)
  ==   (query-filter Query$FilterOperator.EQUAL)
  >    (query-filter Query$FilterOperator.GREATER_THAN_OR_EQUAL)
  >=   (query-filter Query$FilterOperator.GREATER_THAN)
  !=   (query-filter Query$FilterOperator.NOT_EQUAL)
  desc (fn (q fetch props)
           (q 'addSort car.props Query$SortDirection.DESCENDING)
           (build-query q fetch cdr.props))
  asc  (fn (q fetch props)
           (q 'addSort car.props)
           (build-query q fetch cdr.props))
  page (fn (q fetch props)
           (with (page car.props per-page cadr.props)
             (fetch 'offset (* (- page 1) per-page))
             (fetch 'limit per-page))
           (build-query q fetch cddr.props))
))

(def build-query (q fetch props)
  (if props
    ((query-builders car.props) q cdr.props)
    q))

(def prepare-query (kind props (o fetch nilfn))
  ((datastore) 'prepare (build-query (Query new kind) fetch props)))

(def find-entities (kind . properties)
  (let f (fetch-options)
    (map arcify 
         ((prepare-query kind properties f) 'asList f))))

(def find-entity (kind . properties)
  (arcify ((prepare-query kind properties) 'asSingleEntity)))

(def count-entities (kind . properties)
  ((prepare-query kind properties) 'countEntities))

(def debug-find (kind . properties)
  ((prepare-query kind properties) 'toString))

(def get-entity (kind id)
  (arcify ((datastore) 'get (KeyFactory 'createKey kind id))))

(def fetch-options args
  (let builder (FetchOptions$Builder 'withLimit 100)
    (each (method opt) (pair args)
      (= builder (builder method opt)))
    builder))

(def new-entity (kind . props)
  (let e (Entity new kind)
    (each (k v) (pair props)
      (e 'setProperty k v))
    (arcify e)))

(def arcify (entity)
  (if entity
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
                   (entity 'getProperty car.args))))))



