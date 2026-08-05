module prime_count_mod
  use types_mod, only : i64
  use sieve_mod, only : sieve_primes
  implicit none
  private
  public :: init_prime_counter, pi_count, pi_small, &
            global_primes, global_num_primes

  integer(i64), allocatable :: global_primes(:)
  integer(i64) :: global_num_primes = 0_i64

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
    integer(i64) :: low_idx, high_idx, mid_idx, ans

    if (y < 2_i64) then
      cnt = 0_i64
    else if (global_num_primes > 0_i64) then
      if (y >= global_primes(global_num_primes)) then
        cnt = global_num_primes
      else
        low_idx = 1_i64
        high_idx = global_num_primes
        ans = 0_i64
        do while (low_idx <= high_idx)
          mid_idx = (low_idx + high_idx) / 2_i64
          if (global_primes(mid_idx) <= y) then
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

  recursive function phi_recursive(x, a) result(val)
    integer(i64), intent(in) :: x
    integer(i64), intent(in) :: a
    integer(i64) :: val
    integer(i64) :: h_idx, p_a, v1, v2
    logical :: found_cached

    if (x == 0_i64) then
      val = 0_i64
    else if (a == 0_i64) then
      val = x
    else if (a == 1_i64) then
      val = x - (x / 2_i64)
    else
      p_a = global_primes(a)
      if (x < p_a) then
        val = 1_i64
      else
        found_cached = .false.
        if (a <= 100_i64) then
          h_idx = mod(x * 10007_i64 + a, hash_size) + 1_i64
          if (cache_x(h_idx) == x) then
            if (cache_a(h_idx) == a) then
              val = cache_v(h_idx)
              found_cached = .true.
            end if
          end if
        else
          h_idx = -1_i64
        end if

        if (.not. found_cached) then
          v1 = phi_recursive(x, a - 1_i64)
          v2 = phi_recursive(x / p_a, a - 1_i64)
          val = v1 - v2

          if (h_idx > 0_i64) then
            cache_x(h_idx) = x
            cache_a(h_idx) = a
            cache_v(h_idx) = val
          end if
        end if
      end if
    end if
  end function phi_recursive

  function pi_count(x) result(res)
    integer(i64), intent(in) :: x
    integer(i64) :: res
    integer(i64) :: x_cbrt, x_sqrt, a_idx, b_idx, p2_sum, i, p_i, y, pi_y

    if (x < 2_i64) then
      res = 0_i64
    else if (x <= global_primes(global_num_primes)) then
      res = pi_small(x)
    else
      call clear_phi_cache()

      x_cbrt = int(exp(log(real(x, kind=8)) / 3.0_8), i64)
      if ((x_cbrt + 1_i64)**3_i64 <= x) then
        x_cbrt = x_cbrt + 1_i64
      end if

      x_sqrt = int(sqrt(real(x, kind=8)), i64)

      a_idx = pi_small(x_cbrt)
      b_idx = pi_small(x_sqrt)

      p2_sum = 0_i64
      i = a_idx + 1_i64
      do while (i <= b_idx)
        p_i = global_primes(i)
        y = x / p_i
        pi_y = pi_small(y)
        p2_sum = p2_sum + (pi_y - i + 1_i64)
        i = i + 1_i64
      end do

      res = phi_recursive(x, a_idx)
      res = res + a_idx - 1_i64 - p2_sum
    end if
  end function pi_count

end module prime_count_mod
