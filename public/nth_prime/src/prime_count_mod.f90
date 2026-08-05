module prime_count_mod
  use types_mod, only : i64
  use sieve_mod, only : sieve_primes
  implicit none
  private
  public :: init_prime_counter, pi_count, pi_small, &
            global_primes, global_num_primes

  integer(i64), allocatable, public :: global_primes(:)
  integer(i64), public :: global_num_primes = 0_i64

  integer(i64), parameter :: hash_size = 131072_i64
  integer(i64) :: cache_x(131072)
  integer(i64) :: cache_a(131072)
  integer(i64) :: cache_v(131072)

contains

  subroutine init_prime_counter(max_limit)
    integer(i64), intent(in) :: max_limit
    if (allocated(global_primes)) then
      deallocate(global_primes)
    end if
    call sieve_primes(max_limit, global_primes, global_num_primes)
  end subroutine init_prime_counter

  function pi_small(y) result(cnt)
    integer(i64), intent(in) :: y
    integer(i64) :: cnt
    integer(i64) :: low_idx, high_idx, mid_idx, ans, p_mid, sum_idx

    if (y < 2_i64) then
      cnt = 0_i64
    else if (global_num_primes > 0_i64) then
      p_mid = global_primes(global_num_primes)
      if (y >= p_mid) then
        cnt = global_num_primes
      else
        low_idx = 1_i64
        high_idx = global_num_primes
        ans = 0_i64
        do while (low_idx <= high_idx)
          sum_idx = low_idx + high_idx
          mid_idx = sum_idx / 2_i64
          p_mid = global_primes(mid_idx)
          if (p_mid <= y) then
            ans = mid_idx
            low_idx = mid_idx + 1_i64
          else
            high_idx = mid_idx - 1_i64
          end if
        end do
        cnt = ans
      end if
    else
      cnt = 0_i64
    end if
  end function pi_small

  subroutine clear_phi_cache()
    integer(i64) :: i
    i = 1_i64
    do while (i <= hash_size)
      cache_x(i) = -1_i64
      cache_a(i) = -1_i64
      cache_v(i) = -1_i64
      i = i + 1_i64
    end do
  end subroutine clear_phi_cache

  subroutine check_cache(x, a, val, found, h_idx)
    integer(i64), intent(in) :: x
    integer(i64), intent(in) :: a
    integer(i64), intent(out) :: val
    logical, intent(out) :: found
    integer(i64), intent(out) :: h_idx
    integer(i64) :: temp_val

    found = .false.
    val = 0_i64
    if (a <= 100_i64) then
      temp_val = x * 10007_i64
      temp_val = temp_val + a
      h_idx = mod(temp_val, hash_size)
      h_idx = h_idx + 1_i64
      if (cache_x(h_idx) == x) then
        if (cache_a(h_idx) == a) then
          val = cache_v(h_idx)
          found = .true.
        end if
      end if
    else
      h_idx = -1_i64
    end if
  end subroutine check_cache

  subroutine store_cache(x, a, val, h_idx)
    integer(i64), intent(in) :: x
    integer(i64), intent(in) :: a
    integer(i64), intent(in) :: val
    integer(i64), intent(in) :: h_idx

    if (h_idx > 0_i64) then
      cache_x(h_idx) = x
      cache_a(h_idx) = a
      cache_v(h_idx) = val
    end if
  end subroutine store_cache

  recursive function phi_recursive(x, a) result(val)
    integer(i64), intent(in) :: x
    integer(i64), intent(in) :: a
    integer(i64) :: val
    integer(i64) :: h_idx, p_a, p_a_sq, v1, v2, a_prev, x_div, pi_x, temp_val
    logical :: found_cached

    if (x == 0_i64) then
      val = 0_i64
    else if (a == 0_i64) then
      val = x
    else if (a == 1_i64) then
      x_div = x / 2_i64
      val = x - x_div
    else
      p_a = global_primes(a)
      if (x < p_a) then
        val = 1_i64
      else
        p_a_sq = p_a * p_a
        if (x < p_a_sq) then
          pi_x = pi_small(x)
          temp_val = pi_x - a
          val = temp_val + 1_i64
        else
          call check_cache(x, a, val, found_cached, h_idx)
          if (.not. found_cached) then
            a_prev = a - 1_i64
            v1 = phi_recursive(x, a_prev)
            x_div = x / p_a
            v2 = phi_recursive(x_div, a_prev)
            val = v1 - v2
            call store_cache(x, a, val, h_idx)
          end if
        end if
      end if
    end if
  end function phi_recursive

  function pi_count(x) result(res)
    integer(i64), intent(in) :: x
    integer(i64) :: res
    integer(i64) :: x_cbrt, x_sqrt, a_idx, b_idx, p2_sum, i, p_i, y, pi_y
    integer(i64) :: cbrt_plus, cbrt_cube, term1, term2
    real(kind=8) :: rx, lx, lx_3

    if (x < 2_i64) then
      res = 0_i64
    else if (x <= global_primes(global_num_primes)) then
      res = pi_small(x)
    else
      call clear_phi_cache()

      rx = real(x, kind=8)
      lx = log(rx)
      lx_3 = lx / 3.0_8
      x_cbrt = int(exp(lx_3), i64)
      cbrt_plus = x_cbrt + 1_i64
      cbrt_cube = cbrt_plus * cbrt_plus
      cbrt_cube = cbrt_cube * cbrt_plus
      if (cbrt_cube <= x) then
        x_cbrt = cbrt_plus
      end if

      rx = sqrt(rx)
      x_sqrt = int(rx, i64)

      a_idx = pi_small(x_cbrt)
      b_idx = pi_small(x_sqrt)

      p2_sum = 0_i64

      !$omp parallel do reduction(+:p2_sum) private(i, p_i, y, pi_y, term1, term2) schedule(dynamic, 64)
      do i = a_idx + 1_i64, b_idx
        p_i = global_primes(i)
        y = x / p_i
        pi_y = pi_small(y)
        term1 = pi_y - i
        term2 = term1 + 1_i64
        p2_sum = p2_sum + term2
      end do
      !$omp end parallel do

      res = phi_recursive(x, a_idx)
      res = res + a_idx
      res = res - 1_i64
      res = res - p2_sum
    end if
  end function pi_count

end module prime_count_mod
