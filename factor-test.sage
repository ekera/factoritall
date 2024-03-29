# ------------------------------------------------------------------------------
# This Sage script implements tests for the procedure described in the paper:
#
# [E21b] Ekerå, M.: "On completely factoring any integer efficiently in a single
#                    run of an order-finding algorithm".
#                   Quantum Inf. Process. 20(6):205 (2021).
#
# Note: You must attach "factor.sage" prior to attaching this file.
#
# Note: This implementation assumes that the random_element() function (in the
# IntegerModRing class that is provided by Sage) is indistinguishable from a
# function that selects an element uniformly at random from the ring.

from timer import Timer;

# ------------------------------------------------------------------------------
# Tests the implementation of the factoring algorithm.

# This function first selects n >= 2 distinct primes pi from the set of all odd
# l bit primes, and n exponents ei uniformly at random from [1, e_max]. It then
# computes N = p1^e1 * .. * pn^en.
#
# This function may be run in exact or heuristic mode, as controlled by the
# exact flag being set to either True or False, respectively:
#
# i) In heuristic mode, this function selects g uniformly at random from the
# multiplicative group of the ring of integers modulo N, and heuristically
# determines the order r of g using the method in Appendix A of [E21b].
#
# More specifically, it selects gi from the multiplicative group of the ring of
# integers modulo pi^ei for i in [1, n], and heuristically estimates the order
# ri of gi. This by using that lambda(pi^ei) = (pi - 1) pi^(ei - 1) as pi is
# odd, and by using a factor base of primes <= Bs to find small factors of
# pi - 1 via trial division. It then computes g via the Chinese remainder
# theorem, by using that gi = g mod pi^ei, along with a heuristic estimate
# lcm(r1, ..., rn) of the order r of g.
#
# ii) In exact mode, this function instead samples the orders ri exactly, and
# then computes r = lcm(r1, ..., rn). To sample ri exactly, this function first
# samples an index di uniformly at random from [0, lambda(pi^ei)). It then uses
# that the order ri of the element gi = Gi^di is
#
#   ri = lambda(pi^ei) / gcd(lambda(pi^ei), di)
#
# to sample gi of order ri from the multiplicative group of the ring of integers
# modulo pi^ei, which is cyclic. This for Gi a generator of said group, and for
# lambda() the Carmichael function as defined above.
#
# Note that it is typically hard to compute gi, and hence g, when using exact
# mode: It is hard to find an element Gi that we can prove is a generator
# without factoring pi - 1. However, this is not a problem in our use case, as
# we seek the order r of g selected uniformly at random from the multiplicative
# group of the ring of integers modulo N. We do not need to explicitly know g.
#
# Hence, it suffices to follow the above procedure to sample di, then ri, and
# then r. The computation of gi = Gi^di, and of g, may simply be skipped over.
#
#
# Finally, this function calls factor_completely() with r and N passing along c.
#
# If you wish, you may specify k and/or a timeout in seconds. If the number of
# iterations performed by the solver exceeds k, or if the timeout is exceeded,
# an exception of type IncompleteFactorizationException will be raised.
#
# The remaining arguments are optimization flags. They are documented below in
# the code, and in "optimizations.md". It is recommended to use the defaults.
def test_of_random_pi_ei(l = 1024, n = 2, e_max = 1, c = 1,
  Bs = 10^6, sanity_check = False,
  return_timing_statistics = False,
  k = None,
  timeout = None,
  exact = True,
  opt_split_factors_with_multiplicity = True,
  opt_report_accidental_factors = True,
  opt_abort_early = True,
  opt_square = True,
  opt_exclude_one = True,
  opt_process_composite_factors =
    OptProcessCompositeFactors.SEPARATELY_MOD_Np):

  # Function to select an odd prime uniformly at random from [2^(l - 1), 2^l).
  def generate_prime(l):
    R = IntegerModRing(2^(l - 1));

    while True:
      p = 2^(l - 1) + ZZ(R.random_element().lift());
      if (p % 2) == 0:
        continue; # Explicitly exclude 2. Only relevant when l = 2.
      if p.is_prime(proof = False):
        return p;

  # Rudimentary sanity checks for the parameters passed to this function.
  if (n < 2) or (e_max < 1) or (c < 1) or (l <= 0) or (Bs < 10^3):
    raise Exception("Error: Incorrect parameters: It is required that " +
      "n >= 2, e_max >= 1, c >= 1, l > 0 and Bs >= 10^3.");

  if l <= 24:
    count = prime_pi(2^l - 1) - prime_pi(2^(l - 1) - 1);
    if l == 2:
      count -= 1; # Explicitly exclude 2. Only relevant when l = 2.
    if n > count:
      raise Exception("Error: Incorrect parameters: Ran out of primes: "
        "There are less than " + str(n) + " odd l bit primes.");

  # Start a timer.
  setup_timer = Timer().start();

  # Select n distinct prime factors of length l bits using generate_prime(). For
  # each prime factor, select an exponent uniformly at random from [1, e_max].
  factors = [];

  for i in range(n):
    while True:
      p = generate_prime(l);
      e = 1 + IntegerModRing(e_max).random_element().lift();

      if p not in [f for [f, _] in factors]:
        print("Selected factor " + str(i) + ":", str(p) + "^" + str(e));
        factors.append([p, e]);
        break;

  print("");

  # Take the product of the factors with exponents to form N.
  N = prod([p^e for [p, e] in factors]);

  print("Selected N = " + str(N) + "\n");

  # Define Z_N.
  R = IntegerModRing(N);

  if exact:
    # Compute the exact order r of an element g selected uniformly at random
    # from the multiplicative group of the ring of integers modulo N. This
    # without explicitly computing g.

    while True:
      ris = [];

      for i in range(len(factors)):
        [pi, ei] = factors[i];

        lambdai = (pi - 1) * pi^(ei - 1);
        di = IntegerModRing(lambdai).random_element().lift();

        ris.append(lambdai / gcd(lambdai, di));

      r = lcm(ris); # order of g

      # Optimization: Sample g uniformly at random from Z_N^* \ {1}.
      #
      # For details, see "optimizations.md" and Section 3.2.1 of [E21b].
      if (r == 1) and opt_exclude_one:
        print("\nNote: Sampled g = 1; excluding and sampling again...\n");
        continue;

      break;

  else:
    # Select an element g uniformly at random from the multiplicative group of
    # the ring of integers modulo N. Approximate the order r of g heuristically.

    P = prime_range(Bs + 1);

    while True:
      # Select g quickly by picking gi from each cyclic subgroup, computing its
      # order, and composing under the CRT. This avoids exponentiating modulo N.
      ris = [];
      gis = [];
      mds = [];

      for i in range(len(factors)):
        [pi, ei] = factors[i];

        print("Processing subgroup " + str(i) + ": " + str(pi) + "^" + str(ei));

        Ri = IntegerModRing(pi^ei);
        while True:
          gi = Ri.random_element();
          if gcd(gi.lift(), pi) == 1:
            break;

          # Note: If a non-trivial factor is found "by accident" when sampling
          # g, we would use it to split N in an actual implementation. We do not
          # do so here, so as not to complicate the test procedure too much.

        ri = (pi - 1) * pi^(ei - 1);

        ri_base = ri;
        ri = 1;

        for f in P:
          while (ri_base % f) == 0:
            ri_base /= f;
            ri *= f;

        gi_base = gi^ri_base;

        for f in P:
          while (ri % f) == 0:
            if gi_base^(ri / f) != 1:
              break;
            ri /= f;

        ri *= ri_base;

        ris.append(ri);
        gis.append(gi.lift());
        mds.append(pi^ei);

      g = R(crt(gis, mds)); # map (g1, .., gn) to g in Z_N^*

      # Optimization: Sample g uniformly at random from Z_N^* \ {1}.
      #
      # For details, see "optimizations.md" and Section 3.2.1 of [E21b].
      if (g == 1) and opt_exclude_one:
        print("\nNote: Sampled g = 1; excluding and sampling again...\n");
        continue;

      r = lcm(ris); # order of g

      break;

    if sanity_check:
      if g^r != 1:
        raise Exception("Error: The order is incorrectly approximated.");

      for f in P:
        if r % f == 0:
          if g^(r / f) == 1:
            raise Exception("Error: The order is incorrectly approximated.");

    print("\nSelected g = " + str(g));

  r_max = lcm([(p - 1) * p^(e - 1) for [p, e] in factors]);

  if exact:
    print("The order of g is r =", r);
  else:
    print("\nThe order of g is approximated as r =", r);

  print("\nThe maximal order is lambda(N) =", r_max);
  print("\nThe fraction lambda(N) / r = " + str(factor(r_max / r)) + "\n");

  # Stop the timer.
  setup_timer.stop();

  # The problem instance has been constructed.
  print("Time required to construct the problem instance:", setup_timer);

  print("\nFinished building the problem instance, solving commences...\n");
  solve_timer = Timer().start();
  factor_completely(r, N, c,
    k = k,
    timeout = timeout,
    opt_split_factors_with_multiplicity =
      opt_split_factors_with_multiplicity,
    opt_report_accidental_factors =
      opt_report_accidental_factors,
    opt_abort_early =
      opt_abort_early,
    opt_square =
      opt_square,
    opt_exclude_one =
      opt_exclude_one,
    opt_process_composite_factors =
      opt_process_composite_factors);
  solve_timer.stop();

  if return_timing_statistics:
    return [setup_timer, solve_timer];

