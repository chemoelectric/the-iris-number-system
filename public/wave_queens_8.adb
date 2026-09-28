pragma ada_2022;

with ada.text_io;
with ada.integer_text_io;
with ada.float_text_io;
with ada.numerics.generic_elementary_functions;

-- discrete 8-queens wave action potential relaxation engine.
-- author: frédéric blondin custer.
procedure wave_queens_8 is

   board_size : constant integer := 8;
   max_diag   : constant integer := 2 * board_size - 1;

   type real is new long_float;
   package real_math is new
     ada.numerics.generic_elementary_functions (real);
   use real_math;

   type board_indices is array (1 .. board_size) of integer;
   type board_angles is array (1 .. board_size) of real;
   type channel_array is array (integer range <>) of real;

   package real_io is new ada.text_io.float_io (real);

   pi : constant real := 3.141592653589793238462643383279502884;

   type rand_u32 is mod 2**32;

   rng_state : rand_u32 := 987654321;

   function next_random return integer is
      mult_val : constant rand_u32 := 1664525;
      add_val  : constant rand_u32 := 1013904223;
      res      : integer;
   begin
      rng_state := rng_state * mult_val + add_val;
      res := integer (rng_state / 2);
      return res;
   end next_random;

   procedure evaluate_wave_channels
     (phases     : in board_angles;
      col_re     : out channel_array;
      col_im     : out channel_array;
      diag1_re   : out channel_array;
      diag1_im   : out channel_array;
      diag2_re   : out channel_array;
      diag2_im   : out channel_array)
     with pre => col_re'first = 1 and col_re'last = board_size and
                 col_im'first = 1 and col_im'last = board_size and
                 diag1_re'first = 1 and diag1_re'last = max_diag and
                 diag1_im'first = 1 and diag1_im'last = max_diag and
                 diag2_re'first = 1 and diag2_re'last = max_diag and
                 diag2_im'first = 1 and diag2_im'last = max_diag
   is
      col_idx   : integer;
      d1_idx    : integer;
      d2_idx    : integer;
      ang_c     : real;
      ang_d1    : real;
      ang_d2    : real;
      fn_n      : real;
      k_wave    : real;
      c_val     : real;
      s_val     : real;
      row_idx   : integer;
   begin
      col_re := (others => 0.0);
      col_im := (others => 0.0);
      diag1_re := (others => 0.0);
      diag1_im := (others => 0.0);
      diag2_re := (others => 0.0);
      diag2_im := (others => 0.0);

      fn_n := real (board_size);
      k_wave := (2.0 * pi) / fn_n;
      row_idx := 1;

      while row_idx <= board_size loop
         ang_c := phases (row_idx);
         c_val := cos (ang_c);
         s_val := sin (ang_c);

         col_idx :=
           integer (real'floor ((ang_c / (2.0 * pi)) * fn_n)) + 1;
         if col_idx < 1 then
            col_idx := 1;
         elsif col_idx > board_size then
            col_idx := board_size;
         end if;

         d1_idx := row_idx - col_idx + board_size;
         d2_idx := row_idx + col_idx - 1;

         col_re (col_idx) := col_re (col_idx) + c_val;
         col_im (col_idx) := col_im (col_idx) + s_val;

         ang_d1 := k_wave * real (d1_idx);
         diag1_re (d1_idx) := diag1_re (d1_idx) + cos (ang_d1);
         diag1_im (d1_idx) := diag1_im (d1_idx) + sin (ang_d1);

         ang_d2 := k_wave * real (d2_idx);
         diag2_re (d2_idx) := diag2_re (d2_idx) + cos (ang_d2);
         diag2_im (d2_idx) := diag2_im (d2_idx) + sin (ang_d2);

         row_idx := row_idx + 1;
      end loop;
   end evaluate_wave_channels;

   function compute_action_potential
     (phases : in board_angles) return real
     with post => compute_action_potential'result >= 0.0
   is
      col_re   : channel_array (1 .. board_size);
      col_im   : channel_array (1 .. board_size);
      diag1_re : channel_array (1 .. max_diag);
      diag1_im : channel_array (1 .. max_diag);
      diag2_re : channel_array (1 .. max_diag);
      diag2_im : channel_array (1 .. max_diag);
      p_col    : real;
      p_d1     : real;
      p_d2     : real;
      diff     : real;
      total_e  : real;
      c_idx    : integer;
      d_idx    : integer;
   begin
      evaluate_wave_channels
        (phases,
         col_re,
         col_im,
         diag1_re,
         diag1_im,
         diag2_re,
         diag2_im);

      total_e := 0.0;
      c_idx := 1;

      while c_idx <= board_size loop
         p_col := (col_re (c_idx) ** 2) + (col_im (c_idx) ** 2);
         if p_col > 1.0 then
            diff := p_col - 1.0;
            total_e := total_e + diff;
         end if;
         c_idx := c_idx + 1;
      end loop;

      d_idx := 1;
      while d_idx <= max_diag loop
         p_d1 := (diag1_re (d_idx) ** 2) + (diag1_im (d_idx) ** 2);
         if p_d1 > 1.0 then
            diff := p_d1 - 1.0;
            total_e := total_e + diff;
         end if;

         p_d2 := (diag2_re (d_idx) ** 2) + (diag2_im (d_idx) ** 2);
         if p_d2 > 1.0 then
            diff := p_d2 - 1.0;
            total_e := total_e + diff;
         end if;
         d_idx := d_idx + 1;
      end loop;

      return total_e;
   end compute_action_potential;

   procedure quantize_columns
     (phases : in board_angles;
      cols   : out board_indices)
   is
      fn_n    : real;
      c_val   : integer;
      ang_c   : real;
      row_idx : integer;
   begin
      fn_n := real (board_size);
      row_idx := 1;
      while row_idx <= board_size loop
         ang_c := phases (row_idx);
         c_val :=
           integer (real'floor ((ang_c / (2.0 * pi)) * fn_n)) + 1;
         if c_val < 1 then
            c_val := 1;
         elsif c_val > board_size then
            c_val := board_size;
         end if;
         cols (row_idx) := c_val;
         row_idx := row_idx + 1;
      end loop;
   end quantize_columns;

   function verify_solution
     (cols : in board_indices) return boolean
   is
      valid : boolean;
      c1    : integer;
      c2    : integer;
      dc    : integer;
      dr    : integer;
      i     : integer;
      j     : integer;
   begin
      valid := true;
      i := 1;

      while i < board_size loop
         j := i + 1;
         while j <= board_size loop
            c1 := cols (i);
            c2 := cols (j);
            dc := abs (c1 - c2);
            dr := j - i;

            if c1 = c2 or dc = dr then
               valid := false;
            end if;
            j := j + 1;
         end loop;
         i := i + 1;
      end loop;

      return valid;
   end verify_solution;

   function find_conflicted_row
     (cols : in board_indices) return integer
   is
      type conflict_list is array (1 .. board_size) of integer;
      conf_rows : conflict_list;
      conf_cnt  : integer;
      r1        : integer;
      r2        : integer;
      has_conf  : boolean;
      c1        : integer;
      c2        : integer;
      dc        : integer;
      dr        : integer;
      chosen    : integer;
      rnd_idx   : integer;
   begin
      conf_cnt := 0;
      r1 := 1;

      while r1 <= board_size loop
         has_conf := false;
         r2 := 1;
         while r2 <= board_size loop
            if r1 /= r2 then
               c1 := cols (r1);
               c2 := cols (r2);
               dc := abs (c1 - c2);
               dr := abs (r1 - r2);
               if c1 = c2 or dc = dr then
                  has_conf := true;
               end if;
            end if;
            r2 := r2 + 1;
         end loop;

         if has_conf then
            conf_cnt := conf_cnt + 1;
            conf_rows (conf_cnt) := r1;
         end if;
         r1 := r1 + 1;
      end loop;

      if conf_cnt > 0 then
         rnd_idx := (next_random mod conf_cnt) + 1;
         chosen := conf_rows (rnd_idx);
      else
         chosen := 1;
      end if;

      return chosen;
   end find_conflicted_row;

   procedure step_phase_relaxation
     (phases     : in out board_angles;
      cols       : in board_indices;
      plateau    : in out integer)
   is
      target_r  : integer;
      min_e     : real;
      best_c    : integer;
      cand_c    : integer;
      test_p    : board_angles;
      cand_ang  : real;
      test_e    : real;
      curr_e    : real;
      fn_n      : real;
      k_row     : integer;
      k_col     : integer;
      k_ang     : real;
   begin
      fn_n := real (board_size);
      curr_e := compute_action_potential (phases);
      target_r := find_conflicted_row (cols);

      min_e := 999999.0;
      best_c := cols (target_r);
      cand_c := 1;

      while cand_c <= board_size loop
         test_p := phases;
         cand_ang := (real (cand_c - 1) + 0.5) * (2.0 * pi / fn_n);
         test_p (target_r) := cand_ang;
         test_e := compute_action_potential (test_p);

         if test_e < min_e then
            min_e := test_e;
            best_c := cand_c;
         end if;
         cand_c := cand_c + 1;
      end loop;

      phases (target_r) :=
        (real (best_c - 1) + 0.5) * (2.0 * pi / fn_n);

      if min_e >= curr_e then
         plateau := plateau + 1;
      else
         plateau := 0;
      end if;

      if plateau > 10 then
         k_row := 1;
         while k_row <= board_size loop
            k_col := (next_random mod board_size) + 1;
            k_ang := (real (k_col - 1) + 0.5) * (2.0 * pi / fn_n);
            phases (k_row) := k_ang;
            k_row := k_row + 1;
         end loop;
         plateau := 0;
      end if;
   end step_phase_relaxation;

   procedure print_board (cols : in board_indices) is
      r : integer;
      c : integer;
   begin
      ada.text_io.put_line ("+---+---+---+---+---+---+---+---+");
      r := 1;
      while r <= board_size loop
         c := 1;
         while c <= board_size loop
            if cols (r) = c then
               ada.text_io.put ("| Q ");
            else
               ada.text_io.put ("|   ");
            end if;
            c := c + 1;
         end loop;
         ada.text_io.put_line ("|");
         ada.text_io.put_line ("+---+---+---+---+---+---+---+---+");
         r := r + 1;
      end loop;
   end print_board;

   phases     : board_angles;
   cols       : board_indices;
   energy     : real;
   solved     : boolean;
   step_cnt   : integer;
   seed_phase : real;
   max_steps  : constant integer := 5000;
   fn_n       : real;
   row_init   : integer;
   pr_row     : integer;
   plateau    : integer;
begin
   ada.text_io.put_line ("========================================");
   ada.text_io.put_line ("Iris Wave-Mechanical 8-Queens Engine");
   ada.text_io.put_line ("========================================");

   fn_n := real (board_size);

   -- initialize phases with non-colliding continuous offset.
   row_init := 1;
   while row_init <= board_size loop
      seed_phase :=
        (real (row_init - 1) * (2.0 * pi / fn_n)) + 0.15;
      phases (row_init) := seed_phase;
      row_init := row_init + 1;
   end loop;

   step_cnt := 0;
   plateau := 0;
   solved := false;

   while step_cnt < max_steps and not solved loop
      quantize_columns (phases, cols);
      energy := compute_action_potential (phases);
      solved := verify_solution (cols);

      if solved or step_cnt mod 500 = 0 then
         ada.text_io.put ("Step ");
         ada.integer_text_io.put (step_cnt, width => 4);
         ada.text_io.put (" | Action Potential: ");
         real_io.put (energy, fore => 2, aft => 4, exp => 0);
         if solved then
            ada.text_io.put_line (" [PHASE-LOCKED SOLUTION FOUND]");
         else
            ada.text_io.put_line (" [Relaxing wave field...]");
         end if;
      end if;

      if not solved then
         step_phase_relaxation (phases, cols, plateau);
         step_cnt := step_cnt + 1;
      end if;
   end loop;

   if solved then
      ada.text_io.new_line;
      ada.text_io.put_line ("Valid 8-Queens Permutation:");
      ada.text_io.put ("(");
      pr_row := 1;
      while pr_row <= board_size loop
         ada.integer_text_io.put (cols (pr_row), width => 1);
         if pr_row < board_size then
            ada.text_io.put (", ");
         end if;
         pr_row := pr_row + 1;
      end loop;
      ada.text_io.put_line (")");
      ada.text_io.new_line;
      print_board (cols);
   else
      ada.text_io.put_line ("Phase-locking search terminated.");
   end if;

   ada.text_io.put_line ("========================================");
end wave_queens_8;
