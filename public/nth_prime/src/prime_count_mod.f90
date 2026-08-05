module prime_count_mod
  use types_mod, only : i64, r128
  use iso_c_binding, only : c_int64_t
  implicit none
  private
  public :: init_prime_counter, pi_count, pi_small, pi_val, &
            global_primes, global_num_primes

  integer(i64), allocatable, public :: global_primes(:)
  integer(i64), public :: global_num_primes = 0_i64

  interface
    subroutine init_c_prime_counter(max_limit) bind(C, name="init_c_prime_counter")
      import :: c_int64_t
      integer(c_int64_t), value, intent(in) :: max_limit
    end subroutine init_c_prime_counter

    function c_pi_small(y) result(res) bind(C, name="c_pi_small")
      import :: c_int64_t
      integer(c_int64_t), value, intent(in) :: y
      integer(c_int64_t) :: res
    end function c_pi_small

    function c_pi_count(x) result(res) bind(C, name="c_pi_count")
      import :: c_int64_t
      integer(c_int64_t), value, intent(in) :: x
      integer(c_int64_t) :: res
    end function c_pi_count

    function c_pi_val(y) result(res) bind(C, name="c_pi_val")
      import :: c_int64_t
      integer(c_int64_t), value, intent(in) :: y
      integer(c_int64_t) :: res
    end function c_pi_val
  end interface

contains

  subroutine init_prime_counter(max_limit)
    integer(i64), intent(in) :: max_limit
    call init_c_prime_counter(max_limit)
  end subroutine init_prime_counter

  function pi_small(y) result(cnt)
    integer(i64), intent(in) :: y
    integer(i64) :: cnt
    cnt = c_pi_small(y)
  end function pi_small

  function pi_val(y) result(cnt)
    integer(i64), intent(in) :: y
    integer(i64) :: cnt
    cnt = c_pi_val(y)
  end function pi_val

  function pi_count(x) result(res)
    integer(i64), intent(in) :: x
    integer(i64) :: res
    res = c_pi_count(x)
  end function pi_count

end module prime_count_mod
