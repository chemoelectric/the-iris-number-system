pragma ada_2022;

with ada.text_io;
with ada.integer_text_io;

-- discrete 8-queens grassmann exterior wave annihilation engine.
-- computes the complete ensemble of 92 solutions simultaneously.
-- author: frédéric blondin custer.
procedure grassmann_queens_8 is

   board_size : constant integer := 8;
   max_blades : constant integer := 1024;

   type board_indices is array (1 .. board_size) of integer;
   type mask_u32 is mod 2**32;

   type wave_blade is record
      cols     : board_indices;
      col_mask : mask_u32;
      d1_mask  : mask_u32;
      d2_mask  : mask_u32;
   end record;

   type blade_array is array (1 .. max_blades) of wave_blade;

   procedure init_vacuum_blade
     (blade_list : out blade_array;
      count      : out integer)
     with post => count = 1
   is
      empty_cols : board_indices;
      idx        : integer;
   begin
      idx := 1;
      while idx <= board_size loop
         empty_cols (idx) := 0;
         idx := idx + 1;
      end loop;

      blade_list (1) :=
        (cols     => empty_cols,
         col_mask => 0,
         d1_mask  => 0,
         d2_mask  => 0);
      count := 1;
   end init_vacuum_blade;

   function shift_bit (pos : in integer) return mask_u32 is
      res : mask_u32;
   begin
      res := mask_u32 (2 ** pos);
      return res;
   end shift_bit;

   procedure expand_row_wave
     (curr_blades : in blade_array;
      curr_count  : in integer;
      row_idx     : in integer;
      next_blades : out blade_array;
      next_count  : out integer)
     with pre  => curr_count >= 1 and curr_count <= max_blades and
                  row_idx >= 1 and row_idx <= board_size,
          post => next_count >= 0 and next_count <= max_blades
   is
      b_idx    : integer;
      col_idx  : integer;
      d1_idx   : integer;
      d2_idx   : integer;
      c_bit    : mask_u32;
      d1_bit   : mask_u32;
      d2_bit   : mask_u32;
      src      : wave_blade;
      dst_cols : board_indices;
   begin
      next_count := 0;
      b_idx := 1;

      while b_idx <= curr_count loop
         src := curr_blades (b_idx);
         col_idx := 1;

         while col_idx <= board_size loop
            c_bit := shift_bit (col_idx);
            d1_idx := row_idx - col_idx + board_size;
            d1_bit := shift_bit (d1_idx);
            d2_idx := row_idx + col_idx - 1;
            d2_bit := shift_bit (d2_idx);

            -- nilpotent exterior wedge: check channel orthogonality
            if (src.col_mask and c_bit) = 0 and then
               (src.d1_mask and d1_bit) = 0 and then
               (src.d2_mask and d2_bit) = 0
            then
               next_count := next_count + 1;
               dst_cols := src.cols;
               dst_cols (row_idx) := col_idx;

               next_blades (next_count) :=
                 (cols     => dst_cols,
                  col_mask => src.col_mask or c_bit,
                  d1_mask  => src.d1_mask or d1_bit,
                  d2_mask  => src.d2_mask or d2_bit);
            end if;

            col_idx := col_idx + 1;
         end loop;

         b_idx := b_idx + 1;
      end loop;
   end expand_row_wave;

   procedure print_solution_line
     (sol_idx : in integer;
      blade   : in wave_blade)
   is
      r : integer;
   begin
      ada.text_io.put ("  Solution ");
      ada.integer_text_io.put (sol_idx, width => 2);
      ada.text_io.put (": (");
      r := 1;
      while r <= board_size loop
         ada.integer_text_io.put (blade.cols (r), width => 1);
         if r < board_size then
            ada.text_io.put (", ");
         end if;
         r := r + 1;
      end loop;
      ada.text_io.put_line (")");
   end print_solution_line;

   procedure print_sample_ensemble
     (blades : in blade_array;
      count  : in integer)
     with pre => count >= 1 and count <= max_blades
   is
      show_cnt : integer;
      idx      : integer;
   begin
      ada.text_io.new_line;
      ada.text_io.put_line
        ("Sample Solutions from the 92-Blade Homogeneous Multivector:");
      
      show_cnt := 8;
      if count < show_cnt then
         show_cnt := count;
      end if;

      idx := 1;
      while idx <= show_cnt loop
         print_solution_line (idx, blades (idx));
         idx := idx + 1;
      end loop;

      if count > show_cnt then
         ada.text_io.put_line ("  ...");
         print_solution_line (count, blades (count));
      end if;
   end print_sample_ensemble;

   active_blades : blade_array;
   temp_blades   : blade_array;
   blade_cnt     : integer;
   next_cnt      : integer;
   row           : integer;
begin
   ada.text_io.put_line
     ("============================================================");
   ada.text_io.put_line
     ("Iris Grassmann Exterior Wave-Superposition 8-Queens Engine");
   ada.text_io.put_line
     ("============================================================");

   init_vacuum_blade (active_blades, blade_cnt);

   row := 1;
   while row <= board_size loop
      expand_row_wave
        (curr_blades => active_blades,
         curr_count  => blade_cnt,
         row_idx     => row,
         next_blades => temp_blades,
         next_count  => next_cnt);

      active_blades := temp_blades;
      blade_cnt := next_cnt;

      ada.text_io.put ("Row ");
      ada.integer_text_io.put (row, width => 1);
      ada.text_io.put (": Wedge product W_");
      ada.integer_text_io.put (row, width => 1);
      ada.text_io.put (" -> Surviving constructive blades: ");
      ada.integer_text_io.put (blade_cnt, width => 3);
      ada.text_io.new_line;

      row := row + 1;
   end loop;

   ada.text_io.new_line;
   ada.text_io.put ("Total ground-state solutions in Psi_all: ");
   ada.integer_text_io.put (blade_cnt, width => 1);
   ada.text_io.new_line;

   print_sample_ensemble (active_blades, blade_cnt);

   ada.text_io.put_line
     ("============================================================");
end grassmann_queens_8;
