program main_program
  use, intrinsic :: iso_fortran_env, only : input_unit, output_unit, int64
  use types_mod, only : i64, r128
  use nth_prime_mod, only : get_nth_prime
  implicit none

  integer :: arg_count, ios
  character(len=256) :: arg_str
  integer(i64) :: n_val, result_prime

  arg_count = command_argument_count()

  if (arg_count > 0) then
    call get_command_argument(1, arg_str)
    call parse_input_number(arg_str, n_val, ios)
  else
    read(input_unit, '(a)', iostat=ios) arg_str
    if (ios == 0) then
      call parse_input_number(arg_str, n_val, ios)
    end if
  end if

  if (ios == 0) then
    if (n_val > 0_i64) then
      result_prime = get_nth_prime(n_val)
      write(output_unit, "(i0)") result_prime
    end if
  end if

contains

  subroutine parse_input_number(raw_str, n_val, ios)
    character(len=*), intent(in) :: raw_str
    integer(i64), intent(out) :: n_val
    integer, intent(out) :: ios

    character(len=256) :: clean_str
    integer :: i, len_clean, p_idx
    real(r128) :: rval
    integer(i64) :: base_val, exp_val

    clean_str = ""
    len_clean = 0
    i = 1
    do while (i <= len(trim(raw_str)))
      if (raw_str(i:i) /= ',' .and. raw_str(i:i) /= '_') then
        len_clean = len_clean + 1
        clean_str(len_clean:len_clean) = raw_str(i:i)
      end if
      i = i + 1
    end do

    ios = -1
    if (len_clean == 0) return

    p_idx = index(clean_str(1:len_clean), '^')
    if (p_idx > 0) then
      read(clean_str(1:p_idx-1), *, iostat=ios) base_val
      if (ios == 0) then
        read(clean_str(p_idx+1:len_clean), *, iostat=ios) exp_val
        if (ios == 0) then
          n_val = base_val ** exp_val
          return
        end if
      end if
    end if

    p_idx = index(clean_str(1:len_clean), '**')
    if (p_idx > 0) then
      read(clean_str(1:p_idx-1), *, iostat=ios) base_val
      if (ios == 0) then
        read(clean_str(p_idx+2:len_clean), *, iostat=ios) exp_val
        if (ios == 0) then
          n_val = base_val ** exp_val
          return
        end if
      end if
    end if

    read(clean_str(1:len_clean), *, iostat=ios) n_val
    if (ios == 0) return

    read(clean_str(1:len_clean), *, iostat=ios) rval
    if (ios == 0) then
      n_val = int(rval, i64)
      return
    end if
  end subroutine parse_input_number

end program main_program
