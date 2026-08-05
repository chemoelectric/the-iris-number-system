module types_mod
  use, intrinsic :: iso_fortran_env, only : int64, real64
  implicit none
  private
  public :: i64, r64

  integer, parameter :: i64 = int64
  integer, parameter :: r64 = real64
end module types_mod
