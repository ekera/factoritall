# On completely factoring any integer efficiently in a single run of an order-finding algorithm
From the abstract of [[E21b]](https://doi.org/10.1007/s11128-021-03069-1): "We show that given the order of a single element selected uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\color{brown}\mathbb Z_N^*">, we can with very high probability, and for any integer <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N">, efficiently find the complete factorization of <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N"> in polynomial time.
This implies that a single run of the quantum part of Shor's factoring algorithm is usually sufficient.
All prime factors of <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N"> can then be recovered with negligible computational cost in a classical post-processing step.
The classical algorithm required for this step is essentially due to Miller [[Miller76]](https://doi.org/10.1016/S0022-0000(76)80043-8)."

This repository contains a [Sage](https://www.sagemath.org) script [<code>factor.sage</code>](factor.sage) that implements the factoring algorithm in [[E21b]](https://doi.org/10.1007/s11128-021-03069-1).

For test purposes, it furthermore contains a script [<code>factor-test.sage</code>](factor-test.sage) that simulates order finding.

Note that the aforementioned scripts were developed for academic research purposes. They grew out of our research project in an organic manner as research questions were posed and answered. They are distributed "as is" without warranty of any kind, either expressed or implied. For further details, see the [license](LICENSE.md).

It is possible to further optimize portions of the scripts and the procedures therein. However, the current scripts perform sufficiently well for our purposes, in that they clearly show that it is virtually always possible to completely factor any integer <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N"> efficiently after a single run of an order-finding algorithm.

## Prerequisites
To install [Sage](https://www.sagemath.org) under [Ubuntu 20.04 LTS](https://releases.ubuntu.com/20.04), simply execute:

```console
$ sudo apt install sagemath
```
For other Linux and Unix distributions, or operating systems, you may need to [download Sage](https://www.sagemath.org/download) and install it manually. These scripts were developed for Sage 9.3.

### Attaching the scripts
Launch Sage and attach the scripts [<code>factor.sage</code>](factor.sage) and [<code>factor-test.sage</code>](factor-test.sage), by executing:

```console
$ sage
(..)
sage: %attach factor.sage
sage: %attach factor-test.sage
```

## Factoring
To completely factor <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N">, execute:

```console
sage: factor_completely(r, N, c = 1)
```

Above <img src="https://render.githubusercontent.com/render/math?math=\color{brown}r"> is the order of an element <img src="https://render.githubusercontent.com/render/math?math=\color{brown}g"> selected uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\color{brown}\mathbb Z_N^*">, <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N"> is the integer to be factored, and <img src="https://render.githubusercontent.com/render/math?math=\color{brown}c \ge 1"> is a constant that may be freely selected.

As is explained in [[E21b]](https://doi.org/10.1007/s11128-021-03069-1), by increasing <img src="https://render.githubusercontent.com/render/math?math=\color{brown}c"> the success probability of the algorithm can be increased at the expense of also increasing the runtime. In virtually all cases, it is however more than sufficient to let <img src="https://render.githubusercontent.com/render/math?math=\color{brown}c = 1">.

To better understand why, recall from [[E21b]](https://doi.org/10.1007/s11128-021-03069-1) that if some moderate product of small prime factors is missing from the order <img src="https://render.githubusercontent.com/render/math?math=\color{brown}r"> input compared to <img src="https://render.githubusercontent.com/render/math?math=\color{brown}\lambda'(N)">, the complete factorization will be recovered anyhow by iterating. If a <i>single</i> large prime factor is missing, it still does not matter, for the complete factorization will be found anyhow via <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N">. It is only if <i>two</i> large prime factors are missing simultaneously, and if these two factors are associated with different prime factors <img src="https://render.githubusercontent.com/render/math?math=\color{brown}p_i"> of <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N = \prod_{i = 1}^n p_i^{e_i}">, that the complete factorization of <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N"> will not be recovered. This is very unlikely to occur in practice, even if some <img src="https://render.githubusercontent.com/render/math?math=\color{brown}p_i - 1"> are smooth.

Note furthermore that by default the function will continue to iterate until the complete factorization is found, or until Ctrl-C is pressed. The constant <img src="https://render.githubusercontent.com/render/math?math=\color{brown}k"> in [[E21b]](https://doi.org/10.1007/s11128-021-03069-1), that controls the number of iterations, need therefore not be specified. If you wish, you may explicitly set <img src="https://render.githubusercontent.com/render/math?math=\color{brown}k">, or a timeout in seconds, or both, in which case an exception will be raised if either limit specified is exceeded.

## Simulating order finding
The [<code>factor-test.sage</code>](factor-test.sage) script implements two types of order-finding simulators:

- Given the factorization of <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N">, and an element <img src="https://render.githubusercontent.com/render/math?math=\color{brown}g \in \mathbb Z_N^*">, the first type of order-finding simulator yields either the order <img src="https://render.githubusercontent.com/render/math?math=\color{brown}r"> of <img src="https://render.githubusercontent.com/render/math?math=\color{brown}g">, or a heuristic approximation of <img src="https://render.githubusercontent.com/render/math?math=\color{brown}r"> that is correct with very high probability.

   To be more specific: If the factorization of <img src="https://render.githubusercontent.com/render/math?math=\color{brown}p_i - 1"> is known for all <img src="https://render.githubusercontent.com/render/math?math=\color{brown}i \in [1, n]">, where <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N = \prod_{i = 1}^n p_i^{e_i}">, order finding can be performed exactly. Otherwise, a heuristic approximation can be computed by performing trial division to identify all small factors of <img src="https://render.githubusercontent.com/render/math?math=\color{brown}p_i - 1"> for <img src="https://render.githubusercontent.com/render/math?math=\color{brown}i \in [1, n]">. For further details, see Appendix A of [[E21b]](https://doi.org/10.1007/s11128-021-03069-1).

- Given the factorization of <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N">, the second type of order-finding simulator yields the order <img src="https://render.githubusercontent.com/render/math?math=\color{brown}r"> of an element <img src="https://render.githubusercontent.com/render/math?math=\color{brown}g"> selected uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\color{brown}\mathbb Z_N^*">. This without explicitly computing <img src="https://render.githubusercontent.com/render/math?math=\color{brown}g">.

   This approach to simulating order finding is not described in [[E21b]](https://doi.org/10.1007/s11128-021-03069-1). For further details, see instead the documentation of the <code>test_of_random_pi_ei()</code> function in the [<code>factor-test.sage</code>](factor-test.sage) script.

### Exact order finding by factoring
To test the factoring algorithm by performing exact order finding for a random integer <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N">, execute:

```console
sage: test_of_random_N(m = 192, c = 1)
```

This function will first select <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N"> uniformly at random from the set of all <img src="https://render.githubusercontent.com/render/math?math=\color{brown}m"> bit composites, where it is required that <img src="https://render.githubusercontent.com/render/math?math=\color{brown}m \in [8, 224]">. It will then select <img src="https://render.githubusercontent.com/render/math?math=\color{brown}g"> uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\color{brown}\mathbb Z_N^*">, and compute the order <img src="https://render.githubusercontent.com/render/math?math=\color{brown}r"> of <img src="https://render.githubusercontent.com/render/math?math=\color{brown}g"> exactly classically by factoring <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N = p_1^{e_1} \cdot \ldots \cdot p_n^{e_n}"> and then <img src="https://render.githubusercontent.com/render/math?math=\color{brown}p_i - 1"> for <img src="https://render.githubusercontent.com/render/math?math=\color{brown}i \in [1, n]"> using functions native to [Sage](https://www.sagemath.org).

Finally, it will call <code>factor_completely()</code> with <img src="https://render.githubusercontent.com/render/math?math=\color{brown}r"> and <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N"> passing along the constant <img src="https://render.githubusercontent.com/render/math?math=\color{brown}c">.

### Exact or heuristic order finding for a given factorization
To test the factoring algorithm by performing order finding given the factorization of <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N">, execute:

```console
sage: test_of_random_pi_ei(l = 1024, n = 2, e_max = 1, c = 1, exact = True)
```

This function will first select <img src="https://render.githubusercontent.com/render/math?math=\color{brown}n \ge 2"> distinct primes <img src="https://render.githubusercontent.com/render/math?math=\color{brown}p_i"> uniformly at random from the set of all odd <img src="https://render.githubusercontent.com/render/math?math=\color{brown}\ell"> bit primes,
and <img src="https://render.githubusercontent.com/render/math?math=\color{brown}n"> exponents <img src="https://render.githubusercontent.com/render/math?math=\color{brown}e_i"> uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\color{brown}[1, e_{\max}]">.
It will then compute <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N=\prod_{i=1}^n p_i^{e_i}">.

- If <code>exact</code> is set to <code>False</code>, this function will first select <img src="https://render.githubusercontent.com/render/math?math=\color{brown}g"> uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\color{brown}\mathbb Z_N^*">. It will then heuristically determine the order <img src="https://render.githubusercontent.com/render/math?math=\color{brown}r"> of <img src="https://render.githubusercontent.com/render/math?math=\color{brown}g"> using the first type of simulator [described above](#simulating-order-finding).

- If <code>exact</code> is set to <code>True</code>, as is the default, this function will exactly compute the order <img src="https://render.githubusercontent.com/render/math?math=\color{brown}r"> of an element <img src="https://render.githubusercontent.com/render/math?math=\color{brown}g"> selected uniformly at random from <img src="https://render.githubusercontent.com/render/math?math=\color{brown}\mathbb Z_N^*">, using the second type of simulator [described above](#simulating-order-finding).

   This without explicitly computing <img src="https://render.githubusercontent.com/render/math?math=\color{brown}g">. (Note that <img src="https://render.githubusercontent.com/render/math?math=\color{brown}g"> is not used by the factoring algorithm in [[E21b]](https://doi.org/10.1007/s11128-021-03069-1).)

Finally, this function will call <code>factor_completely()</code> with <img src="https://render.githubusercontent.com/render/math?math=\color{brown}r"> and <img src="https://render.githubusercontent.com/render/math?math=\color{brown}N"> passing along the constant <img src="https://render.githubusercontent.com/render/math?math=\color{brown}c">.

### Test suites
To run the test suite described in Appendix A.3 of [[E21b]](https://doi.org/10.1007/s11128-021-03069-1), execute:

```console
sage: test_all_appendix_A(exact = True)
```

This function in turn calls the <code>test_of_random_pi_ei()</code> function [documented above](#exact-or-heuristic-order-finding-for-a-given-factorization).

- Set the <code>exact</code> flag to <code>False</code> to perform heuristic order finding as described in Appendix A of [[E21b]](https://doi.org/10.1007/s11128-021-03069-1).

- Set the <code>exact</code> flag to <code>True</code>, as is the default, to instead perform exact order finding at the expense of foregoing the computation of <img src="https://render.githubusercontent.com/render/math?math=\color{brown}g">. This is an improvement of the procedure in Appendix A of [[E21b]](https://doi.org/10.1007/s11128-021-03069-1).

For further details on the <code>exact</code> flag, see the [documentation](#exact-or-heuristic-order-finding-for-a-given-factorization) for the <code>test_of_random_pi_ei()</code> function.

## Notes on optimizations
This implementation supports several optimizations that may be enabled or disabled by passing along flags to the functions described in the above sections. For more information, see the [notes on optimizations](optimizations.md).

## About and acknowledgments
These scripts were developed by [Martin Ekerå](mailto:ekera@kth.se), in part at [KTH, the Royal Institute of Technology](https://www.kth.se/en), in Stockholm, [Sweden](https://www.sweden.se). Valuable comments and advice were provided by Johan Håstad throughout the development process.

Funding and support was provided by the Swedish NCSA that is a part of the [Swedish Armed Forces](https://www.mil.se).
