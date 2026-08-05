module sieve_mod
  use types_mod, only : i64, r128
  implicit none
  private
  public :: sieve_primes, segmented_sieve_count

contains

  subroutine mark_odd_composites(is_odd_prime, num_odds, sq_lim)
    logical, intent(inout) :: is_odd_prime(:)
    integer(i64), intent(in) :: num_odds
    integer(i64), intent(in) :: sq_lim
    integer(i64) :: k, p, idx, k_plus_1, prod_k

    k = 1_i64
    p = 3_i64
    do while (p <= sq_lim)
      if (is_odd_prime(k)) then
        k_plus_1 = k + 1_i64
        prod_k = k * k_plus_1
        idx = 2_i64 * prod_k
        do while (idx <= num_odds)
          is_odd_prime(idx) = .false.
          idx = idx + p
        end do
      end if
      k = k + 1_i64
      p = 2_i64 * k
      p = p + 1_i64
    end do
  end subroutine mark_odd_composites

  subroutine collect_odd_primes(is_odd_prime, num_odds, primes, num_primes)
    logical, intent(in) :: is_odd_prime(:)
    integer(i64), intent(in) :: num_odds
    integer(i64), allocatable, intent(out) :: primes(:)
    integer(i64), intent(out) :: num_primes
    integer(i64) :: k, count, p

    count = 1_i64
    k = 1_i64
    do while (k <= num_odds)
      if (is_odd_prime(k)) then
        count = count + 1_i64
      end if
      k = k + 1_i64
    end do

    num_primes = count
    allocate(primes(num_primes))

    primes(1) = 2_i64
    count = 1_i64
    k = 1_i64
    do while (k <= num_odds)
      if (is_odd_prime(k)) then
        count = count + 1_i64
        p = 2_i64 * k
        p = p + 1_i64
        primes(count) = p
      end if
      k = k + 1_i64
    end do
  end subroutine collect_odd_primes

  subroutine sieve_primes(limit, primes, num_primes)
    integer(i64), intent(in) :: limit
    integer(i64), allocatable, intent(out) :: primes(:)
    integer(i64), intent(out) :: num_primes

    logical, allocatable :: is_odd_prime(:)
    integer(i64) :: sq_lim, num_odds, lim_minus_1
    real(r128) :: rlim

    if (limit < 2_i64) then
      num_primes = 0_i64
      allocate(primes(0))
    else if (limit == 2_i64) then
      num_primes = 1_i64
      allocate(primes(1))
      primes(1) = 2_i64
    else
      lim_minus_1 = limit - 1_i64
      num_odds = lim_minus_1 / 2_i64

      allocate(is_odd_prime(num_odds))
      is_odd_prime = .true.

      rlim = real(limit, kind=r128)
      rlim = sqrt(rlim)
      sq_lim = int(rlim, i64)

      call mark_odd_composites(is_odd_prime, num_odds, sq_lim)
      call collect_odd_primes(is_odd_prime, num_odds, primes, num_primes)

      deallocate(is_odd_prime)
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
