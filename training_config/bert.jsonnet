local base = import 'base.libsonnet';

// local transformer_model = "google/bert_uncased_L-8_H-512_A-8";
// local transformer_dim = 512;  

local transformer_model = "roberta-base";
local transformer_dim = 768;

local TRANSFORMER_READER_CONFIG = {
    "token_indexers": {
        "tokens": {
            "type": "pretrained_transformer",
            "model_name": transformer_model
        }
    },
    "tokenizer": {
        "type": "pretrained_transformer",
        "model_name": transformer_model
    }
};

local TRANSFORMER_EMBEDDER_CONFIG = {
    "type": "basic_classifier",
    "text_field_embedder": {
        "token_embedders": {
            "tokens": {
                "type": "pretrained_transformer",
                "model_name": transformer_model
            }
        }
    },
    "seq2vec_encoder": {
        "type": "bert_pooler",
        "pretrained_model": transformer_model,
        "dropout": 0.1
    },
};


base.config + {
    "dataset_reader" : base.reader + TRANSFORMER_READER_CONFIG,
    "model": TRANSFORMER_EMBEDDER_CONFIG
}