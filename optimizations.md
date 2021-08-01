## Notes on optimizations
This implementation supports several optimizations that may be enabled or disabled by passing along flags to the functions described in the [main documentation](README.md). This allows tests to be performed both with and without optimizations enabled. In particular, you may set:

- <code>opt_process_composite_factors</code> to one of the below three options:

   - <code>OptProcessCompositeFactors.JOINTLY_MOD_N</code>

      The solver selects <img src="https://render.githubusercontent.com/render/math?math=x"> (denoted <img src="https://render.githubusercontent.com/render/math?math={x_j}"> in [[E21b]](https://doi.org/10.1007/s11128-021-03069-1)) uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\mathbb Z_N^*">. It then exponentiates <img src="https://render.githubusercontent.com/render/math?math=x"> modulo <img src="https://render.githubusercontent.com/render/math?math=N">.

      This is how the unoptimized algorithm is described in Section 3.2 of [[E21b]](https://doi.org/10.1007/s11128-021-03069-1).

   - <code>OptProcessCompositeFactors.JOINTLY_MOD_Np</code>

      The solver selects <img src="https://render.githubusercontent.com/render/math?math=x"> uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\mathbb Z_{N'}^*">.  It then exponentiates <img src="https://render.githubusercontent.com/render/math?math=x"> modulo <img src="https://render.githubusercontent.com/render/math?math={N^{\prime}}">.

      Above <img src="https://render.githubusercontent.com/render/math?math={N^{\prime}}"> is the product of all pairwise coprime composite factors of <img src="https://render.githubusercontent.com/render/math?math=N"> currently stored in the factor collection.

   - <code>OptProcessCompositeFactors.SEPARATELY_MOD_Np</code> (default option)

      The solver selects <img src="https://render.githubusercontent.com/render/math?math=x"> uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\mathbb Z_{N'}^*">, for <img src="https://render.githubusercontent.com/render/math?math={N^{\prime}}"> the product of all pairwise coprime composite factors of <img src="https://render.githubusercontent.com/render/math?math=N"> currently stored in the factor collection.
      The solver then exponentiates <img src="https://render.githubusercontent.com/render/math?math=x"> modulo <img src="https://render.githubusercontent.com/render/math?math={N^{\prime}}"> where <img src="https://render.githubusercontent.com/render/math?math={N^{\prime}}"> now runs over all pairwise coprime composite factors of <img src="https://render.githubusercontent.com/render/math?math=N"> currently stored in the factor collection. This is the default option.

   Note that all three options are equivalent with respect to their ability to find non-trivial factors of <img src="https://render.githubusercontent.com/render/math?math=N">. The options differ only in terms of their arithmetic complexity. Although several exponentiations may be required when the default option is used, this fact is, in general, more than compensated for by the fact that the moduli are smaller, leading the default option to outperform the other two options.

   This optimization is described in Section 3.2.1 of [[E21b]](https://doi.org/10.1007/s11128-021-03069-1).
