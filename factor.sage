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

    # A set of observed factors to avoid processing the same factor twice.
    self.observed_factors = set();

    # A set of the factors found so far, reduced so that all factors in the set 
    # are pairwise coprime to each other. This property is enforced by add().
    self.found_factors = set();

    # A set of found prime factors.
    self.found_primes = set();

    # Call add() to report N as a factor.
    self.add(N);

  # Checks if all prime factors have been found.
  def is_complete(self):
    return self.residual == 1;

  # Adds a factor to the collection.
  def add(self, d):
    new_factors_queue = [ZZ(d)];

    while new_factors_queue != []:
      # Fetch the next new factor to process.
      d = new_factors_queue.pop();

      # Check that we have not already processed this factor to save time.
      if d in self.observed_factors:
        continue;
      self.observed_factors.add(d);

      # Check if d is a perfect power.
      (d, _) = ZZ(d).perfect_power();

      # Check if d is prime.
      if d.is_prime(proof = False):
          self.found_primes.add(d);

          while self.residual % d == 0:
            self.residual /= d;
      
      # Add the factor the list of found factors.
      self.found_factors.add(d);

      # Reduce down the factors by taking pairwise greatest common divisors, 
      # whilst keeping track of any new factors generated.
      while True:
        # Take pairwise D = gcd() between all factors. Break if D != 1.
        D = 1;

        for f1 in self.found_factors:
          if D != 1:
            break;

          for f2 in self.found_factors:
            if f1 == f2:
              continue;

            D = gcd(f1, f2);
            if D != 1:
              break;

        # If D = 1 at the end of the procedure, then all factors are pairwise 
        # coprime, so we can stop iterating.
        if D == 1:
          break;

        # We have found a new factor D.
        new_factors_queue.append(D);

        # Divide off D from all factors that are divisible by D.
        tmp = set();
        tmp.add(D);

        for f in self.found_factors:
          x = f;
          while gcd(x, D) > 1:
            x /= gcd(x, D);

          if x > 1:
            tmp.add(x);

            if x != f:
              # We have found a new factor x.
              new_factors_queue.append(x);

        self.found_factors = tmp;

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

  # Start a timer.
  timer = Timer();

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
    # after the first run, and is explained in section 2.1.
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
    tmp = x^o;

    # Step 4.2.1 for i = 0.
    d = gcd((tmp - 1).lift(), N);
    if d not in [1, N]:
      F.add(d);

    for i in range(1, t + 1):
      if tmp == 1:
        break; # No point in continuing. If we square again, we get one again.

      tmp = tmp^2;

      # Step 4.2.1 for i = 1, .., t.
      d = gcd((tmp - 1).lift(), N);
      if d not in [1, N]:
        F.add(d);

  # The complete factorization has been found.
  print("Time required to solve:", timer.stop());

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