# On completely factoring any integer efficiently in a single run of an order-finding algorithm
From the abstract of a recent paper [[E21b]](https://doi.org/10.1007/s11128-021-03069-1): "We show that given the order of a single element selected uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\mathbb Z_N^*">, we can with high probability, and for any integer <img src="https://render.githubusercontent.com/render/math?math=N">, efficiently find the complete factorization of <img src="https://render.githubusercontent.com/render/math?math=N"> in polynomial time.
This implies that a single run of the quantum part of Shor's factoring algorithm is usually sufficient.
All prime factors of <img src="https://render.githubusercontent.com/render/math?math=N"> can then be recovered with negligible computational cost in a classical post-processing step.
The classical algorithm required for this step is essentially due to Miller [[Miller76]](https://doi.org/10.1016/S0022-0000(76)80043-8)."

This repository contains a [Sage](https://www.sagemath.org) script [<code>factor.sage</code>](factor.sage) that implements the factoring algorithm described in [[E21b]](https://doi.org/10.1007/s11128-021-03069-1).

For test purposes, it furthermore contains a script [<code>factor-test.sage</code>](factor-test.sage) that implements order finding: Given the factorization of <img src="https://render.githubusercontent.com/render/math?math=N">, and an element <img src="https://render.githubusercontent.com/render/math?math=g \in \mathbb Z_N^*">, it yields either the exact order <img src="https://render.githubusercontent.com/render/math?math=r"> of <img src="https://render.githubusercontent.com/render/math?math=g">, or a heuristic approximation of <img src="https://render.githubusercontent.com/render/math?math=r"> that is correct with very high probability. The heuristic order-finding simulator is described in further detail in Appendix A of [[E21b]](https://doi.org/10.1007/s11128-021-03069-1).

Note that the aforementioned scripts were developed for academic research purposes. They grew out of our research project in an organic manner as research questions were posed and answered. They are distributed "as is" without warranty of any kind, either expressed or implied. For further details on the terms of use, see the [license](LICENSE.md).

It is possible to further optimize portions of the scripts and the procedures therein. However, the current scripts perform sufficiently well for our purposes, in that they clearly show that it is virtually always possible to completely factor any integer <img src="https://render.githubusercontent.com/render/math?math=N"> efficiently after a single run of an order-finding algorithm.

## Prerequisites
To install [Sage](https://www.sagemath.org) under [Ubuntu 20.04 LTS](https://releases.ubuntu.com/20.04), simply execute:

```console
$ sudo apt install sagemath
```
For other Linux and Unix distributions, or operating systems, you may need to [download Sage](https://www.sagemath.org/download) and install it manually. These scripts were developed for Sage 9.1.

### Attaching the scripts
Launch Sage and attach the scripts [<code>factor.sage</code>](factor.sage) and [<code>factor-test.sage</code>](factor-test.sage), by executing:

```console
$ sage
(..)
sage: %attach factor.sage
sage: %attach factor-test.sage
```

## Factoring
To completely factor <img src="https://render.githubusercontent.com/render/math?math=N">, execute:

```console
sage: factor_completely(r, N, c = 1)
```

Above <img src="https://render.githubusercontent.com/render/math?math=r"> is the order returned by the order-finding algorithm, <img src="https://render.githubusercontent.com/render/math?math=N"> is the integer to be factored, and <img src="https://render.githubusercontent.com/render/math?math=c \ge 1"> is a constant.

As is explained in [[E21b]](https://doi.org/10.1007/s11128-021-03069-1), by increasing <img src="https://render.githubusercontent.com/render/math?math=c"> the success probability of the algorithm can be increased at the expense of also increasing the runtime. In virtually all cases, it is however more than sufficient to let <img src="https://render.githubusercontent.com/render/math?math=c = 1"> as is the default.

To better understand why, recall from [[E21b]](https://doi.org/10.1007/s11128-021-03069-1) that if some moderate product of small prime factors is missing from the order <img src="https://render.githubusercontent.com/render/math?math=r"> input compared to <img src="https://render.githubusercontent.com/render/math?math=\lambda'(N)">, the complete factorization will be recovered anyhow by iterating. If a <i>single</i> large prime factor is missing, it still does not matter, for the complete factorization will be found anyhow via <img src="https://render.githubusercontent.com/render/math?math=N">. It is only if <i>two</i> large prime factors are missing simultaneously, and if these two factors are associated with different prime factors <img src="https://render.githubusercontent.com/render/math?math=p_i"> of <img src="https://render.githubusercontent.com/render/math?math=N = \prod_{i = 1}^n p_i^{e_i}">, that the complete factorization of <img src="https://render.githubusercontent.com/render/math?math=N"> will not be recovered. This is extremely unlikely in practice.

Note furthermore that by default the function will continue to iterate until the complete factorization is found, or until Ctrl-C is pressed. The constant <img src="https://render.githubusercontent.com/render/math?math=k"> in [[E21b]](https://doi.org/10.1007/s11128-021-03069-1), that controls the number of iterations, need therefore not be specified. If you wish, you may explicitly <img src="https://render.githubusercontent.com/render/math?math=k">, or a timeout in seconds, or both, in which case an exception will be raised if either limit specified is exceeded.

## Simulating order finding
As is described in [[E21b]](https://doi.org/10.1007/s11128-021-03069-1), it is possible to perform order finding classically when the factorization of <img src="https://render.githubusercontent.com/render/math?math=N"> is known.

If the factorization of <img src="https://render.githubusercontent.com/render/math?math=p_i - 1"> is known for all <img src="https://render.githubusercontent.com/render/math?math=i \in [1, n]">, where <img src="https://render.githubusercontent.com/render/math?math=N = \prod_{i = 1}^n p_i^{e_i}">, order finding may be performed exactly classically. Otherwise, order finding may be simulated heuristically. Both methods are supported.

### Exact order finding
To test the factoring algorithm by exact order finding, execute:

```console
sage: test_exact_of_random_N(m = 192, c = 1)
```

This function will first select <img src="https://render.githubusercontent.com/render/math?math=N"> uniformly at random from the set of all <img src="https://render.githubusercontent.com/render/math?math=m"> bit composites, where it is required that <img src="https://render.githubusercontent.com/render/math?math=m \in [8, 224]">. It will then select <img src="https://render.githubusercontent.com/render/math?math=g"> uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\mathbb Z_N^*">, and compute the order <img src="https://render.githubusercontent.com/render/math?math=r"> of <img src="https://render.githubusercontent.com/render/math?math=g"> exactly classically by factoring <img src="https://render.githubusercontent.com/render/math?math=N = p_1^{e_1} \cdot \ldots \cdot p_n^{e_n}"> and then <img src="https://render.githubusercontent.com/render/math?math=p_i - 1"> for <img src="https://render.githubusercontent.com/render/math?math=i \in [1, n]"> using functions native to [Sage](https://www.sagemath.org).

Finally, it will call the solver for <img src="https://render.githubusercontent.com/render/math?math=r"> and <img src="https://render.githubusercontent.com/render/math?math=N"> passing along the constant <img src="https://render.githubusercontent.com/render/math?math=c">.

### Heuristic order finding
To test the factoring algorithm by simulating order finding heuristically, execute:

```console
sage: test_heuristic_of_random_pi_ei(l = 1024, n = 2, e_max = 1, c = 1)
```

This function will first select <img src="https://render.githubusercontent.com/render/math?math=n"> distinct prime numbers <img src="https://render.githubusercontent.com/render/math?math=p_i"> uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=[3, 2^{\ell})">,
and <img src="https://render.githubusercontent.com/render/math?math=n"> exponents <img src="https://render.githubusercontent.com/render/math?math=e_i"> uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=[1, e_{\max}]">.
It will then compute <img src="https://render.githubusercontent.com/render/math?math=N=\prod_{i=1}^n p_i^{e_i}">,
select <img src="https://render.githubusercontent.com/render/math?math=g"> uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\mathbb Z_N^*">, and heuristically determine the order <img src="https://render.githubusercontent.com/render/math?math=r"> of <img src="https://render.githubusercontent.com/render/math?math=g"> using the method described in Appendix A of [[E21b]](https://doi.org/10.1007/s11128-021-03069-1).

Finally, it will call the solver for <img src="https://render.githubusercontent.com/render/math?math=r"> and <img src="https://render.githubusercontent.com/render/math?math=N"> passing along the constant <img src="https://render.githubusercontent.com/render/math?math=c">.

### Test suites
To run the test suite described in Appendix A.3 of [[E21b]](https://doi.org/10.1007/s11128-021-03069-1), execute:

```console
sage: test_all_appendix_A()
```

## About and acknowledgments
This script was developed by [Martin Ekerå](mailto:ekera@kth.se), in part at [KTH, the Royal Institute of Technology](https://www.kth.se/en), in Stockholm, [Sweden](https://www.sweden.se). Valuable comments and advice were provided by Johan Håstad throughout the development process.

Funding and support for this work was provided by the Swedish NCSA that is a part of the [Swedish Armed Forces](https://www.mil.se).
