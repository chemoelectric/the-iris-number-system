! nth_prime_64.f90 - Fortran 2023 64-bit hardware integer nth-prime
! engine implementing fast Lehmer prime counting, modular wheel base
! cases, memoized recursion, and bit-packed segmented window extraction.

module nth_prime_64_mod
  use, intrinsic :: iso_fortran_env, only : int64, real64, real128, &
                                            input_unit, output_unit
  implicit none
  private
  public :: get_nth_prime_u64, get_nth_prime_str

  integer, parameter :: i64 = int64
  integer, parameter :: r64 = real64
  integer, parameter :: r128 = real128

  integer(i64), parameter :: CACHE_SIZE = 1048576_i64
  integer(i64), parameter :: CACHE_MASK = 1048575_i64

  integer(i64) :: g_memo_x(0:CACHE_SIZE-1) = 0_i64
  integer(i64) :: g_memo_a(0:CACHE_SIZE-1) = 0_i64
  integer(i64) :: g_memo_res(0:CACHE_SIZE-1) = 0_i64

  integer(i64) :: g_phi6_table(0:30029)
  logical :: g_phi6_initialized = .false.

  integer(i64), allocatable :: g_is_subprime_bit(:)
  integer(i64), allocatable :: g_popcnt_block(:)
  integer(i64) :: g_sieve_max = 0_i64

