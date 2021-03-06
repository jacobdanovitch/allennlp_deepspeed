from typing import Union, Dict, Any, NamedTuple
from copy import deepcopy

import os
import json
import tempfile
import logging

import torch
from deepspeed.utils import logger as ds_logger
ds_logger.setLevel(logging.WARNING)
ds_logger.propagate = False
import deepspeed

from allennlp.common import Params, FromParams

JsonDict = Dict[str, Any]

class DeepspeedConfig(FromParams):
    def __init__(
        self,
        optimizer: JsonDict,
        fp16: JsonDict = {'enabled': False},
        amp:  JsonDict = {'enabled': False},
        zero_optimization: Union[bool, Dict] = False,
        zero_allow_untested_optimizer: bool = True
    ):
        self.optimizer = optimizer
        self.fp16 = fp16
        self.amp = amp
        self.zero_optimization = zero_optimization
        self.zero_allow_untested_optimizer = zero_allow_untested_optimizer

    @staticmethod
    def build_deepspeed_args(deepspeed_config_path: str, local_rank: int = 0):
        from argparse import ArgumentParser, Namespace
        parser = ArgumentParser()
        parser.add_argument('--local_rank', type=int, default=local_rank)
        parser = deepspeed.add_config_arguments(parser)

        args, _ = parser.parse_known_args()
        arg_dict = vars(args)

        arg_dict.update(dict(deepspeed_config=deepspeed_config_path, deepspeed=True, local_rank=local_rank))
        return Namespace(**arg_dict)

    @property
    def config(self):
        # return {
        #     'fp16': self.fp16,
        #     'amp': self.amp,
        #     'zero_optimization': self.zero_optimization,
        #     'zero_allow_untested_optimizer': self.zero_allow_untested_optimizer
        # }
        return vars(self)

    def _to_temp_file(self, serialization_dir, **kwargs):
        fd, path = tempfile.mkstemp(dir=serialization_dir)
        
        config = {**self.config, **kwargs}
        with os.fdopen(fd, 'w') as f:
            f.write(json.dumps(config))

        return path

    def launch(
        self,
        model: torch.nn.Module,
        optimizer: Union[str, torch.optim.Optimizer],
        local_rank: int, 
        serialization_dir: str,
        batch_size: int, 
        gradient_accumulation_steps: int
    ):
        path = self._to_temp_file(serialization_dir, train_batch_size=batch_size, gradient_accumulation_steps=gradient_accumulation_steps)
        ds = deepspeed.initialize(
            args=self.build_deepspeed_args(path, local_rank),
            model=model,
            model_parameters=model.parameters(),
            dist_init_required=False
        )

        os.remove(path)
        return ds