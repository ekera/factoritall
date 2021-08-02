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

- <code>opt_split_factors_with_multiplicity</code> to either <code>True</code> (default option) or <code>False</code>

   When set to <code>True</code>, as is the default, the solver initially tests if <img src="https://render.githubusercontent.com/render/math?math=\gcd(r, N)"> yields a non-trivial factor. If so, the non-trivial factor is reported. When set to <code>False</code>, the aforementioned test is not performed.

   To understand the test, note that if <img src="https://render.githubusercontent.com/render/math?math=p^e"> divides <img src="https://render.githubusercontent.com/render/math?math=N">, for <img src="https://render.githubusercontent.com/render/math?math=e > 1"> an integer and <img src="https://render.githubusercontent.com/render/math?math=p"> a large prime, then <img src="https://render.githubusercontent.com/render/math?math=p^{e-1}"> is likely to also divide <img src="https://render.githubusercontent.com/render/math?math=r">. Note furthermore that it is relatively inexpensive to split <img src="https://render.githubusercontent.com/render/math?math=N"> by computing <img src="https://render.githubusercontent.com/render/math?math=\gcd(r, N)">, compared to exponentiating modulo <img src="https://render.githubusercontent.com/render/math?math=N">.

   For random <img src="https://render.githubusercontent.com/render/math?math=N"> void of small factors, it is very unlikely for prime factors to occur with multiplicity. For such <img src="https://render.githubusercontent.com/render/math?math=N">, this optimization is hence not of any practical use. It is only if <img src="https://render.githubusercontent.com/render/math?math=N"> is likely to have factors that occur with multiplicity, for some special reason, that this optimization is useful in practice. This optimization may also yield non-trivial factors if <img src="https://render.githubusercontent.com/render/math?math=N"> has small factors. However, such factors would typically first be removed, e.g. by trial division, before calling upon these more elaborate factoring techniques.

   Note that for <img src="https://render.githubusercontent.com/render/math?math=N"> as in the problem instances setup in Appendix A.3 of [[E21b]](https://doi.org/10.1007/s11128-021-03069-1), prime factors are intentionally forced to occur with multiplicity with high probability (when <img src="https://render.githubusercontent.com/render/math?math=e_{\max} > 1">). This so as to test that such special cases are handled correctly by the solver. For such <img src="https://render.githubusercontent.com/render/math?math=N">, this optimization is likely to report non-trivial factors. This served as our rationale for including it as an option.

   This optimization is described in earlier works in the literature, see for instance [[GLMS15]](https://arxiv.org/pdf/1511.04385.pdf).

- <code>opt_report_accidental_factors</code> to either <code>True</code> (default option) or <code>False</code>

   When set to <code>True</code>, as is the default, the solver reports non-trivial factors of <img src="https://render.githubusercontent.com/render/math?math=N"> found "by accident" when sampling <img src="https://render.githubusercontent.com/render/math?math=x"> (denoted <img src="https://render.githubusercontent.com/render/math?math={x_j}"> in [[E21b]](https://doi.org/10.1007/s11128-021-03069-1)) uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\mathbb Z_{N'}^*">, for <img src="https://render.githubusercontent.com/render/math?math=N^\prime"> equal to <img src="https://render.githubusercontent.com/render/math?math=N">, or to the product of all pairwise coprime composite factors of <img src="https://render.githubusercontent.com/render/math?math=N"> in the factor collection, depending on which option is selected for the <code>opt_process_composite_factors</code> flag. When set to <code>False</code>, such non-trivial factors are not reported.

   Note that it is very unlikely for non-trivial factors to be found by accident if <img src="https://render.githubusercontent.com/render/math?math=N"> is void of small prime factors. It is only if small factors of <img src="https://render.githubusercontent.com/render/math?math=N"> are not first removed, e.g. by trial division, that factors are likely to be found by accident. On the other hand, if we do find factors by accident, it is only logical to report them. This served as our rationale for including this optimization as an option.

   Note furthermore that if <img src="https://render.githubusercontent.com/render/math?math=N"> has small factors when this optimization is enabled, and if the <code>opt_process_composite_factors</code> flag is furthermore set to <code>OptProcessCompositeFactors.JOINTLY_MOD_N</code>, then the same non-trivial factor of <img src="https://render.githubusercontent.com/render/math?math=N"> may be repeatedly found by accident when sampling. This may generate long printouts.

   Also note that factors that are found "by accident" when sampling <img src="https://render.githubusercontent.com/render/math?math=g"> uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\mathbb Z_{N}^*"> are not reported even if <code>opt_report_accidental_factors</code> is set to <code>True</code>. This is because such factors, if found in practice, would typically affect for which <img src="https://render.githubusercontent.com/render/math?math=N"> order finding is performed in the first place.

- <code>opt_square</code> to either <code>True</code> (default option) or <code>False</code>

   When set to <code>True</code>, as is the default, the solver first computes <img src="https://render.githubusercontent.com/render/math?math=x^{o}">. It then takes consecutive squares to form <img src="https://render.githubusercontent.com/render/math?math=x^{2^i o}"> for various <img src="https://render.githubusercontent.com/render/math?math=i">. When set to <code>False</code>, the solver naïvely computes <img src="https://render.githubusercontent.com/render/math?math=x^{2^i o}"> from scratch for each <img src="https://render.githubusercontent.com/render/math?math=i">.

   This optimization is described in Section 3.2.1 of [[E21b]](https://doi.org/10.1007/s11128-021-03069-1).