local GRADIENT_DESCENT = {
    "optimizer": "adam",
    "num_epochs": 5
};

local DEEPSPEED = GRADIENT_DESCENT + {
    "type": "deepspeed",
    "deepspeed_config": {
        "optimizer": {
            "type": "Adam",
            "params": {
                "lr": 0.00001
            }
        },
        "fp16": { "enabled": true },
        "zero_optimization": {
            "stage": 2
        }
    },
};

{
    "config": {
        "train_data_path": "https://allennlp.s3.amazonaws.com/datasets/sst/train.txt",
        "validation_data_path": "https://allennlp.s3.amazonaws.com/datasets/sst/dev.txt",
        "data_loader": {
            "batch_size": 64,
            "shuffle": true
        },
        "distributed": {
            "cuda_devices": [0, 1]
        },
        "trainer": GRADIENT_DESCENT
        // "trainer": DEEPSPEED
    },
    "reader": {
        "type": "sst_tokens",
        "granularity": "2-class",
        "max_instances": 10000
    },
}