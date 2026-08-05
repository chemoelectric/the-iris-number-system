module sieve_mod
  use types_mod, only : i64, r128
  use iso_c_binding, only : c_int64_t, c_bool
  implicit none
  private
  public :: sieve_primes, segmented_sieve_count

  interface
    subroutine c_segmented_sieve_count(low_val, high_val, num_small, &
                                       target_offset, base_count, &
                                       result_prime, found) &
               bind(C, name="c_segmented_sieve_count")
      import :: c_int64_t, c_bool
      integer(c_int64_t), value, intent(in) :: low_val, high_val, num_small
      integer(c_int64_t), value, intent(in) :: target_offset, base_count
      integer(c_int64_t), intent(out) :: result_prime
      logical(c_bool), intent(out) :: found
    end subroutine c_segmented_sieve_count
  end interface

contains

  subroutine sieve_primes(limit, primes, num_primes)
    integer(i64), intent(in) :: limit
    integer(i64), allocatable, intent(out) :: primes(:)
    integer(i64), intent(out) :: num_primes
    allocate(primes(0))
    num_primes = 0_i64
  end subroutine sieve_primes

  subroutine segmented_sieve_count(low_val, high_val, small_primes, &
                                   num_small, target_offset, &
                                   base_count, result_prime, found)
    integer(i64), intent(in) :: low_val
    integer(i64), intent(in) :: high_val
    integer(i64), intent(in) :: small_primes(:)
    integer(i64), intent(in) :: num_small
    integer(i64), intent(in) :: target_offset
    integer(i64), intent(in) :: base_count
    integer(i64), intent(out) :: result_prime
    logical, intent(out) :: found
    logical(c_bool) :: c_found

    call c_segmented_sieve_count(low_val, high_val, num_small, &
                                 target_offset, base_count, &
                                 result_prime, c_found)
    found = c_found
  end subroutine segmented_sieve_count

end module sieve_mod