# This function first selects N uniformly at random from the set of all m bit
# composites, where it is required that m be in [8, 224]. It then selects g
# uniformly at random from the multiplicative group of the ring of integers
# modulo N, and computes the order r of g exactly classically by factoring
# N = p1^e1 * .. * pn^en and then factoring pi - 1 for i in [1, n] using
# functions native to Sage.
#
# Finally, this function calls factor_completely() with r and N passing along c.
#
# If you wish, you may specify k and/or a timeout in seconds. If the number of
# iterations performed by the solver exceeds k, or if the timeout is exceeded,
# an exception of type IncompleteFactorizationException will be raised.
#
# The remaining arguments are optimization flags. They are documented below in
# the code, and in "optimizations.md". It is recommended to use the defaults.
def test_of_random_N(m = 192, c = 1,
  return_timing_statistics = False,
  k = None,
  timeout = None,
  opt_split_factors_with_multiplicity = True,
  opt_report_accidental_factors = True,
  opt_abort_early = True,
  opt_square = True,
  opt_exclude_one = True,
  opt_process_composite_factors =
    OptProcessCompositeFactors.SEPARATELY_MOD_Np):

  # Sanity checks.
  if m < 8:
    raise Exception("Error: Select m >= 8.");

  if m > 224:
    raise Exception("Error: It may take a long time to factor an m = " +
      str(m) + " bit integer N. Select m <= 224.");

  # Start a timer.
  setup_timer = Timer().start();

  # Pick an m bit composite integer N uniformly at random.
  R = IntegerModRing(2^(m - 1));
  while True:
    N = R.random_element().lift() + 2^(m - 1);
    if not N.is_prime(proof = False):
      break;

  print("Selected N =", N);

  # Pick a generator g.
  R = IntegerModRing(N);
  while True:
    g = R.random_element();

    # Optimization: Sample g uniformly at random from Z_N^* \ {1}.
    #
    # For details, see "optimizations.md" and Section 3.2.1 of [E21b].
    if (g == 1) and opt_exclude_one:
      print("\nNote: Sampled g = 1; excluding and sampling again...");
      continue;

    if gcd(g.lift(), N) == 1:
      break;

  print("\nSelected g =", str(g) + "\n");

  # Compute the order r of g.
  print("Computing the order of g, this step may take some time...\n");
  r = g.multiplicative_order();

  print("The order of g is r =", str(r) + "\n");

  # Stop the timer.
  setup_timer.stop();

  # The problem instance has been constructed.
  print("Time required to construct the problem instance:", setup_timer);

  print("\nFinished building the problem instance, solving commences...\n");
  solve_timer = Timer().start();
  factor_completely(r, N, c,
    k = k,
    timeout = timeout,
    opt_split_factors_with_multiplicity =
      opt_split_factors_with_multiplicity,
    opt_report_accidental_factors =
      opt_report_accidental_factors,
    opt_abort_early =
      opt_abort_early,
    opt_square =
      opt_square,
    opt_exclude_one =
      opt_exclude_one,
    opt_process_composite_factors =
      opt_process_composite_factors);
  solve_timer.stop();

  if return_timing_statistics:
    return [setup_timer, solve_timer];

