(java-imports com.google.appengine.api.datastore
  Query Query$FilterOperator FetchOptions FetchOptions$Builder
  DatastoreServiceFactory Entity)

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
    (each (k v) (pair props)
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



