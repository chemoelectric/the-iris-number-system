import JSZip from 'jszip';

export async function exportCompleteWorkspaceZip(): Promise<void> {
  const zip = new JSZip();

  // List of files to fetch and package into the zip
  const filesToInclude = [
    'Iris_Number_System-00-Bibliography.adoc',
    'Iris_Number_System-01-Volume_I_Fundamentals.adoc',
    'Iris_Number_System-02-Volume_II_Number_Theory_etc.adoc',
    'Iris_Number_System-03-Volume_III_Geometry_Algebra_etc.adoc',
    'Iris_Number_System-04-Volume_IV_Physics_etc.adoc',
    'Iris_Number_System-05-Volume_V_Spectral_Analysis_etc.adoc',
    'Iris_Number_System-06-Volume_VI_Fractals.adoc',
    'Iris_Number_System-07-Volume_VII_Typefaces.adoc',
    'Iris_Number_System-08-Volume_VIII_Physical_Chemistry.adoc',
    'Iris_Number_System-Reference_Book.adoc',
    'm_res_numerical_analysis_and_statistical_mechanics.adoc',
    'mres_numerical_analysis/mres_types.h',
    'mres_numerical_analysis/mres_types.c',
    'mres_numerical_analysis/mres_stiff_solver.h',
    'mres_numerical_analysis/mres_stiff_solver.c',
    'mres_numerical_analysis/test_mres_analysis.c',
    'mres_numerical_analysis/Makefile',
    'GNUmakefile',
    'header.tex',
    'chapter-newpage.lua',
    'fix-greek.lua',
    'bezclip.mp',
    'bernstein_root_finder.adb',
    'wave_queens_8.adb',
    'grassmann_queens_8.adb',
    'acl2/iris_number_system.lisp',
    'acl2/README.md',
    'grover_search_givens/grover_search_givens.adb',
    'grover_search_givens/grover_search_givens.gpr',
    'grover_search_givens/GNUmakefile',
    'grover_search_givens/README.md',
    'fast_factorization/fast_factorization.d',
    'fast_factorization/semiprime_factorization.d',
    'fast_factorization/uncrustify.cfg',
    'primality_test/primality_test.d',
    'primality_test/uncrustify.cfg',
    'nth_prime/GNUmakefile',
    'nth_prime/README.md',
    'nth_prime/nth_prime_demo.icn',
    'nth_prime/nth_prime.icn',
    'nth_prime/make-lcov-reports',
    'nth_prime/src/main.f90',
    'nth_prime/src/nth_prime_64.d',
    'nth_prime/src/nth_prime.c',
    'nth_prime/src/nth_prime_mod.f90',
    'nth_prime/src/sieve_mod.f90',
    'nth_prime/src/types_mod.f90',
    'nth_prime/src/nth_prime_64.c',
    'nth_prime/src/nth_prime.d',
    'nth_prime/src/prime_c.h'
  ];

  for (const filePath of filesToInclude) {
    try {
      const response = await fetch(`/${filePath}`);
      if (response.ok) {
        const text = await response.text();
        zip.file(filePath, text);
      }
    } catch (e) {
      console.warn(`Could not fetch ${filePath} for zip packaging:`, e);
    }
  }

  const contentBlob = await zip.generateAsync({ type: 'blob' });
  const downloadUrl = URL.createObjectURL(contentBlob);
  const link = document.createElement('a');
  link.href = downloadUrl;
  link.download = 'the-iris-number-system-complete.zip';
  document.body.appendChild(link);
  link.click();
  document.body.removeChild(link);
  URL.revokeObjectURL(downloadUrl);
}
