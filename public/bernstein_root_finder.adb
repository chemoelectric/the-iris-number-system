pragma ada_2022;

with ada.text_io;
with ada.float_text_io;
with ada.numerics.elementary_functions;

-- complete demonstration of command officer's recursive bernstein
-- derivative-crossing real root isolation algorithm in floating point.
-- author: frédéric blondin custer.
procedure bernstein_root_finder is

   type real is new long_float;
   type float_array is array (integer range <>) of real;

   function eval_bernstein (coeffs : float_array; u : real) return real is
      m : constant integer := coeffs'length - 1;
      v : float_array (0 .. m);
      i : integer;
      j : integer;
      u_1 : real;
      t1 : real;
      t2 : real;
      idx : integer;
      res : real;
   begin
      i := 0;
      while i <= m loop
         idx := coeffs'first + i;
         v (i) := coeffs (idx);
         i := i + 1;
      end loop;

      u_1 := 1.0 - u;
      j := 1;
      while j <= m loop
         i := 0;
         while i <= (m - j) loop
            t1 := u_1 * v (i);
            idx := i + 1;
            t2 := u * v (idx);
            v (i) := t1 + t2;
            i := i + 1;
         end loop;
         j := j + 1;
      end loop;

      res := v (0);
      return res;
   end eval_bernstein;

   function compute_error_filter (coeffs : float_array) return real is
      m_val : constant real := real (coeffs'length - 1);
      eps_mach : constant real := real'epsilon;
      gamma_m : real;
      sum_abs : real;
      i : integer;
      term : real;
      prod : real;
      denom : real;
      res : real;
   begin
      sum_abs := 0.0;
      i := coeffs'first;
      while i <= coeffs'last loop
         term := abs (coeffs (i));
         sum_abs := sum_abs + term;
         i := i + 1;
      end loop;

      prod := m_val * eps_mach;
      denom := 1.0 - prod;
      gamma_m := prod / denom;
      res := gamma_m * sum_abs;
      return res;
   end compute_error_filter;

   procedure compute_derivative
     (coeffs : float_array;
      deriv  : out float_array)
   is
      m_val : constant real := real (coeffs'length - 1);
      i : integer;
      idx1 : integer;
      idx2 : integer;
      val1 : real;
      val2 : real;
      diff : real;
      d_idx : integer;
   begin
      i := 0;
      while i < deriv'length loop
         idx1 := coeffs'first + i;
         idx2 := idx1 + 1;
         val1 := coeffs (idx1);
         val2 := coeffs (idx2);
         diff := val2 - val1;
         d_idx := deriv'first + i;
         deriv (d_idx) := m_val * diff;
         i := i + 1;
      end loop;
   end compute_derivative;

   function refine_root_itp
     (coeffs   : float_array;
      domain_a : real;
      domain_b : real;
      a_in     : real;
      b_in     : real;
      tol      : real) return real
   is
      a : real;
      b : real;
      fa : real;
      fb : real;
      fitp : real;
      u_a : real;
      u_b : real;
      u_itp : real;
      x_half : real;
      x_f : real;
      x_t : real;
      x_itp : real;
      delta : real;
      sigma : real;
      radius : real;
      diff : real;
      k : integer;
      n_0 : constant real := 1.0;
      kappa_1 : constant real := 0.1;
      kappa_2 : constant real := 2.0;
      dom_len : real;
      n_half : real;
      n_max : real;
      two_tol : real;
      ratio : real;
      num : real;
      den : real;
      pow_val : real;
      t1 : real;
      t2 : real;
      abs_fitp : real;
      prod_sign : real;
      loop_cond : boolean;
      res : real;
   begin
      a := a_in;
      b := b_in;
      dom_len := domain_b - domain_a;

      num := a - domain_a;
      u_a := num / dom_len;

      num := b - domain_a;
      u_b := num / dom_len;

      fa := eval_bernstein (coeffs, u_a);
      fb := eval_bernstein (coeffs, u_b);

      two_tol := 2.0 * tol;
      diff := b - a;
      ratio := diff / two_tol;

      if ratio > 1.0 then
         n_half := ada.numerics.elementary_functions.log (ratio, 2.0);
         n_half := real'ceiling (n_half);
      else
         n_half := 0.0;
      end if;

      n_max := n_half + n_0;
      k := 0;

      diff := b - a;
      if diff > two_tol then
         if k < 100 then
            loop_cond := true;
         else
            loop_cond := false;
         end if;
      else
         loop_cond := false;
      end if;

      while loop_cond loop
         t1 := a + b;
         x_half := 0.5 * t1;

         t1 := b * fa;
         t2 := a * fb;
         num := t1 - t2;
         den := fa - fb;
         x_f := num / den;

         diff := b - a;
         pow_val := diff ** kappa_2;
         delta := kappa_1 * pow_val;

         diff := x_half - x_f;
         diff := abs (diff);

         if x_half >= x_f then
            sigma := 1.0;
         else
            sigma := -1.0;
         end if;

         if delta <= diff then
            t1 := sigma * delta;
            x_t := x_f + t1;
         else
            x_t := x_half;
         end if;

         t1 := real (k);
         t2 := n_max - t1;
         pow_val := 2.0 ** t2;
         t1 := pow_val * tol;
         t2 := b - a;
         t2 := 0.5 * t2;
         radius := t1 - t2;

         diff := x_t - x_half;
         diff := abs (diff);

         if diff <= radius then
            x_itp := x_t;
         else
            t1 := sigma * radius;
            x_itp := x_half - t1;
         end if;

         num := x_itp - domain_a;
         u_itp := num / dom_len;
         fitp := eval_bernstein (coeffs, u_itp);

         abs_fitp := abs (fitp);
         if abs_fitp <= 1.0e-14 then
            a := x_itp;
            b := x_itp;
         else
            prod_sign := fa * fitp;
            if prod_sign < 0.0 then
               b := x_itp;
               fb := fitp;
            else
               a := x_itp;
               fa := fitp;
            end if;
         end if;

         k := k + 1;

         diff := b - a;
         if diff > two_tol then
            if k < 100 then
               loop_cond := true;
            else
               loop_cond := false;
            end if;
         else
            loop_cond := false;
         end if;
      end loop;

      t1 := a + b;
      res := 0.5 * t1;
      return res;
   end refine_root_itp;

   procedure isolate_bernstein_roots
     (coeffs     : float_array;
      domain_a   : real;
      domain_b   : real;
      tol        : real;
      roots      : out float_array;
      num_roots  : out integer)
   is
      m : constant integer := coeffs'length - 1;
      eps_filter : real;
      b0 : real;
      b1 : real;
      prod_sign : real;
      den : real;
      u_star : real;
      dom_len : real;
      t1 : real;
      x_star : real;
      i : integer;
      j : integer;
      min_idx : integer;
      temp_r : real;
      num_c : integer;
      c_val : float_array (0 .. 32);
      u_c : real;
      num_d_roots : integer;
      d_roots : float_array (0 .. 32);
      num_d_coeffs : integer;
      val_left : real;
      val_right : real;
      abs_val : real;
   begin
      num_roots := 0;
      eps_filter := compute_error_filter (coeffs);
      dom_len := domain_b - domain_a;

      if m = 1 then
         b0 := coeffs (coeffs'first);
         b1 := coeffs (coeffs'first + 1);
         prod_sign := b0 * b1;
         if prod_sign < 0.0 then
            den := b0 - b1;
            u_star := b0 / den;
            t1 := u_star * dom_len;
            x_star := domain_a + t1;
            roots (roots'first) := x_star;
            num_roots := 1;
         elsif abs (b0) <= eps_filter then
            roots (roots'first) := domain_a;
            num_roots := 1;
         elsif abs (b1) <= eps_filter then
            roots (roots'first) := domain_b;
            num_roots := 1;
         end if;
      else
         num_d_coeffs := m;
         declare
            d_coeffs : float_array (0 .. num_d_coeffs - 1);
         begin
            compute_derivative (coeffs, d_coeffs);
            isolate_bernstein_roots
              (coeffs     => d_coeffs,
               domain_a   => domain_a,
               domain_b   => domain_b,
               tol        => tol,
               roots      => d_roots,
               num_roots  => num_d_roots);
         end;

         -- sort derivative roots
         i := 0;
         while i < num_d_roots - 1 loop
            min_idx := i;
            j := i + 1;
            while j < num_d_roots loop
               if d_roots (j) < d_roots (min_idx) then
                  min_idx := j;
               end if;
               j := j + 1;
            end loop;
            if min_idx /= i then
               temp_r := d_roots (i);
               d_roots (i) := d_roots (min_idx);
               d_roots (min_idx) := temp_r;
            end if;
            i := i + 1;
         end loop;

         -- assemble sub-interval boundaries c_val
         c_val (0) := domain_a;
         i := 0;
         while i < num_d_roots loop
            c_val (i + 1) := d_roots (i);
            i := i + 1;
         end loop;
         num_c := num_d_roots + 1;
         c_val (num_c) := domain_b;

         -- check each sub-interval
         i := 0;
         while i < num_c loop
            t1 := c_val (i) - domain_a;
            u_c := t1 / dom_len;
            val_left := eval_bernstein (coeffs, u_c);

            t1 := c_val (i + 1) - domain_a;
            u_c := t1 / dom_len;
            val_right := eval_bernstein (coeffs, u_c);

            abs_val := abs (val_left);
            if abs_val <= eps_filter then
               if num_roots = 0 then
                  roots (roots'first + num_roots) := c_val (i);
                  num_roots := num_roots + 1;
               else
                  t1 := c_val (i) - roots (roots'first + num_roots - 1);
                  t1 := abs (t1);
                  if t1 > tol then
                     roots (roots'first + num_roots) := c_val (i);
                     num_roots := num_roots + 1;
                  end if;
               end if;
            end if;

            prod_sign := val_left * val_right;
            if prod_sign < 0.0 then
               x_star := refine_root_itp
                 (coeffs   => coeffs,
                  domain_a => domain_a,
                  domain_b => domain_b,
                  a_in     => c_val (i),
                  b_in     => c_val (i + 1),
                  tol      => tol);
               roots (roots'first + num_roots) := x_star;
               num_roots := num_roots + 1;
            end if;

            i := i + 1;
         end loop;

         -- check rightmost boundary
         t1 := domain_b - domain_a;
         u_c := t1 / dom_len;
         val_right := eval_bernstein (coeffs, u_c);
         abs_val := abs (val_right);
         if abs_val <= eps_filter then
            if num_roots > 0 then
               t1 := domain_b - roots (roots'first + num_roots - 1);
               t1 := abs (t1);
               if t1 > tol then
                  roots (roots'first + num_roots) := domain_b;
                  num_roots := num_roots + 1;
               end if;
            else
               roots (roots'first + num_roots) := domain_b;
               num_roots := num_roots + 1;
            end if;
         end if;
      end if;
   end isolate_bernstein_roots;

   test_b : constant float_array (0 .. 3) := (1.0, 2.0, -1.0, 0.0);
   found_roots : float_array (0 .. 10);
   n_found : integer;
   idx_r : integer;
   r_val : real;
begin
   ada.text_io.put_line ("=================================================");
   ada.text_io.put_line (" recursive bernstein derivative-crossing finder ");
   ada.text_io.put_line ("   demonstration in floating-point (ada 2022)   ");
   ada.text_io.put_line ("=================================================");

   isolate_bernstein_roots
     (coeffs    => test_b,
      domain_a  => 0.0,
      domain_b  => 1.0,
      tol       => 1.0e-8,
      roots     => found_roots,
      num_roots => n_found);

   ada.text_io.put ("isolated real roots count: ");
   ada.text_io.put (integer'image (n_found));
   ada.text_io.new_line;

   idx_r := 0;
   while idx_r < n_found loop
      r_val := found_roots (idx_r);
      ada.text_io.put ("  root");
      ada.text_io.put (integer'image (idx_r + 1));
      ada.text_io.put (" = ");
      ada.float_text_io.put (item => float (r_val), fore => 1, aft => 8, exp => 0);
      ada.text_io.new_line;
      idx_r := idx_r + 1;
   end loop;
end bernstein_root_finder;
