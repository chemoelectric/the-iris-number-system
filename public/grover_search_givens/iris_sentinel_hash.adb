pragma ada_2022;

-- generic sentinel-based block hash table body for iris typesetter.
-- author: frédéric blondin custer.

package body iris_sentinel_hash is

   procedure scan_block
     (table       : in table_type;
      base_idx    : in natural;
      target_key  : in key_type;
      blk_found   : out boolean;
      blk_empty   : out boolean;
      match_idx   : out natural;
      empty_idx   : out natural)
   is
      offset    : natural;
      curr_idx  : natural;
      found_var : boolean;
      empty_var : boolean;
      curr_key  : key_type;
      is_occ    : boolean;
   begin
      offset    := 0;
      found_var := false;
      empty_var := false;
      match_idx := base_idx;
      empty_idx := base_idx;

      while not found_var and then offset < block_size loop
         curr_idx := (base_idx + offset) mod max_table_size;
         curr_key := table.slots (slot_index (curr_idx)).key;
         is_occ   := table.slots (slot_index (curr_idx)).occupied;

         if is_occ and then curr_key = target_key then
            found_var := true;
            match_idx := curr_idx;
         elsif not is_occ and then not empty_var then
            empty_var := true;
            empty_idx := curr_idx;
         end if;

         offset := offset + 1;
      end loop;

      blk_found := found_var;
      blk_empty := empty_var;
   end scan_block;

   procedure initialize (table : out table_type) is
      idx : natural;
   begin
      idx := 0;
      while idx < max_table_size loop
         table.slots (slot_index (idx)).key      := sentinel_key;
         table.slots (slot_index (idx)).value    := sentinel_value;
         table.slots (slot_index (idx)).occupied := false;
         idx := idx + 1;
      end loop;

      table.item_count  := 0;
      table.initialized := true;
   end initialize;

   procedure clear (table : in out table_type) is
   begin
      initialize (table);
   end clear;

   function count (table : in table_type) return natural is
      res : natural;
   begin
      res := table.item_count;
      return res;
   end count;

   function capacity (table : in table_type) return positive is
      res : positive;
   begin
      res := max_table_size;
      return res;
   end capacity;

   function is_empty (table : in table_type) return boolean is
      res : boolean;
   begin
      res := table.item_count = 0;
      return res;
   end is_empty;

   function is_full (table : in table_type) return boolean is
      res : boolean;
   begin
      res := table.item_count = max_table_size;
      return res;
   end is_full;

   procedure lookup_index
     (table : in table_type;
      key   : in key_type;
      found : out boolean;
      index : out natural)
   is
      h_val     : hash_type;
      base_idx  : natural;
      probes    : natural;
      res_found : boolean;
      res_idx   : natural;
      blk_found : boolean;
      blk_empty : boolean;
      blk_match : natural;
      blk_first : natural;
      step      : natural;
   begin
      h_val     := hash (key);
      base_idx  := natural (h_val mod hash_type (max_table_size));
      probes    := 0;
      res_found := false;
      res_idx   := 0;
      step      := block_size;

      while not res_found and then probes < max_table_size loop
         scan_block
           (table       => table,
            base_idx    => base_idx,
            target_key  => key,
            blk_found   => blk_found,
            blk_empty   => blk_empty,
            match_idx   => blk_match,
            empty_idx   => blk_first);

         if blk_found then
            res_found := true;
            res_idx   := blk_match;
         elsif blk_empty then
            probes := max_table_size;
         else
            probes   := probes + step;
            base_idx := (base_idx + step) mod max_table_size;
         end if;
      end loop;

      found := res_found;
      index := res_idx;
   end lookup_index;

   procedure lookup
     (table : in table_type;
      key   : in key_type;
      found : out boolean;
      value : out value_type)
   is
      idx_found : boolean;
      slot_pos  : natural;
      res_val   : value_type;
   begin
      lookup_index
        (table => table,
         key   => key,
         found => idx_found,
         index => slot_pos);

      if idx_found then
         res_val := table.slots (slot_index (slot_pos)).value;
      else
         res_val := sentinel_value;
      end if;

      found := idx_found;
      value := res_val;
   end lookup;

   function contains
     (table : in table_type;
      key   : in key_type) return boolean
   is
      found_flag : boolean;
      pos        : natural;
      res        : boolean;
   begin
      lookup_index
        (table => table,
         key   => key,
         found => found_flag,
         index => pos);

      res := found_flag;
      return res;
   end contains;

   procedure insert
     (table   : in out table_type;
      key     : in key_type;
      value   : in value_type;
      success : out boolean)
   is
      h_val      : hash_type;
      base_idx   : natural;
      probes     : natural;
      res_ok     : boolean;
      blk_found  : boolean;
      blk_empty  : boolean;
      blk_match  : natural;
      blk_free   : natural;
      first_free : natural;
      has_free   : boolean;
      step       : natural;
      done       : boolean;
   begin
      h_val      := hash (key);
      base_idx   := natural (h_val mod hash_type (max_table_size));
      probes     := 0;
      res_ok     := false;
      has_free   := false;
      first_free := 0;
      step       := block_size;
      done       := false;

      while not done and then probes < max_table_size loop
         scan_block
           (table       => table,
            base_idx    => base_idx,
            target_key  => key,
            blk_found   => blk_found,
            blk_empty   => blk_empty,
            match_idx   => blk_match,
            empty_idx   => blk_free);

         if blk_found then
            table.slots (slot_index (blk_match)).value := value;
            res_ok := true;
            done   := true;
         elsif blk_empty then
            if not has_free then
               first_free := blk_free;
               has_free   := true;
            end if;
            done := true;
         else
            probes   := probes + step;
            base_idx := (base_idx + step) mod max_table_size;
         end if;
      end loop;

      if not res_ok and then has_free then
         table.slots (slot_index (first_free)).key      := key;
         table.slots (slot_index (first_free)).value    := value;
         table.slots (slot_index (first_free)).occupied := true;
         table.item_count := table.item_count + 1;
         res_ok := true;
      end if;

      success := res_ok;
   end insert;

   procedure remove
     (table   : in out table_type;
      key     : in key_type;
      removed : out boolean)
   is
      idx_found : boolean;
      slot_pos  : natural;
      res_rem   : boolean;
   begin
      lookup_index
        (table => table,
         key   => key,
         found => idx_found,
         index => slot_pos);

      if idx_found then
         table.slots (slot_index (slot_pos)).key :=
           sentinel_key;
         table.slots (slot_index (slot_pos)).value :=
           sentinel_value;
         table.slots (slot_index (slot_pos)).occupied := false;
         table.item_count := table.item_count - 1;
         res_rem := true;
      else
         res_rem := false;
      end if;

      removed := res_rem;
   end remove;

end iris_sentinel_hash;
