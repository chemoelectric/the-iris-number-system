module nth_prime_mod
  use types_mod, only : i64, r128
  use sieve_mod, only : segmented_sieve_count
  use prime_count_mod, only : init_prime_counter, pi_count, pi_small, &
                              global_primes, global_num_primes
  implicit none
  private
  public :: get_nth_prime

contains

  function estimate_initial_x(n) result(x0)
    integer(i64), intent(in) :: n
    integer(i64) :: x0
    real(r128) :: fn, ln1, ln2, t1, t2, t3, approx, ln2_sq, ln1_sq, num2, den2

    fn = real(n, kind=r128)
    ln1 = log(fn)
    ln2 = log(ln1)

    t1 = ln1 + ln2
    t1 = t1 - 1.0_r128

    t2 = ln2 - 2.0_r128
    t2 = t2 / ln1

    ln2_sq = ln2 * ln2
    ln1_sq = ln1 * ln1
    num2 = 6.0_r128 * ln2
    num2 = ln2_sq - num2
    num2 = num2 + 11.0_r128
    den2 = 2.0_r128 * ln1_sq
    t3 = num2 / den2

    approx = t1 + t2
    approx = approx - t3
    approx = fn * approx
    x0 = int(approx, i64)
  end function estimate_initial_x

  function get_nth_prime(n) result(pn)
    integer(i64), intent(in) :: n
    integer(i64) :: pn
    integer(i64) :: x0, pi0, delta_n, x1, low_bound, high_bound
    integer(i64) :: pi_low, max_sieve_prime, num_small, range_len, step_size
    real(r128) :: fx0, log_x0, adj, rx0, lx0_23
    logical :: found

    if (n == 1_i64) then
      pn = 2_i64
    else if (n == 2_i64) then
      pn = 3_i64
    else if (n == 3_i64) then
      pn = 5_i64
    else if (n == 4_i64) then
      pn = 7_i64
    else if (n == 5_i64) then
      pn = 11_i64
    else
      x0 = estimate_initial_x(n)

      rx0 = real(x0, kind=r128)
      lx0_23 = log(rx0)
      lx0_23 = lx0_23 * 0.6666666666666666666666666666666666_r128
      max_sieve_prime = int(exp(lx0_23), i64)
      max_sieve_prime = max_sieve_prime + 10000_i64
      if (max_sieve_prime < 100000_i64) then
        max_sieve_prime = 100000_i64
      end if
      if (max_sieve_prime > 2000000000_i64) then
        max_sieve_prime = 2000000000_i64
      end if

      call init_prime_counter(max_sieve_prime)

      pi0 = pi_count(x0)
      delta_n = n - pi0

      fx0 = real(x0, kind=r128)
      log_x0 = log(fx0)
      adj = real(delta_n, kind=r128)
      adj = adj * log_x0
      x1 = x0 + int(adj, i64)

      step_size = 10000_i64
      low_bound = x1 - 5000_i64
      high_bound = x1 + 5000_i64
      if (low_bound < 2_i64) then
        low_bound = 2_i64
      end if

      found = .false.
      do while (.not. found)
        range_len = low_bound - 1_i64
        pi_low = pi_count(range_len)

        if (n < pi_low) then
          adj = real(pi_low - n, kind=r128)
          adj = adj * log(real(low_bound, kind=r128))
          step_size = max(10000_i64, int(adj, i64) + 1000_i64)
          high_bound = low_bound - 1_i64
          low_bound = high_bound - step_size + 1_i64
          if (low_bound < 2_i64) then
            low_bound = 2_i64
          end if
        else
          rx0 = real(high_bound, kind=r128)
          rx0 = sqrt(rx0)
          num_small = pi_small(int(rx0, i64))
          call segmented_sieve_count(low_bound, high_bound, global_primes, &
                                     num_small, n, pi_low, pn, found)
          if (.not. found) then
            adj = real(n - pi_low, kind=r128)
            adj = adj * log(real(high_bound, kind=r128))
            step_size = max(10000_i64, int(adj, i64) + 1000_i64)
            low_bound = high_bound + 1_i64
            high_bound = low_bound + step_size - 1_i64
          end if
        end if
      end do
    end if
  end function get_nth_prime

end module nth_prime_mod
