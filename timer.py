from time import time;
from math import floor;

# Supporting class to collect timing information.
class Timer:
  # Initializes the timer, starting it automatically.
  def __init__(self):
    self.start();

  # Starts the timer after it has been stopped, or re-starts the timer if it
  # is currently running.
  def start(self):
    self.delta_t = None;

    self.t = time();

  # Stops the timer if it is currently running. Returns the time elapsed
  # in-between the points in time that the timer was started and then stopped.
  def stop(self):
    if self.delta_t == None:
      self.delta_t = time() - self.t;

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
