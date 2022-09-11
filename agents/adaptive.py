from gym.spaces import MultiDiscrete
from network.base_station import BaseStation as BS
from env.config import timeStep, actionInterval

class AdaptivePolicy:
    pre_sm2_time = 0.01
    ue_stats_start = BS.public_obs_ndims + BS.private_obs_ndims - 11
    act_interval = timeStep * actionInterval

    def __init__(self, action_space, num_agents):
        self.act_space = action_space
        self.num_agents = num_agents
        self._sleep_timer = 0

    def act(self, obs):
        def single_act(obs):
            s = self.ue_stats_start
            sm = list(obs[2:6]).index(1)
            next_sm = list(obs[6:10]).index(1)
            wakeup_time = obs[10]
            arrival_rate = obs[s-1]
            thrp_other = obs[s+4]
            thrp_req = obs[s+5] + obs[s+6]
            thrp_req_idle = obs[s+7]
            thrp_log_ratio = obs[s+9]
            thrp_log_ratio_other = obs[s+10]
            new_sm = sm
            ant_switch = 2
            if sm:
                conn_mode = 1
                self._sleep_timer += self.act_interval
                if sm != next_sm:
                    pass
                elif thrp_req_idle or thrp_log_ratio_other < 0:  # wakeup
                    new_sm = 0
                    ant_switch = 4  # +16
                    if wakeup_time <= 3e-3:
                        conn_mode = 2
                elif sm == 1:
                    if self._sleep_timer >= self.pre_sm2_time:
                        new_sm = 2
                        ant_switch = 0  # -16
                elif sm > 1:
                    if thrp_other < arrival_rate * 1.2:
                        new_sm = 1
                        ant_switch = 4
            else:
                conn_mode = 2
                self._sleep_timer = 0
                if thrp_req == 0:
                    new_sm = 1
                    conn_mode = 0
                elif thrp_log_ratio_other < 0:
                    ant_switch = 3  # +4
                elif thrp_log_ratio > 1:
                    ant_switch = 1  # -4
            return [ant_switch, new_sm, conn_mode]
        return [single_act(ob) for ob in obs]
