;;
;; mkjdo - make a JDO class from an entity file in SML format
;;
;; Usage: jarc mkjdo.arc somefile.sml package.name
;;
;; SML format example:
;; (Person
;;  id Long
;;  name String)

(= fileName (car *argv*))
(= packageName (cadr *argv*))
(= object (car:readfile (string fileName)))
(= className (car object))

(w/outfile out (string className ".java")
  (w/stdout out
    (pr "package " packageName ";\n")
    (pr "import com.google.appengine.api.datastore.Key;

import java.util.*;
import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.IdentityType;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

@PersistenceCapable(identityType = IdentityType.APPLICATION)
public class " className " {\n")

    (= fields (pair (cdr object)))
    (= id (car fields))
    (prn "    @PrimaryKey\n    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)")
    (prn "    private " (cadr id) " " (car id) ";\n")
    (each (name type) (cdr fields)
      (prn "    @Persistent")
      (prn "    private " type " " name ";"))

    (prn "\n    // constructors")
    (prn "    public " className "() {}")
;    (prn "    public " className "(Map map) { putAll(map); }")
    (pr "    public " className "(")
    (each (name type) (cdr fields)
      (if (no (is name (caar:cdr fields))) (pr ", "))
      (pr type " " name))
    (prn ") {")
    (each (name type) (cdr fields)
      (prn "        this." name " = " name ";"))
    (prn "    }")

    (prn "    public int hashCode() { return " (car id) " == null ? 0 : " (car id) ".hashCode(); }")

    (prn "\n    // jarc.AbstractTable overrides")
    (prn "    public Object get(String key) {")
    (each (name type) fields
      (prn "        if (key.equals(\"" name "\")) return " name ";")
    )
    (prn "        return null;")
    (prn "    }")

    (prn "    public Object put(String key, Object value) {")
    (each (name type) fields
      (prn "        if (key.equals(\"" name "\")) return " name " = (" type ")value;")
    )
    (prn "        return null;")
    (prn "    }")

    (prn "    public Set<Map.Entry<String, Object>> entrySet() {")
    (prn "        Set<Map.Entry<String, Object>> entries = new HashSet<Map.Entry<String, Object>>();")
    (each (name type) fields
      (prn "        entries.add((Map.Entry<String, Object>)new AbstractMap.SimpleEntry<String, Object>(\"" name "\", " name "));")
    )
    (prn "        return entries;")
    (prn "    }")
    (prn "}")
  )
)




