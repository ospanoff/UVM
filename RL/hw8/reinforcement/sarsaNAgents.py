# qlearningAgents.py
# ------------------
# Licensing Information:  You are free to use or extend these projects for
# educational purposes provided that (1) you do not distribute or publish
# solutions, (2) you retain this notice, and (3) you provide clear
# attribution to UC Berkeley, including a link to http://ai.berkeley.edu.
#
# Attribution Information: The Pacman AI projects were developed at UC Berkeley.
# The core projects and autograders were primarily created by John DeNero
# (denero@cs.berkeley.edu) and Dan Klein (klein@cs.berkeley.edu).
# Student side autograding was added by Brad Miller, Nick Hay, and
# Pieter Abbeel (pabbeel@cs.berkeley.edu).


from game import *
from learningAgents import ReinforcementAgent
from featureExtractors import *

import random,util,math

class SARSANLearningAgent(ReinforcementAgent):
    """
      Q-Learning Agent

      Functions you should fill in:
        - computeValueFromQValues
        - computeActionFromQValues
        - getQValue
        - getAction
        - update

      Instance variables you have access to
        - self.epsilon (exploration prob)
        - self.alpha (learning rate)
        - self.discount (discount rate)

      Functions you should use
        - self.getLegalActions(state)
          which returns legal actions for a state
    """
    def __init__(self, **args):
        self.nstep = args.pop('sarsa_n')
        "You can initialize Q-values here..."
        ReinforcementAgent.__init__(self, **args)

        self.Q = util.Counter()
        self.hist = []

        print self.nstep

    def getQValue(self, state, action):
        """
          Returns Q(state,action)
          Should return 0.0 if we have never seen a state
          or the Q node value otherwise
        """
        return self.Q[(state, action)]


    def computeValueFromQValues(self, state):
        """
          Returns max_action Q(state,action)
          where the max is over legal actions.  Note that if
          there are no legal actions, which is the case at the
          terminal state, you should return a value of 0.0.
        """
        action = self.computeActionFromQValues(state)
        if action == None:
            return 0.0
        else:
            return self.getQValue(state, action)

    def computeActionFromQValues(self, state):
        """
          Compute the best action to take in a state.  Note that if there
          are no legal actions, which is the case at the terminal state,
          you should return None.
        """
        a_best = []
        Q_best = -float('inf')
        for a in self.getLegalActions(state):
            Q = self.getQValue(state, a)
            if Q > Q_best:
                a_best = [a]
                Q_best = Q

            elif abs(Q - Q_best) < 1e-20:
                a_best += [a]

        return random.choice(a_best) if a_best else None

    def getAction(self, state):
        """
          Compute the action to take in the current state.  With
          probability self.epsilon, we should take a random action and
          take the best policy action otherwise.  Note that if there are
          no legal actions, which is the case at the terminal state, you
          should choose None as the action.

          HINT: You might want to use util.flipCoin(prob)
          HINT: To pick randomly from a list, use random.choice(list)
        """
        # Pick Action
        if util.flipCoin(self.epsilon):
            return random.choice(self.getLegalActions(state))
        else:
            return self.computeActionFromQValues(state)

    def sarsa_step(self):
        G = 0

        for i, (s, a, r) in enumerate(self.hist):
            G += (self.discount ** i) * r
        s, a, _ = self.hist[-1]  # the last state action in history
        G += (self.discount ** self.nstep) * self.Q[(s, a)]

        s, a, _ = self.hist[0]  # state, action we update
        self.Q[(s, a)] += self.alpha * (G - self.Q[(s, a)])
        self.hist = self.hist[1:]

    def update(self, state, action, nextState, reward):
        """
          The parent class calls this to observe a
          state = action => nextState and reward transition.
          You should do your Q-Value update here

          NOTE: You should never call this function,
          it will be called on your behalf
        """
        self.hist += [(state, action, reward)]

        if len(self.hist) == self.nstep:
            self.sarsa_step()

        if nextState == 'TERMINAL_STATE':
            while len(self.hist):
                self.sarsa_step()

    def getPolicy(self, state):
        return self.computeActionFromQValues(state)

    def getValue(self, state):
        return self.computeValueFromQValues(state)


class PacmanSARSAAgent(SARSANLearningAgent):
    "Exactly the same as QLearningAgent, but with different default parameters"

    def __init__(self, epsilon=0.05,gamma=0.8,alpha=0.2, numTraining=0, **args):
        """
        These default parameters can be changed from the pacman.py command line.
        For example, to change the exploration rate, try:
            python pacman.py -p PacmanQLearningAgent -a epsilon=0.1

        alpha    - learning rate
        epsilon  - exploration rate
        gamma    - discount factor
        numTraining - number of training episodes, i.e. no learning after these many episodes
        """
        args['epsilon'] = epsilon
        args['gamma'] = gamma
        args['alpha'] = alpha
        args['numTraining'] = numTraining
        self.index = 0  # This is always Pacman
        SARSANLearningAgent.__init__(self, **args)

    def getAction(self, state):
        """
        Simply calls the getAction method of QLearningAgent and then
        informs parent of action for Pacman.  Do not change or remove this
        method.
        """
        action = SARSANLearningAgent.getAction(self,state)
        self.doAction(state,action)
        return action


