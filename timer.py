from time import time;
from math import floor;

# Supporting class to collect timing information.
class Timer:
  # A constant for state management indicating that the timer is stopped.
  STOPPED = 0;

  # A constant for state management indicating that the timer is running.
  RUNNING = 1;

  # Initializes the timer, starting it automatically.
  def __init__(self):
    self.state = Timer.STOPPED;
    self.delta_t = 0;

    self.start();

  # Starts the timer after it has been stopped. If the timer is currently
  # running, calling this function has no effect.
  def start(self):
    if self.state != Timer.STOPPED:
      return;

    self.state = Timer.RUNNING;
    self.t = time();

  # Stops the timer if it is currently running. Returns the time elapsed.
  def stop(self):
    if self.state == Timer.RUNNING:
      self.state = Timer.STOPPED;
      self.delta_t += time() - self.t;

    hours = floor(self.delta_t / 3600);
    mins = floor(self.delta_t / 60) % 60;
    secs = floor(self.delta_t) % 60;
    ms = int(floor((10 ** 3) * self.delta_t)) % (10 ** 3);
    us = int(floor((10 ** 6) * self.delta_t)) % (10 ** 3);

    hr = "";
    if self.delta_t >= 3600:
      hr += str(hours) + " hour";
      if hours > 1:
        hr += "s";
      else:
        hr += " ";

    if self.delta_t >= 60:
      hr += str(mins) + " min ";

    if self.delta_t >= 1:
      hr += str(secs) + " sec ";

    if self.delta_t >= 10 ** -3:
      hr += str(ms) + " ms ";

    hr += str(us) + " µs";

    self.hr = hr;

    return self.hr;

  # Stops the timer if it is running. Then sets the time elapsed to zero.
  def reset(self):
    self.stop();
    self.delta_t = 0;

  # Resets the timer and then immediately starts it again.
  def restart(self):
    self.reset();
    self.start();

  # Peeks at the a running or stopped timer, returning the number of seconds
  # elapsed. For a stopped timer, the time delta is returned. For a running
  # timer, the sum of the time delta and the time offset is returned.
  def peek(self):
    tmp_delta_t = self.delta_t;
    if self.state == Timer.RUNNING:
      tmp_delta_t += time() - self.t;

    return tmp_delta_t;