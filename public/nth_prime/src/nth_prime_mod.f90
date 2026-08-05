module nth_prime_mod
  use types_mod, only : i64, r64
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
    real(r64) :: fn, ln1, ln2, t1, t2, t3, approx

    fn = real(n, kind=r64)
    ln1 = log(fn)
    ln2 = log(ln1)

    t1 = ln1 + ln2 - 1.0_r64
    t2 = (ln2 - 2.0_r64) / ln1
    t3 = (ln2 * ln2 - 6.0_r64 * ln2 + 11.0_r64) / (2.0_r64 * ln1 * ln1)

    approx = fn * (t1 + t2 - t3)
    x0 = int(approx, i64)
  end function estimate_initial_x

  function get_nth_prime(n) result(pn)
    integer(i64), intent(in) :: n
    integer(i64) :: pn
    integer(i64) :: x0, pi0, delta_n, x1, low_bound, high_bound
    integer(i64) :: pi_low, max_sieve_prime, num_small
    real(r64) :: fx0, log_x0, adj
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
      max_sieve_prime = int(sqrt(real(x0 + 100000_i64, kind=r64)) * 2.0_r64, i64)
      if (max_sieve_prime < 100000_i64) then
        max_sieve_prime = 100000_i64
      end if

      call init_prime_counter(max_sieve_prime)

      pi0 = pi_count(x0)
      delta_n = n - pi0

      fx0 = real(x0, kind=r64)
      log_x0 = log(fx0)
      adj = real(delta_n, kind=r64) * log_x0
      x1 = x0 + int(adj, i64)

      low_bound = x1 - 5000_i64
      high_bound = x1 + 5000_i64
      if (low_bound < 2_i64) then
        low_bound = 2_i64
      end if

      found = .false.
      do while (.not. found)
        pi_low = pi_count(low_bound - 1_i64)
        num_small = pi_small(int(sqrt(real(high_bound, kind=r64)), i64))
        call segmented_sieve_count(low_bound, high_bound, global_primes, &
                                   num_small, n, pi_low, pn, found)
        if (.not. found) then
          low_bound = high_bound + 1_i64
          high_bound = high_bound + 10000_i64
        end if
      end do
    end if
  end function get_nth_prime

end module nth_prime_mod
