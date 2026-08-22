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
      r_val     : real;
   begin
      col_re := (others => 0.0);
      col_im := (others => 0.0);
      diag1_re := (others => 0.0);
      diag1_im := (others => 0.0);
      diag2_re := (others => 0.0);
      diag2_im := (others => 0.0);

      fn_n := real (board_size);
      k_wave := (2.0 * pi) / fn_n;

      for row in 1 .. board_size loop
         ang_c := phases (row);
         c_val := cos (ang_c);
         s_val := sin (ang_c);
         r_val := real (row);

         col_idx :=
           integer (real'floor ((ang_c / (2.0 * pi)) * fn_n)) + 1;
         if col_idx < 1 then
            col_idx := 1;
         elsif col_idx > board_size then
            col_idx := board_size;
         end if;

         d1_idx := row - col_idx + board_size;
         d2_idx := row + col_idx - 1;

         col_re (col_idx) := col_re (col_idx) + c_val;
         col_im (col_idx) := col_im (col_idx) + s_val;

         ang_d1 := k_wave * real (d1_idx);
         diag1_re (d1_idx) := diag1_re (d1_idx) + cos (ang_d1);
         diag1_im (d1_idx) := diag1_im (d1_idx) + sin (ang_d1);

         ang_d2 := k_wave * real (d2_idx);
         diag2_re (d2_idx) := diag2_re (d2_idx) + cos (ang_d2);
         diag2_im (d2_idx) := diag2_im (d2_idx) + sin (ang_d2);
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

      for c in 1 .. board_size loop
         p_col := (col_re (c) ** 2) + (col_im (c) ** 2);
         if p_col > 1.0 then
            diff := p_col - 1.0;
            total_e := total_e + diff;
         end if;
      end loop;

      for d in 1 .. max_diag loop
         p_d1 := (diag1_re (d) ** 2) + (diag1_im (d) ** 2);
         if p_d1 > 1.0 then
            diff := p_d1 - 1.0;
            total_e := total_e + diff;
         end if;

         p_d2 := (diag2_re (d) ** 2) + (diag2_im (d) ** 2);
         if p_d2 > 1.0 then
            diff := p_d2 - 1.0;
            total_e := total_e + diff;
         end if;
      end loop;

      return total_e;
   end compute_action_potential;

   procedure step_phase_gradient
     (phases     : in out board_angles;
      step_size  : in real)
     with pre => step_size > 0.0
   is
      eps      : constant real := 0.0001;
      p_plus   : board_angles;
      p_minus  : board_angles;
      e_plus   : real;
      e_minus  : real;
      grad     : real;
      new_ang  : real;
      two_eps  : real;
   begin
      two_eps := 2.0 * eps;

      for row in 1 .. board_size loop
         p_plus := phases;
         p_minus := phases;

         p_plus (row) := p_plus (row) + eps;
         p_minus (row) := p_minus (row) - eps;

         e_plus := compute_action_potential (p_plus);
         e_minus := compute_action_potential (p_minus);

         grad := (e_plus - e_minus) / two_eps;
         new_ang := phases (row) - (step_size * grad);

         while new_ang < 0.0 loop
            new_ang := new_ang + (2.0 * pi);
         end loop;

         while new_ang >= (2.0 * pi) loop
            new_ang := new_ang - (2.0 * pi);
         end loop;

         phases (row) := new_ang;
      end loop;
   end step_phase_gradient;

   procedure quantize_columns
     (phases : in board_angles;
      cols   : out board_indices)
   is
      fn_n    : real;
      c_val   : integer;
      ang_c   : real;
   begin
      fn_n := real (board_size);
      for row in 1 .. board_size loop
         ang_c := phases (row);
         c_val :=
           integer (real'floor ((ang_c / (2.0 * pi)) * fn_n)) + 1;
         if c_val < 1 then
            c_val := 1;
         elsif c_val > board_size then
            c_val := board_size;
         end if;
         cols (row) := c_val;
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
   begin
      valid := true;

      for i in 1 .. board_size - 1 loop
         for j in i + 1 .. board_size loop
            c1 := cols (i);
            c2 := cols (j);
            dc := abs (c1 - c2);
            dr := j - i;

            if c1 = c2 or dc = dr then
               valid := false;
            end if;
         end loop;
      end loop;

      return valid;
   end verify_solution;

   procedure print_board (cols : in board_indices) is
   begin
      ada.text_io.put_line ("+---+---+---+---+---+---+---+---+");
      for r in 1 .. board_size loop
         for c in 1 .. board_size loop
            if cols (r) = c then
               ada.text_io.put ("| Q ");
            else
               ada.text_io.put ("|   ");
            end if;
         end loop;
         ada.text_io.put_line ("|");
         ada.text_io.put_line ("+---+---+---+---+---+---+---+---+");
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
begin
   ada.text_io.put_line ("========================================");
   ada.text_io.put_line ("Iris Wave-Mechanical 8-Queens Engine");
   ada.text_io.put_line ("========================================");

   fn_n := real (board_size);

   -- initialize phases with non-colliding continuous offset.
   for row in 1 .. board_size loop
      seed_phase := (real (row - 1) * (2.0 * pi / fn_n)) + 0.15;
      phases (row) := seed_phase;
   end loop;

   step_cnt := 0;
   solved := false;

   while step_cnt < max_steps and not solved loop
      energy := compute_action_potential (phases);
      quantize_columns (phases, cols);
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
         step_phase_gradient (phases, 0.05);
         step_cnt := step_cnt + 1;
      end if;
   end loop;

   if solved then
      ada.text_io.new_line;
      ada.text_io.put_line ("Valid 8-Queens Permutation:");
      ada.text_io.put ("(");
      for r in 1 .. board_size loop
         ada.integer_text_io.put (cols (r), width => 1);
         if r < board_size then
            ada.text_io.put (", ");
         end if;
      end loop;
      ada.text_io.put_line (")");
      ada.text_io.new_line;
      print_board (cols);
   else
      ada.text_io.put_line ("Phase-locking search terminated.");
   end if;

   ada.text_io.put_line ("========================================");
end wave_queens_8;
