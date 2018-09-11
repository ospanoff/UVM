import numpy as np
import matplotlib.pyplot as plt


class Bandits:
    def __init__(self, n_bandits, q_mean=0.0, q_std=1.0, r_std=1.0,
                 rw_mean=0.0, rw_std=0.01):
        self.rw_mean = rw_mean  # random walk mean
        self.rw_std = rw_std  # random walk std

        self.n_bandits = n_bandits

        self.bandits = np.random.normal(
            loc=q_mean, scale=q_std, size=self.n_bandits
        )  # reward mean or q*
        # self.bandits = np.repeat(np.random.normal(loc=q_mean, scale=q_std),
        #                          self.n_bandits)  # the case of equal init
        self.r_std = r_std  # reward std

    def random_walk(self):
        self.bandits += np.random.normal(self.rw_mean, self.rw_std,
                                         self.n_bandits)

    def get_reward(self, i_bandit):
        return np.random.normal(self.bandits[i_bandit], self.r_std)

    def is_optimal(self, i_bandit):
        return (self.bandits == self.bandits.max())[i_bandit]


class KArmedBandits:
    def __init__(self, n_bandits=10, n_runs=1000, n_steps=1000,
                 eps=0.1, alpha=0.1, method='sa'):
        """
        :param n_bandits: number of bandits
        :param n_runs: number of runs
        :param n_steps: number of steps within a run
        :param eps: eps for eps-greedy step
        :param alpha: alpha is the step size for 'cs' type. see 'type' param
        :param method: 'sa' - sample average, 'cs' - constant step
        """
        self.n_bandits = n_bandits
        self.n_runs = n_runs
        self.n_steps = n_steps

        self.eps = eps
        self.alpha = alpha

        self.method = method

    def run(self):
        print('Starting the algorithm with {} type of action-value method'
              .format(self.method))
        R_avg = np.zeros(self.n_steps)
        optimal_action_rate = np.zeros(self.n_steps)
        for run_num in range(self.n_runs):
            bandits = Bandits(self.n_bandits)

            Q = np.zeros(self.n_bandits)
            n = np.zeros(self.n_bandits)

            for step in range(self.n_steps):
                bandit_i = np.argmax(Q) if np.random.uniform() > self.eps \
                    else np.random.choice(self.n_bandits)

                R = bandits.get_reward(bandit_i)
                n[bandit_i] += 1

                if self.method == 'sa':
                    self.alpha = 1 / n[bandit_i]

                Q[bandit_i] += self.alpha * (R - Q[bandit_i])

                R_avg[step] += R
                optimal_action_rate[step] += bandits.is_optimal(bandit_i)

                bandits.random_walk()

            print('\rRun #{}/{}: {:.2f}%'.format(run_num + 1, self.n_runs,
                  100. * (run_num + 1) / self.n_runs), end='')
        print()

        return R_avg / self.n_runs, optimal_action_rate / self.n_runs


if __name__ == '__main__':
    n_step = 5000

    algo = KArmedBandits(n_steps=n_step)
    R_avg_sa, rate_sa = algo.run()

    algo = KArmedBandits(n_steps=n_step, method='cs')
    R_avg_cs, rate_cs = algo.run()

    plt.subplot(211)
    plt.plot(R_avg_sa, label='Sample average')
    plt.plot(R_avg_cs, label='Constant rate')
    plt.xlabel('Steps')
    plt.ylabel('Average reward')
    plt.legend(loc='best')

    plt.subplot(212)
    plt.plot(rate_sa, label='Sample average')
    plt.plot(rate_cs, label='Constant rate')
    plt.xlabel('Steps')
    plt.ylabel('Optimal action rate')
    plt.legend(loc='best')

    plt.show()
