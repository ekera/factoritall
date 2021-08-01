# ------------------------------------------------------------------------------
# This Sage script implements tests for the procedure described in the paper:
#
# [E21b] Ekerå, M.: "On completely factoring any integer efficiently in a single 
#                    run of an order-finding algorithm".
#                   Quantum Inf. Process. 20(6):205 (2021).

from timer import Timer;

# ------------------------------------------------------------------------------
# Tests the implementation of the factoring algorithm.

# This function will first select n distinct l bit odd prime numbers pi
# uniformly at random, and n exponents ei uniformly at random from [1, e_max].
# It will then compute N = p1^e1 * .. * pn^en, select g uniformly at random from
# the multiplicative group of the ring of integers modulo N, and heuristically
# determine the order r of g using the method described in Appendix A of [E21b].
#
# Finally, it will call the solver for r and N passing along the constant c.
def test_heuristic_of_random_pi_ei(l = 1024, n = 2, e_max = 1, c = 1,
  Bs = 10^6, sanity_check = False,
  k = None,
  timeout = None):

  # Function to select an odd prime uniformly at random from [2^(l-1), 2^l).
  def generate_prime(l):
    R = IntegerModRing(2^(l-1));

    while True:
      p = 2^(l-1) + ZZ(R.random_element().lift());
      if (p % 2) == 0:
        continue; # Explicitly exclude 2. Only relevant when l = 2.
      if p.is_prime(proof = False):
        return p;

  # Rudimentary sanity checks for the parameters passed to this function.
  if (n < 2) or (e_max < 1) or (c < 1) or (l <= 0) or (Bs < 10^3):
    raise Exception("Error: Incorrect parameters: It is required that " +
      "n >= 2, e_max >= 1, c >= 1, l > 0 and Bs >= 10^3.");

  if l <= 16:
    count = len([f for f in primes(2^(l-1), 2^l)]);
    if l == 2:
      count -= 1; # Exclude 2 since this prime is not odd.
    if n > count:
      raise Exception("Error: Incorrect parameters: Ran out of primes: "
        "There are less than " + str(n) + " odd l bit primes.");

  # Start a timer.
  timer = Timer();

  # Randomly select m distinct prime factors for N of length n bits.
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

  # Select g quickly by picking gi from each cyclic subgroup, computing its 
  # order, and composing under the CRT. This avoids exponentiating modulo N.
  ris = [];
  gis = [];
  mds = [];

  P = [f for f in primes(Bs + 1)];

  for i in range(len(factors)):
    [pi, ei] = factors[i];

    print("Processing subgroup " + str(i) + ": " + str(pi) + "^" + str(ei));

    Ri = IntegerModRing(pi^ei);
    while True:
      gi = Ri.random_element();
      if gcd(gi.lift(), pi) == 1:
        break;

    ri = pi^(ei - 1) * (pi - 1);
    
    ri_base = ri;
    ri = 1;

    for f in P:
      while ((ri_base % f) == 0) and (ri_base != 0):
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
  r = lcm(ris); # order of g

  if sanity_check:
    if g^r != 1:
      raise Exception("Error: The order is incorrectly approximated.");
    
    for f in primes(Bs + 1):
      if r % f == 0:
        if g^(r / f) == 1:
          raise Exception("Error: The order is incorrectly approximated.");
  
  r_max = lcm([p^(e-1) * (p-1) for [p, e] in factors]);

  print("\nSelected g = " + str(g));
  print("\nThe order of g is approximated as r =", r);
  print("\nThe maximal order is lambda(N) =", r_max);
  print("\nThe fraction lambda(N) / r = " + str(factor(r_max / r)) + "\n");

  # The problem instance has been constructed.
  print("Time required to construct problem instance:", timer.stop());

  print("\nFinished building the problem instance, solving commences...\n");
  factor_completely(r, N, c,
    k = k,
    timeout = timeout);

# This function will first select N uniformly at random from the set of all m 
# bit composites, where it is required that m be in [8, 224]. It will then 
# select g uniformly at random from the multiplicative group of the ring of 
# integers modulo N, and compute the order r of g exactly classically by 
# factoring N = p1^e1 * .. * pn^en and then factoring pi - 1 for i in [1, n]
# using functions native to Sage.
# 
# Finally, it will call the solver for r and N passing along the constant c.
def test_exact_of_random_N(m = 192, c = 1,
  k = None,
  timeout = None):

  # Sanity checks.
  if m < 8:
    raise Exception("Error: Select a larger m.");

  if m > 224:
    raise Exception("Error: It may take a long time to factor an m = " + 
      str(m) + " bit integer N. Select a smaller m.");

  # Start a timer.
  timer = Timer();

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
    if gcd(g.lift(), N) == 1:
      break;

  print("\nSelected g =", str(g) + "\n");

  # Compute the order r of g.
  print("Computing the order of g, this step may take some time...\n");
  r = g.multiplicative_order();

  print("The order of g is r =", str(r) + "\n");
  
  # The problem instance has been constructed.
  print("Time required to construct problem instance:", timer.stop());

  print("\nFinished building the problem instance, solving commences...\n");
  factor_completely(r, N, c,
    k = k,
    timeout = timeout);

# This function executes the test suite described in Appendix A.3 of [E21b].
def test_all_appendix_A(
  k = None,
  timeout = None):

  # Start a timer.
  timer = Timer();

  for l in [256, 512, 1024]:
    for n in [2, 5, 10, 25]:
      for e_max in [1, 2, 3]:
        print("\n ** Running test for l =", str(l) + ", n =", str(n) + \
          ", e_max =", str(e_max) + "...\n");
        test_heuristic_of_random_pi_ei(l, n, e_max,
          k = k,
          timeout = timeout);

  # The tests have been executed.
  print("\n ** Time required to execute all tests:", timer.stop());