pragma ada_2022;

with ada.text_io;
with ada.float_text_io;
with ada.numerics.generic_elementary_functions;

-- digital grover search inference engine using givens rotations.
-- author: frédéric blondin custer.
procedure grover_search_givens is

   type real is new long_float;
   package real_functions is new
     ada.numerics.generic_elementary_functions (real);
   use real_functions;

   type state_vector is array (integer range <>) of real;

   procedure apply_givens_rotation
     (state : in out state_vector;
      p     : in integer;
      q     : in integer;
      theta : in real)
     with pre => p >= state'first and
                 p <= state'last and
                 q >= state'first and
                 q <= state'last and
                 p /= q
   is
      cos_t : real;
      sin_t : real;
      val_p : real;
      val_q : real;
      t1    : real;
      t2    : real;
      new_p : real;
      new_q : real;
   begin
      cos_t := cos (theta);
      sin_t := sin (theta);
      val_p := state (p);
      val_q := state (q);

      t1 := cos_t * val_p;
      t2 := sin_t * val_q;
      new_p := t1 - t2;

      t1 := sin_t * val_p;
      t2 := cos_t * val_q;
      new_q := t1 + t2;

      state (p) := new_p;
      state (q) := new_q;
   end apply_givens_rotation;

   function compute_step_angle (n_size : in integer) return real
     with pre  => n_size >= 2,
          post => compute_step_angle'result > 0.0
   is
      fn       : real;
      sqn      : real;
      arg      : real;
      asin_val : real;
      res      : real;
   begin
      fn := real (n_size);
      sqn := sqrt (fn);
      arg := 1.0 / sqn;
      asin_val := asin (arg);
      res := 2.0 * asin_val;
      return res;
   end compute_step_angle;

   procedure init_uniform_state (state : out state_vector)
     with pre => state'length >= 2
   is
      n_val : real;
      sqn   : real;
      amp   : real;
      i     : integer;
   begin
      n_val := real (state'length);
      sqn := sqrt (n_val);
      amp := 1.0 / sqn;

      i := state'first;
      while i <= state'last loop
         state (i) := amp;
         i := i + 1;
      end loop;
   end init_uniform_state;

   procedure execute_subspace_givens
     (n_size    : in integer;
      n_steps   : in integer;
      out_ortho : out real;
      out_mark  : out real)
     with pre => n_size >= 2 and n_steps >= 0
   is
      theta    : real;
      half_t   : real;
      curr_o   : real;
      curr_m   : real;
      cos_t    : real;
      sin_t    : real;
      t1       : real;
      t2       : real;
      next_o   : real;
      next_m   : real;
      step     : integer;
   begin
      theta := compute_step_angle (n_size);
      half_t := 0.5 * theta;

      curr_o := cos (half_t);
      curr_m := sin (half_t);

      cos_t := cos (theta);
      sin_t := sin (theta);

      step := 0;
      while step < n_steps loop
         t1 := cos_t * curr_o;
         t2 := sin_t * curr_m;
         next_o := t1 - t2;

         t1 := sin_t * curr_o;
         t2 := cos_t * curr_m;
         next_m := t1 + t2;

         curr_o := next_o;
         curr_m := next_m;
         step := step + 1;
      end loop;

      out_ortho := curr_o;
      out_mark := curr_m;
   end execute_subspace_givens;

   function find_max_index (state : in state_vector) return integer
     with pre => state'length >= 1
   is
      best_idx : integer;
      max_val  : real;
      curr_val : real;
      i        : integer;
   begin
      best_idx := state'first;
      max_val := abs (state (best_idx));

      i := state'first + 1;
      while i <= state'last loop
         curr_val := abs (state (i));
         if curr_val > max_val then
            max_val := curr_val;
            best_idx := i;
         end if;
         i := i + 1;
      end loop;

      return best_idx;
   end find_max_index;

   n_dim    : constant integer := 1024;
   target_w : constant integer := 42;
   theta    : real;
   opt_k    : integer;
   pi_val   : constant real := 3.14159265358979323846;
   k_exact  : real;
   ortho_amp: real;
   mark_amp : real;
   prob_mark: real;
   found_idx: integer;
   vec_16   : state_vector (0 .. 15);
   i_idx    : integer;
begin
   ada.text_io.put_line
     ("=================================================");
   ada.text_io.put_line
     (" digital grover search engine (givens rotation) ");
   ada.text_io.put_line
     ("   demonstration in floating-point (ada 2022)   ");
   ada.text_io.put_line
     ("=================================================");

   theta := compute_step_angle (n_dim);
   k_exact := (0.5 * pi_val) / theta;
   opt_k := integer (real'floor (k_exact));

   ada.text_io.put ("search space size N      : ");
   ada.text_io.put (integer'image (n_dim));
   ada.text_io.new_line;

   ada.text_io.put ("givens step angle theta  : ");
   ada.float_text_io.put
     (item => float (theta),
      fore => 1,
      aft  => 6,
      exp  => 0);
   ada.text_io.new_line;

   ada.text_io.put ("optimal givens steps k   : ");
   ada.text_io.put (integer'image (opt_k));
   ada.text_io.new_line;

   execute_subspace_givens
     (n_size    => n_dim,
      n_steps   => opt_k,
      out_ortho => ortho_amp,
      out_mark  => mark_amp);

   prob_mark := mark_amp * mark_amp;

   ada.text_io.put ("target state amplitude   : ");
   ada.float_text_io.put
     (item => float (mark_amp),
      fore => 1,
      aft  => 6,
      exp  => 0);
   ada.text_io.new_line;

   ada.text_io.put ("target state probability : ");
   ada.float_text_io.put
     (item => float (prob_mark),
      fore => 1,
      aft  => 6,
      exp  => 0);
   ada.text_io.new_line;

   init_uniform_state (vec_16);
   apply_givens_rotation
     (state => vec_16,
      p     => 0,
      q     => 3,
      theta => 0.7853981633974483);

   found_idx := find_max_index (vec_16);
   ada.text_io.put ("rotated vector max index : ");
   ada.text_io.put (integer'image (found_idx));
   ada.text_io.new_line;
end grover_search_givens;