# This function executes the test suite described in Appendix A.3 of [E21b].
#
# If you wish, you may specify k and/or a timeout in seconds. If the number of
# iterations performed by the solver exceeds k, or if the timeout is exceeded,
# an exception of type IncompleteFactorizationException will be raised.
#
# The remaining arguments are optimization flags. They are documented in
# "optimizations.md". It is recommended to use the defaults.
def test_all_appendix_A(
  k = None,
  timeout = None,
  exact = True,
  opt_split_factors_with_multiplicity = True,
  opt_report_accidental_factors = True,
  opt_abort_early = True,
  opt_square = True,
  opt_exclude_one = True,
  opt_process_composite_factors =
    OptProcessCompositeFactors.SEPARATELY_MOD_Np):

  # Setup stopped timers for accumulating timing statistics.
  accumulated_setup_timer = Timer();
  accumulated_solve_timer = Timer();

  # Start a timer.
  timer = Timer().start();

  for l in [256, 512, 1024]:
    for n in [2, 5, 10, 25]:
      for e_max in [1, 2, 3]:
        print("\n ** Running test for l =", str(l) + ", n =", str(n) +
          ", e_max =", str(e_max) + "...\n");

        [setup_timer, solve_timer] = \
          test_of_random_pi_ei(l, n, e_max,
            return_timing_statistics = True,
            k = k,
            timeout = timeout,
            exact = exact,
            opt_split_factors_with_multiplicity =
              opt_split_factors_with_multiplicity,
            opt_report_accidental_factors =
              opt_report_accidental_factors,
            opt_abort_early =
              opt_abort_early,
            opt_square =
              opt_square,
            opt_exclude_one =
              opt_exclude_one,
            opt_process_composite_factors =
              opt_process_composite_factors);

        accumulated_setup_timer += setup_timer;
        accumulated_solve_timer += solve_timer;

  # Stop the timer.
  timer.stop();

  # The tests have been executed.
  print("\n ** Time required to setup and execute all tests:", timer);
  print(" **   Time required to setup all problem instances:",
    accumulated_setup_timer);
  print(" **   Time required to solve all problem instances:",
    accumulated_solve_timer);
