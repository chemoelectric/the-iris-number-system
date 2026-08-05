module sieve_mod
  use types_mod, only : i64, r128
  implicit none
  private
  public :: sieve_primes, segmented_sieve_count

contains

  subroutine mark_composites(is_prime, limit, sq_lim)
    logical, intent(inout) :: is_prime(:)
    integer(i64), intent(in) :: limit
    integer(i64), intent(in) :: sq_lim
    integer(i64) :: i, j

    i = 2_i64
    do while (i <= sq_lim)
      if (is_prime(i)) then
        j = i * i
        do while (j <= limit)
          is_prime(j) = .false.
          j = j + i
        end do
      end if
      i = i + 1_i64
    end do
  end subroutine mark_composites

  subroutine collect_primes(is_prime, limit, primes, num_primes)
    logical, intent(in) :: is_prime(:)
    integer(i64), intent(in) :: limit
    integer(i64), allocatable, intent(out) :: primes(:)
    integer(i64), intent(out) :: num_primes
    integer(i64) :: i, count

    count = 0_i64
    i = 1_i64
    do while (i <= limit)
      if (is_prime(i)) then
        count = count + 1_i64
      end if
      i = i + 1_i64
    end do

    num_primes = count
    allocate(primes(num_primes))

    count = 0_i64
    i = 1_i64
    do while (i <= limit)
      if (is_prime(i)) then
        count = count + 1_i64
        primes(count) = i
      end if
      i = i + 1_i64
    end do
  end subroutine collect_primes

  subroutine sieve_primes(limit, primes, num_primes)
    integer(i64), intent(in) :: limit
    integer(i64), allocatable, intent(out) :: primes(:)
    integer(i64), intent(out) :: num_primes

    logical, allocatable :: is_prime(:)
    integer(i64) :: sq_lim
    real(r128) :: rlim

    if (limit < 2_i64) then
      num_primes = 0_i64
      allocate(primes(0))
    else
      allocate(is_prime(limit))
      is_prime = .true.
      is_prime(1) = .false.

      rlim = real(limit, kind=r128)
      rlim = sqrt(rlim)
      sq_lim = int(rlim, i64)

      call mark_composites(is_prime, limit, sq_lim)
      call collect_primes(is_prime, limit, primes, num_primes)

      deallocate(is_prime)
    end if
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

    logical, allocatable :: seg(:)
    integer(i64) :: seg_len, i, p, start_val, idx, current_count, cand, p_sq

    found = .false.
    result_prime = high_val
    seg_len = high_val - low_val
    seg_len = seg_len + 1_i64
    allocate(seg(seg_len))
    seg = .true.

    i = 1_i64
    do while (i <= num_small)
      p = small_primes(i)
      p_sq = p * p
      if (p_sq > high_val) then
        i = num_small + 1_i64
      else
        start_val = low_val + p
        start_val = start_val - 1_i64
        start_val = start_val / p
        start_val = start_val * p
        if (start_val < p_sq) then
          start_val = p_sq
        end if
        idx = start_val - low_val
        idx = idx + 1_i64
        do while (idx <= seg_len)
          seg(idx) = .false.
          idx = idx + p
        end do
        i = i + 1_i64
      end if
    end do

    current_count = base_count
    idx = 1_i64
    do while (idx <= seg_len)
      cand = low_val + idx
      cand = cand - 1_i64
      if (cand > 1_i64) then
        if (seg(idx)) then
          current_count = current_count + 1_i64
          if (current_count == target_offset) then
            result_prime = cand
            found = .true.
            idx = seg_len + 1_i64
          end if
        end if
      end if
      idx = idx + 1_i64
    end do

    deallocate(seg)
  end subroutine segmented_sieve_count

end module sieve_mod
