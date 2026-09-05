pragma ada_2022;

-- generic sentinel-based block hash table for the iris typesetter.
-- author: frédéric blondin custer.

generic
   type key_type is private;
   type value_type is private;
   type hash_type is mod <>;
   sentinel_key   : in key_type;
   sentinel_value : in value_type;
   with function hash (key : in key_type) return hash_type;
   with function "=" (left : in key_type; right : in key_type)
     return boolean is <>;
   block_size     : in positive := 8;
   max_table_size : in positive := 1024;
package iris_sentinel_hash is

   type table_type is limited private;

   procedure initialize (table : out table_type)
     with post => count (table) = 0 and is_empty (table);

   procedure clear (table : in out table_type)
     with post => count (table) = 0 and is_empty (table);

   function count (table : in table_type) return natural;

   function capacity (table : in table_type) return positive
     with post => capacity'result = max_table_size;

   function is_empty (table : in table_type) return boolean;

   function is_full (table : in table_type) return boolean;

   procedure lookup
     (table : in table_type;
      key   : in key_type;
      found : out boolean;
      value : out value_type)
     with pre => key /= sentinel_key;

   procedure lookup_index
     (table : in table_type;
      key   : in key_type;
      found : out boolean;
      index : out natural)
     with pre => key /= sentinel_key;

   function contains
     (table : in table_type;
      key   : in key_type) return boolean
     with pre => key /= sentinel_key;

   procedure insert
     (table   : in out table_type;
      key     : in key_type;
      value   : in value_type;
      success : out boolean)
     with pre => key /= sentinel_key;

   procedure remove
     (table   : in out table_type;
      key     : in key_type;
      removed : out boolean)
     with pre => key /= sentinel_key;

private

   type slot_index is range 0 .. max_table_size - 1;

   type slot_entry is record
      key      : key_type;
      value    : value_type;
      occupied : boolean;
   end record;

   type slot_array is array (slot_index) of slot_entry;

   type table_type is limited record
      slots       : slot_array;
      item_count  : natural := 0;
      initialized : boolean := false;
   end record;

end iris_sentinel_hash;
