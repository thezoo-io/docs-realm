.. code-block:: java

   import org.bson.types.ObjectId;

   import io.realm.DynamicRealmObject;
   import io.realm.RealmObject;
   import io.realm.annotations.PrimaryKey;

   public class Potato extends RealmObject {
       @PrimaryKey
       private ObjectId _id;
       private Long lastUpdated;
       private String species;

       public Potato(ObjectId id, String species) {
           this._id = id;
           this.lastUpdated = System.currentTimeMillis();
           this.species = species;
       }

       public Potato() { this.lastUpdated = System.currentTimeMillis(); }

       // convenience constructor that allows us to convert DynamicRealmObjects in a backup realm
       // into full object instances
       public Potato(DynamicRealmObject obj) {
           this._id = obj.getObjectId("_id");
           this.species = obj.getString("species");
           this.lastUpdated = obj.getLong("lastUpdated");
       }

       public ObjectId getId() { return _id; }
       public String getSpecies() { return species; }
       public void setSpecies(String species) {
           this.species = species;
           this.lastUpdated = System.currentTimeMillis();
       }
       public Long getLastUpdated() { return lastUpdated; }
       public void setLastUpdated(Long lastUpdated) {
           this.lastUpdated = lastUpdated;
       }
   }
