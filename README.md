# Pathfinding with Q-Learning

Built in Apple's Swift programming language, we have developed a simple application that solves mazes with enemies and treasures, that is easily portable across the various Apple platforms. 

## Strategy

We decided to utilize the Q-Learning strategy for solving our maze, which essentially combines a hash table of states, where each value is a hash table of actions, that are each associated with some particular value based on how good that action is expected to be. The "Q-Table" is first randomly populated with values, then tuned and calibrated through a series of steps through the maze, which may be random, or the best known step with current information. The result of each step then issues a specially-weighted recalculation of value, based on tuning variables that we can control.

## Implementation

As always, we decided to challenge ourselves to a new environment for this project, one that we were both unfamiliar with. For this project, that meant coding in Swift via Xcode. To begin, we utilized Apple's [open-source example](https://developer.apple.com/library/archive/samplecode/Pathfinder_GameplayKit/Introduction/Intro.html#//apple_ref/doc/uid/TP40016461) for pathfinding, and then modified it to add treasures, enemies, and our own bespoke Q-Learning pathfinding algorithm.

## Roadblocks and Challenges

While it was relatively easy to get our Q-Learning algorithm to correctly find its way from point A to point B in an empty maze, we repeatedly had infinite-looping issues once we introduced treasures and enemies. Our algorithm would either be "too scared" to confront an enemy it literally must confront to complete the maze, or it would end up going back and forth chasing a "shadow treasure", a treasure that was once there, but has already been collected.

We ended up resolving this issue by constructing a more complete concept of "state" for our maze, which included both the collected treasures and confronted enemies at each point in time. Initially, this was horrendously inefficient. We don't have the exact data, but it is very much possible that our initialization algorithm for our Q-Table was on the order of O((N^2)!) or worse... After a little bit of thought however, it turned out that this was easy enough to move to more of a "make it as you need it" strategy, which provided at least two orders of magnitude of performance enhancement in our basic testing.

## Examples

## Conclusion
