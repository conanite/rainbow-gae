package wine;
import com.google.appengine.api.datastore.Key;

import java.util.*;
import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.IdentityType;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

@PersistenceCapable(identityType = IdentityType.APPLICATION)
public class Wine {
    @PrimaryKey
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
    private Long id;

    @Persistent
    private String description;
    @Persistent
    private String rating;
    @Persistent
    private Date created;

    // constructors
    public Wine() {}
    public Wine(String description, String rating, Date created) {
        this.description = description;
        this.rating = rating;
        this.created = created;
    }
    public int hashCode() { return id == null ? 0 : id.hashCode(); }

    // jarc.AbstractTable overrides
    public Object get(String key) {
        if (key.equals("id")) return id;
        if (key.equals("description")) return description;
        if (key.equals("rating")) return rating;
        if (key.equals("created")) return created;
        return null;
    }
    public Object put(String key, Object value) {
        if (key.equals("id")) return id = (Long)value;
        if (key.equals("description")) return description = (String)value;
        if (key.equals("rating")) return rating = (String)value;
        if (key.equals("created")) return created = (Date)value;
        return null;
    }
    public Set<Map.Entry<String, Object>> entrySet() {
        Set<Map.Entry<String, Object>> entries = new HashSet<Map.Entry<String, Object>>();
        entries.add((Map.Entry<String, Object>)new AbstractMap.SimpleEntry<String, Object>("id", id));
        entries.add((Map.Entry<String, Object>)new AbstractMap.SimpleEntry<String, Object>("description", description));
        entries.add((Map.Entry<String, Object>)new AbstractMap.SimpleEntry<String, Object>("rating", rating));
        entries.add((Map.Entry<String, Object>)new AbstractMap.SimpleEntry<String, Object>("created", created));
        return entries;
    }
}
