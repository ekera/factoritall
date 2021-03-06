# ------------------------------------------------------------------------------
# This Sage script implements the procedure described in the paper:
# 
# [E20] Ekerå, M.: "On completely factoring any integer efficiently in a single 
#                   run of an order finding algorithm" (2020).
#
# Use factor_completely(r, N, c = 1) to solve for r the order and N the integer.

from timer import Timer;

# Supporting class to collect the non-trivial factors of N on reduced form.
class FactorCollection:
  def __init__(self, N):
    # The number N to be factored.
    self.N = N;

    # The residual factor. Initially set to N.
    self.residual = N;

    # A set of the factors found so far, reduced so that all factors in the set 
    # are pairwise coprime to each other. This property is enforced by add().
    self.found_factors = set();

    # A set of found prime factors.
    self.found_primes = set();

    # A timer for measuring the time spent performing primality tests.
    self.timer_test_primality = Timer();
    self.timer_test_primality.reset();

    # A timer for measuring the time spent detecting perfect powers.
    self.timer_test_perfect_power = Timer();
    self.timer_test_perfect_power.reset();

    # Call add() to report N as a factor.
    self.add(N);

  # Checks if all prime factors have been found.
  def is_complete(self):
    return self.residual == 1;

  # Adds a factor to the collection.
  def add(self, d):
    # Check that the factor is non-trivial and has not already been found.
    if (d == 1) or (d in self.found_factors):
      return;

    # Test if d shares a factor with any of the factors found. All factors 
    # found are co-prime, so d can at most share a factor with one of them.
    D = 1;

    for f in self.found_factors:
      D = gcd(f, d);

      if D != 1:
        break;

    if D != 1:
      # Remove the factor, split it and add the resulting factors.
      self.found_factors.remove(f);

      f /= D;
      d /= D;

      self.add(D);

      if f != 1:
        self.add(f);

      if d != 1:
        self.add(d);
    else:
      # Check if d is a perfect power and if so reduce d.
      self.timer_test_perfect_power.start();
      (d, _) = ZZ(d).perfect_power();
      self.timer_test_perfect_power.stop();

      # Check if d is prime and if so register it and reduce the residual.
      self.timer_test_primality.start();
      result = d.is_prime(proof = False);
      self.timer_test_primality.stop();

      if result:
        self.found_primes.add(d);

        while self.residual % d == 0:
          self.residual /= d;

      # Add in the factor.
      self.found_factors.add(d);

  def __repr__(self):
    return "Factors: " + str(self.found_factors);

# ------------------------------------------------------------------------------
# Solves a problem instance given by r and N.
#
# The parameter c is as described in [E20]. The parameter k in [E20] need not be
# explicitly specified: As many iterations k as are necessary to completely 
# factor N will be performed. The algorithm will then stop.
# 
# This function returns the set of all distinct prime factors that divide N.
def factor_completely(r, N, c = 1):

  # Supporting function to build the product of q^e, for q all primes <= B and e 
  # the largest exponent such that q^e <= B for B some bound.
  def build_prime_power_product(B):
    factor = 1;

    for q in primes(B + 1):
      e = 1;
      while q^(e + 1) <= B:
        e += 1;
      factor *= q^e;

    return factor;

  # Supporting function for computing t such that x = 2^t o for o odd.
  def kappa(x):
    if x == 0:
      return 0;

    k = 0;

    while (x % 2) == 0:
      k += 1;
      x /= 2;

    return k;

  # Note: Step 1 is already completed.
  r = ZZ(r);
  N = ZZ(N);
  m = N.nbits();

  # Setup and start a timer to measure the total time required to solve.
  timer = Timer();

  # Setup and reset a timer to measure the time spent exponentiating.
  timer_exponentiation = Timer();
  timer_exponentiation.reset();

  # Step 2: Build the product of prime factors q^e < cm and multiply onto r.
  rp = build_prime_power_product(c * m) * r;

  # Step 3: Let rp = 2^t o for o odd.
  t = kappa(rp);
  o = rp / 2^t;

  # Define a pairwise coprime set and add in N.
  F = FactorCollection(N);

  # Step 4: For j = 1, 2, ... up to k where k is unbounded.
  j = 0;

  while True:
    # Print current status information before proceeding.
    print("Iteration:", j);
    print("Found factors:", len(F.found_factors));
    print("Found primes:", len(F.found_primes));
    
    found_factors = list(F.found_factors);
    found_factors.sort();
  
    for i in range(len(found_factors)):
      print(" Factor " + str(i) + ":", found_factors[i]);
    print("");

    # Check if we're done...
    if F.is_complete():
      break;

    # Increment j for the next iteration.
    j += 1;

    # Step 4.1: Select x uniformly at random from Z_N^*.
    #
    # Note that as an optimization, we select from Z_N'^* where N' is N with all
    # prime factors in found this far divided up. This speeds up the arithmetic 
    # after the first run, and is explained in section 3.2.1.
    while True:
      x = IntegerModRing(F.residual).random_element();
      if gcd(x.lift(), F.residual) == 1:
        break;

      # N.B.: This point is reached when x_j is not in Z_N'^*. In an optimized 
      # implementation we would check if d is non-zero and if so add d to F, but
      # we avoid doing so here to avoid checking if F is complete and breaking 
      # both in this inner loop and multiple times in the outer loop.

    # Step 4.2: For i = 0, 1, .., t do:
    # 
    # Note that further speed up the arithmetic, we use a temporary variable, 
    # that we initially set to x^o and then square repeatedly, as opposed to
    # computing x^(2^i o) in each iteration.
    timer_exponentiation.start();
    tmp = x^o;
    timer_exponentiation.stop();

    # Step 4.2.1 for i = 0.
    d = gcd((tmp - 1).lift(), N);
    if 1 < d < N:
      F.add(d);

    for i in range(1, t + 1):
      if tmp == 1:
        break; # No point in continuing. If we square again, we get one again.

      timer_exponentiation.start();
      tmp = tmp^2;
      timer_exponentiation.stop();

      # Step 4.2.1 for i = 1, .., t.
      d = gcd((tmp - 1).lift(), N);
      if 1 < d < N:
        F.add(d);

  # The complete factorization has been found.
  print("Time required to solve:", timer.stop());
  print(" Time spent exponentiating:", timer_exponentiation.stop());
  print(" Time spent checking primality:", F.timer_test_primality.stop());
  print(" Time spent reducing perfect powers:", F.timer_test_perfect_power.stop());

  # Sanity check to assert that the factorization is correct and complete.
  tmp = N;

  for f in F.found_primes:
    if (tmp % f) != 0:
      raise Exception("Error: Failed to factor N correctly.");

    tmp /= f;
    while (tmp % f) == 0:
      tmp /= f;

  if tmp != 1:
    raise Exception("Error: Failed to completely factor N.");

  # Return the set of prime factors found.
  return F.found_primes;