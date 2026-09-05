pragma ada_2022;

-- test driver for generic sentinel block hash table.
-- author: frédéric blondin custer.

with ada.text_io;
with iris_sentinel_hash;
with interfaces;

procedure test_iris_sentinel_hash is

   type u32 is new interfaces.unsigned_32;

   -- glyph metric record for iris typesetter.
   type glyph_metric is record
      advance_width : integer;
      left_bearing  : integer;
      bbox_height   : integer;
   end record;

   sentinel_metric : constant glyph_metric :=
     (advance_width => -1, left_bearing => -1, bbox_height => -1);

   sentinel_id : constant u32 := 16#ffff_ffff#;

   -- 32-bit modular hash function for glyph identifiers.
   function hash_glyph (k : in u32) return u32 is
      h : u32;
   begin
      h := k * 16#45d9_f3b#;
      h := h xor (h / 16#10000#);
      return h;
   end hash_glyph;

   -- instantiate hash table for glyph metrics.
   package glyph_table_pkg is new iris_sentinel_hash
     (key_type       => u32,
      value_type     => glyph_metric,
      hash_type      => u32,
      sentinel_key   => sentinel_id,
      sentinel_value => sentinel_metric,
      hash           => hash_glyph,
      block_size     => 8,
      max_table_size => 64);

   tbl : glyph_table_pkg.table_type;

   procedure test_insertion (t : in out glyph_table_pkg.table_type) is
      ok  : boolean;
      g   : glyph_metric;
      idx : natural;
      k   : u32;
   begin
      idx := 0;
      while idx < 20 loop
         k := u32 (idx + 65);
         g := (advance_width => integer (idx * 50 + 500),
               left_bearing  => integer (idx * 5 + 20),
               bbox_height   => 700);

         glyph_table_pkg.insert
           (table   => t,
            key     => k,
            value   => g,
            success => ok);

         idx := idx + 1;
      end loop;
   end test_insertion;

   procedure test_lookups (t : in glyph_table_pkg.table_type) is
      found : boolean;
      g     : glyph_metric;
      idx   : natural;
      k     : u32;
   begin
      idx := 0;
      while idx < 20 loop
         k := u32 (idx + 65);
         glyph_table_pkg.lookup
           (table => t,
            key   => k,
            found => found,
            value => g);

         if not found then
            ada.text_io.put_line ("lookup failed unexpectedly");
         end if;

         idx := idx + 1;
      end loop;
   end test_lookups;

   procedure test_miss (t : in glyph_table_pkg.table_type) is
      found : boolean;
      g     : glyph_metric;
      k     : u32;
   begin
      k := 16#9999#;
      glyph_table_pkg.lookup
        (table => t,
         key   => k,
         found => found,
         value => g);

      if found then
         ada.text_io.put_line ("miss matched unexpectedly");
      end if;
   end test_miss;

begin
   glyph_table_pkg.initialize (tbl);

   test_insertion (tbl);
   test_lookups (tbl);
   test_miss (tbl);

   ada.text_io.put_line
     ("sentinel block hash table verified successfully.");
end test_iris_sentinel_hash;
