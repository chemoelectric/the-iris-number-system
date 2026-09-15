/* mres_types.c: Addressable copies of m-resolution operations.
 * Allows linkage from external modules, ATS, Ada, and Scheme.
 * Strictly adheres to 72-character line limit and C23.
 */

#include "mres_types.h"

real_t mres_addr_downarrow_0(mjet3_t j) {
  return mres_downarrow_0(j);
}

real_t mres_addr_downarrow_grid(mjet3_t j, double dx) {
  return mres_downarrow_grid(j, dx);
}

double mres_addr_downarrow_rate(mjet3_t j, int order) {
  return mres_downarrow_rate(j, order);
}

mjet3_t mres_addr_mjet3_add(mjet3_t a, mjet3_t b) {
  return mjet3_add(a, b);
}

mjet3_t mres_addr_mjet3_mul(mjet3_t a, mjet3_t b) {
  return mjet3_mul(a, b);
}

mjet3_t mres_addr_mjet3_inv(mjet3_t a) {
  return mjet3_inv(a);
}