contains

  pure function is_coprime_to_30030(i_val) result(res)
    integer(i64), intent(in) :: i_val
    logical :: res
    res = .true.
    if (modulo(i_val, 2_i64) == 0_i64) then
      res = .false.
    else if (modulo(i_val, 3_i64) == 0_i64) then
      res = .false.
    else if (modulo(i_val, 5_i64) == 0_i64) then
      res = .false.
    else if (modulo(i_val, 7_i64) == 0_i64) then
      res = .false.
    else if (modulo(i_val, 11_i64) == 0_i64) then
      res = .false.
    else if (modulo(i_val, 13_i64) == 0_i64) then
      res = .false.
    end if
  end function is_coprime_to_30030

  subroutine init_phi6_table()
    integer(i64) :: running, i_val
    if (.not. g_phi6_initialized) then
      running = 0_i64
      i_val = 1_i64
      do while (i_val <= 30030_i64)
        if (is_coprime_to_30030(i_val)) then
          running = running + 1_i64
        end if
        g_phi6_table(i_val - 1_i64) = running
        i_val = i_val + 1_i64
      end do
      g_phi6_initialized = .true.
    end if
  end subroutine init_phi6_table

  pure function phi6(x_val) result(ans)
    integer(i64), intent(in) :: x_val
    integer(i64) :: ans, q_val, r_val
    q_val = x_val / 30030_i64
    r_val = modulo(x_val, 30030_i64)
    ans = q_val * 5760_i64
    if (r_val > 0_i64) then
      ans = ans + g_phi6_table(r_val - 1_i64)
    end if
  end function phi6

  subroutine build_bit_sieve(limit)
    integer(i64), intent(in) :: limit
    integer(i64) :: num_odds, num_words, i_val, i_odd, w_idx, b_idx
    integer(i64) :: i2_val, j_val, j_odd, jw, jb, w_val, total, w_iter
    integer(i64) :: sqrt_lim, mask, clr_mask

    if (limit <= g_sieve_max .and. allocated(g_is_subprime_bit)) then
      return
    end if

    if (allocated(g_is_subprime_bit)) deallocate(g_is_subprime_bit)
    if (allocated(g_popcnt_block)) deallocate(g_popcnt_block)

    g_sieve_max = limit
    num_odds = (limit / 2_i64) + 1_i64
    num_words = (num_odds + 63_i64) / 64_i64
    if (num_words == 0_i64) num_words = 1_i64

    allocate(g_is_subprime_bit(0:num_words-1))
    allocate(g_popcnt_block(0:num_words-1))

    g_is_subprime_bit = -1_i64  ! all 1-bits in two's complement
    g_is_subprime_bit(0) = iand(g_is_subprime_bit(0), not(1_i64))

    sqrt_lim = int(sqrt(real(limit, kind=r128)), kind=i64)
    i_val = 3_i64
    do while (i_val <= sqrt_lim)
      i_odd = i_val / 2_i64
      w_idx = i_odd / 64_i64
      b_idx = iand(i_odd, 63_i64)
      mask = ishft(1_i64, int(b_idx))
      w_val = iand(g_is_subprime_bit(w_idx), mask)
      if (w_val /= 0_i64) then
        i2_val = i_val * 2_i64
        j_val = i_val * i_val
        do while (j_val <= limit)
          j_odd = j_val / 2_i64
          jw = j_odd / 64_i64
          jb = iand(j_odd, 63_i64)
          clr_mask = not(ishft(1_i64, int(jb)))
          g_is_subprime_bit(jw) = iand(g_is_subprime_bit(jw), clr_mask)
          j_val = j_val + i2_val
        end do
      end if
      i_val = i_val + 2_i64
    end do

    total = 0_i64
    w_iter = 0_i64
    do while (w_iter < num_words)
      g_popcnt_block(w_iter) = total
      total = total + int(popcnt(g_is_subprime_bit(w_iter)), kind=i64)
      w_iter = w_iter + 1_i64
    end do
  end subroutine build_bit_sieve

  function pi_fast(x_val, primes) result(res)
    integer(i64), intent(in) :: x_val
    integer(i64), intent(in), optional :: primes(:)
    integer(i64) :: res, odd_idx, w_idx, b_idx, count_val, word_val
    integer(i64) :: mask, masked, low_idx, high_idx, mid_idx, p_mid

    if (x_val < 2_i64) then
      res = 0_i64
    else if (x_val <= g_sieve_max .and. allocated(g_is_subprime_bit)) then
      odd_idx = x_val / 2_i64
      w_idx = odd_idx / 64_i64
      b_idx = iand(odd_idx, 63_i64)
      count_val = g_popcnt_block(w_idx)
      word_val = g_is_subprime_bit(w_idx)
      if (b_idx < 63_i64) then
        mask = ishft(1_i64, int(b_idx + 1_i64)) - 1_i64
      else
        mask = -1_i64
      end if
      masked = iand(word_val, mask)
      count_val = count_val + int(popcnt(masked), kind=i64)
      res = count_val + 1_i64  ! include prime 2
    else if (present(primes)) then
      low_idx = 1_i64
      high_idx = int(size(primes), kind=i64) + 1_i64
      do while (low_idx < high_idx)
        mid_idx = (low_idx + high_idx) / 2_i64
        p_mid = primes(mid_idx)
        if (p_mid <= x_val) then
          low_idx = mid_idx + 1_i64
        else
          high_idx = mid_idx
        end if
      end do
      res = low_idx - 1_i64
    else
      res = 0_i64
    end if
  end function pi_fast

  recursive function phi_memoized(x_val, a_val, primes) &
    result(res)
    integer(i64), intent(in) :: x_val, a_val
    integer(i64), intent(in) :: primes(:)
    integer(i64) :: res, key, slot, p_val, left_val, right_val

    key = ieor(x_val, a_val * 1140071481932319848_i64)
    slot = iand(key, CACHE_MASK)

    if (g_memo_x(slot) == x_val .and. g_memo_a(slot) == a_val) then
      res = g_memo_res(slot)
      return
    end if

    if (a_val <= 6_i64) then
      res = phi6(x_val)
    else if (x_val == 0_i64) then
      res = 0_i64
    else if (a_val == 0_i64) then
      res = x_val
    else if (a_val > int(size(primes), kind=i64)) then
      res = 1_i64
    else
      p_val = primes(a_val)
      if (x_val < p_val) then
        res = 1_i64
      else
        left_val = phi_rec(x_val, a_val - 1_i64, primes)
        right_val = phi_rec(x_val / p_val, a_val - 1_i64, primes)
        res = left_val - right_val
      end if
    end if

    g_memo_x(slot) = x_val
    g_memo_a(slot) = a_val
    g_memo_res(slot) = res
  end function phi_memoized

  recursive function phi_rec(x_val, a_val, primes) result(res)
    integer(i64), intent(in) :: x_val, a_val
    integer(i64), intent(in) :: primes(:)
    integer(i64) :: res, p_val, left_val, right_val

    if (a_val <= 6_i64) then
      if (a_val == 6_i64) then
        res = phi6(x_val)
      else if (a_val == 0_i64) then
        res = x_val
      else if (a_val == 1_i64) then
        res = x_val - (x_val / 2_i64)
      else if (a_val == 2_i64) then
        res = x_val - (x_val / 2_i64) - (x_val / 3_i64) + (x_val / 6_i64)
      else
        p_val = primes(a_val)
        left_val = phi_rec(x_val, a_val - 1_i64, primes)
        right_val = phi_rec(x_val / p_val, a_val - 1_i64, primes)
        res = left_val - right_val
      end if
    else
      res = phi_memoized(x_val, a_val, primes)
    end if
  end function phi_rec

  function lehmer_sum2(x_val, a_val, b_val, c_val, primes) result(res)
    integer(i64), intent(in) :: x_val, a_val, b_val, c_val
    integer(i64), intent(in) :: primes(:)
    integer(i64) :: res, p2, p3, i_idx, j_idx, p_i, p_j, w_val
    integer(i64) :: pi_w, pi_w2, sqrt_w, bi_val

    p2 = 0_i64
    i_idx = a_val + 1_i64
    do while (i_idx <= b_val)
      p_i = primes(i_idx)
      w_val = x_val / p_i
      pi_w = pi_fast(w_val, primes)
      p2 = p2 + (pi_w - (i_idx - 1_i64))
      i_idx = i_idx + 1_i64
    end do

    p3 = 0_i64
    i_idx = a_val + 1_i64
    do while (i_idx <= c_val)
      p_i = primes(i_idx)
      w_val = x_val / p_i
      sqrt_w = int(sqrt(real(w_val, kind=r128)), kind=i64)
      bi_val = pi_fast(sqrt_w, primes)
      j_idx = i_idx
      do while (j_idx <= bi_val)
        p_j = primes(j_idx)
        pi_w2 = pi_fast(w_val / p_j, primes)
        p3 = p3 + (pi_w2 - (j_idx - 1_i64))
        j_idx = j_idx + 1_i64
      end do
      i_idx = i_idx + 1_i64
    end do

    res = p2 + p3
  end function lehmer_sum2

  function prime_count_lehmer(x_val, primes) result(count_val)
    integer(i64), intent(in) :: x_val
    integer(i64), intent(in) :: primes(:)
    integer(i64) :: count_val, a_val, b_val, c_val, phi_val, sum_p2_p3
    real(r128) :: fx, sq_x, sq_sq_x, cb_x

    if (x_val < 2_i64) then
      count_val = 0_i64
    else if (x_val <= g_sieve_max) then
      count_val = pi_fast(x_val, primes)
    else
      fx = real(x_val, kind=r128)
      sq_x = sqrt(fx)
      sq_sq_x = sqrt(sq_x)
      a_val = pi_fast(int(sq_sq_x, kind=i64), primes)
      b_val = pi_fast(int(sq_x, kind=i64), primes)

      cb_x = fx ** (1.0_r128 / 3.0_r128)
      c_val = pi_fast(int(cb_x, kind=i64), primes)

      phi_val = phi_rec(x_val, a_val, primes)
      sum_p2_p3 = lehmer_sum2(x_val, a_val, b_val, c_val, primes)
      count_val = (phi_val + a_val - 1_i64) - sum_p2_p3
    end if
  end function prime_count_lehmer

  function sieve_segment_find_nth(low_val, high_val, base_primes, &
                                  target_n, start_pi) result(result_prime)
    integer(i64), intent(in) :: low_val, high_val, target_n, start_pi
    integer(i64), intent(in) :: base_primes(:)
    integer(i64) :: result_prime, range_diff, range_len, num_words
    integer(i64) :: idx, base_count, p_val, p_sq, start_val, diff_s
    integer(i64) :: w_idx, b_idx, mask, clr_mask, val, diff_v, is_p
    integer(i64) :: current_count
    integer(i64), allocatable :: sieve(:)

    range_diff = high_val - low_val
    range_len = range_diff + 1_i64
    num_words = (range_len + 63_i64) / 64_i64
    if (num_words == 0_i64) num_words = 1_i64

    allocate(sieve(0:num_words-1))
    sieve = -1_i64

    base_count = int(size(base_primes), kind=i64)
    idx = 1_i64
    do while (idx <= base_count)
      p_val = base_primes(idx)
      p_sq = p_val * p_val
      if (p_sq > high_val) then
        idx = base_count + 1_i64
      else
        start_val = ((low_val + p_val - 1_i64) / p_val) * p_val
        if (start_val < p_sq) start_val = p_sq
        do while (start_val <= high_val)
          diff_s = start_val - low_val
          w_idx = diff_s / 64_i64
          b_idx = iand(diff_s, 63_i64)
          clr_mask = not(ishft(1_i64, int(b_idx)))
          sieve(w_idx) = iand(sieve(w_idx), clr_mask)
          start_val = start_val + p_val
        end do
        idx = idx + 1_i64
      end if
    end do

    current_count = start_pi
    result_prime = 0_i64
    val = low_val
    do while (val <= high_val)
      diff_v = val - low_val
      w_idx = diff_v / 64_i64
      b_idx = iand(diff_v, 63_i64)
      mask = ishft(1_i64, int(b_idx))
      is_p = iand(sieve(w_idx), mask)
      if (is_p /= 0_i64) then
        current_count = current_count + 1_i64
        if (current_count == target_n) then
          result_prime = val
          val = high_val  ! exit loop
        end if
      end if
      val = val + 1_i64
    end do
    deallocate(sieve)
  end function sieve_segment_find_nth

  function sieve_segment_find_backward(low_val, high_val, base_primes, &
                                       target_n, start_pi) result(result_prime)
    integer(i64), intent(in) :: low_val, high_val, target_n, start_pi
    integer(i64), intent(in) :: base_primes(:)
    integer(i64) :: result_prime, range_diff, range_len, num_words
    integer(i64) :: idx, base_count, p_val, p_sq, start_val, diff_s
    integer(i64) :: w_idx, b_idx, mask, clr_mask, val, diff_v, is_p
    integer(i64) :: current_count
    integer(i64), allocatable :: sieve(:)

    range_diff = high_val - low_val
    range_len = range_diff + 1_i64
    num_words = (range_len + 63_i64) / 64_i64
    if (num_words == 0_i64) num_words = 1_i64

    allocate(sieve(0:num_words-1))
    sieve = -1_i64

    base_count = int(size(base_primes), kind=i64)
    idx = 1_i64
    do while (idx <= base_count)
      p_val = base_primes(idx)
      p_sq = p_val * p_val
      if (p_sq > high_val) then
        idx = base_count + 1_i64
      else
        start_val = ((low_val + p_val - 1_i64) / p_val) * p_val
        if (start_val < p_sq) start_val = p_sq
        do while (start_val <= high_val)
          diff_s = start_val - low_val
          w_idx = diff_s / 64_i64
          b_idx = iand(diff_s, 63_i64)
          clr_mask = not(ishft(1_i64, int(b_idx)))
          sieve(w_idx) = iand(sieve(w_idx), clr_mask)
          start_val = start_val + p_val
        end do
        idx = idx + 1_i64
      end if
    end do

    current_count = start_pi
    result_prime = 0_i64
    val = high_val
    do while (val >= low_val)
      diff_v = val - low_val
      w_idx = diff_v / 64_i64
      b_idx = iand(diff_v, 63_i64)
      mask = ishft(1_i64, int(b_idx))
      is_p = iand(sieve(w_idx), mask)
      if (is_p /= 0_i64) then
        if (current_count == target_n) then
          result_prime = val
          val = low_val  ! exit
        end if
        current_count = current_count - 1_i64
      end if
      val = val - 1_i64
    end do
    deallocate(sieve)
  end function sieve_segment_find_backward

  function estimate_initial_x(n) result(x0)
    integer(i64), intent(in) :: n
    integer(i64) :: x0
    real(r128) :: fn, log_n, log_log, t2, t3, num3, den3, bracket

    fn = real(n, kind=r128)
    log_n = log(fn)
    log_log = log(log_n)

    t2 = (log_log - 2.0_r128) / log_n
    num3 = (log_log * log_log) - (6.0_r128 * log_log) + 11.0_r128
    den3 = 2.0_r128 * log_n * log_n
    t3 = num3 / den3

    bracket = log_n + log_log - 1.0_r128 + t2 - t3
    x0 = int(fn * bracket, kind=i64)
  end function estimate_initial_x

  function nth_prime_refine(n_val, curr_x_in, base_primes) result(pn)
    integer(i64), intent(in) :: n_val, curr_x_in
    integer(i64), intent(in) :: base_primes(:)
    integer(i64) :: pn, curr_x, curr_pi, diff_n, abs_diff, window
    integer(i64) :: low_val, high_val, step_val
    real(r128) :: f_x, log_x, f_diff, est_w

    curr_x = curr_x_in
    curr_pi = prime_count_lehmer(curr_x, base_primes)
    diff_n = n_val - curr_pi

    do while (diff_n > 2000_i64 .or. diff_n < -2000_i64)
      f_x = real(curr_x, kind=r128)
      log_x = log(f_x)
      f_diff = real(diff_n, kind=r128)
      step_val = int(f_diff * log_x, kind=i64)
      curr_x = curr_x + step_val
      curr_pi = prime_count_lehmer(curr_x, base_primes)
      diff_n = n_val - curr_pi
    end do

    if (diff_n < 0_i64) then
      abs_diff = -diff_n
    else
      abs_diff = diff_n
    end if

    f_x = real(curr_x, kind=r128)
    log_x = log(f_x)
    est_w = real(abs_diff, kind=r128) * log_x * 2.5_r128
    window = int(est_w, kind=i64) + 1000_i64
    if (window < 2000_i64) window = 2000_i64

    if (diff_n > 0_i64) then
      low_val = curr_x + 1_i64
      high_val = curr_x + window
      pn = sieve_segment_find_nth(low_val, high_val, base_primes, &
                                  n_val, curr_pi)
    else
      low_val = 2_i64
      if (curr_x > window) low_val = curr_x - window
      pn = sieve_segment_find_backward(low_val, curr_x, base_primes, &
                                       n_val, curr_pi)
    end if
  end function nth_prime_refine

  function get_nth_prime_u64(n_val) result(pn)
    integer(i64), intent(in) :: n_val
    integer(i64) :: pn, curr_x, z_val, sieve_limit, z_plus, pi_z
    integer(i64) :: cand, cand_odd, w_idx, b_idx, mask, is_p, count_p
    integer(i64), allocatable :: base_primes(:)
    real(r128) :: fx, sq_x

    if (n_val == 0_i64) then
      pn = 0_i64
    else if (n_val == 1_i64) then
      pn = 2_i64
    else if (n_val == 2_i64) then
      pn = 3_i64
    else if (n_val == 3_i64) then
      pn = 5_i64
    else if (n_val == 4_i64) then
      pn = 7_i64
    else if (n_val == 5_i64) then
      pn = 11_i64
    else
      curr_x = estimate_initial_x(n_val)
      fx = real(curr_x, kind=r128)
      sq_x = sqrt(fx)
      z_val = int(sq_x, kind=i64)

      sieve_limit = z_val * 12_i64
      if (sieve_limit < 1000000_i64) sieve_limit = 1000000_i64
      if (curr_x <= 20000000_i64 .and. sieve_limit < curr_x) then
        sieve_limit = curr_x
      end if

      call build_bit_sieve(sieve_limit)
      z_plus = z_val + 1000_i64
      pi_z = pi_fast(z_plus)
      allocate(base_primes(1:pi_z + 1000_i64))

      base_primes(1) = 2_i64
      count_p = 1_i64
      cand = 3_i64
      do while (cand <= z_plus)
        cand_odd = cand / 2_i64
        w_idx = cand_odd / 64_i64
        b_idx = iand(cand_odd, 63_i64)
        mask = ishft(1_i64, int(b_idx))
        is_p = iand(g_is_subprime_bit(w_idx), mask)
        if (is_p /= 0_i64) then
          count_p = count_p + 1_i64
          base_primes(count_p) = cand
        end if
        cand = cand + 2_i64
      end do

      call init_phi6_table()
      g_memo_x = 0_i64

      pn = nth_prime_refine(n_val, curr_x, base_primes(1:count_p))
      deallocate(base_primes)
    end if
  end function get_nth_prime_u64

  subroutine get_nth_prime_str(n_str, out_str)
    character(len=*), intent(in) :: n_str
    character(len=*), intent(out) :: out_str
    integer(i64) :: n_val, digit, res_prime
    integer :: i_idx, len_s
    character :: ch

    n_val = 0_i64
    len_s = len_trim(n_str)
    i_idx = 1
    do while (i_idx <= len_s)
      ch = n_str(i_idx:i_idx)
      if (ch >= '0' .and. ch <= '9') then
        digit = int(ichar(ch) - ichar('0'), kind=i64)
        n_val = (n_val * 10_i64) + digit
      end if
      i_idx = i_idx + 1
    end do

    res_prime = get_nth_prime_u64(n_val)
    write(out_str, '(i0)') res_prime
  end subroutine get_nth_prime_str

end module nth_prime_64_mod
