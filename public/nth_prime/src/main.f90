program main_program
  use, intrinsic :: iso_fortran_env, only : input_unit, output_unit, int64
  use types_mod, only : i64
  use nth_prime_mod, only : get_nth_prime
  implicit none

  integer :: arg_count, ios
  character(len=100) :: arg_str
  integer(i64) :: n_val, result_prime

  arg_count = command_argument_count()

  if (arg_count > 0) then
    call get_command_argument(1, arg_str)
    read(arg_str, *, iostat=ios) n_val
  else
    read(input_unit, *, iostat=ios) n_val
  end if

  if (ios == 0) then
    if (n_val > 0_i64) then
      result_prime = get_nth_prime(n_val)
      write(output_unit, "(i0)") result_prime
    end if
  end if

end program main_program
