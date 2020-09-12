local base = import 'base.libsonnet';

local BASIC_EMBEDDER_CONFIG = {
    "type": "basic_classifier",
    "text_field_embedder": {
        "token_embedders": {
            "tokens": {
                "type": "embedding",
                "embedding_dim": 500
            }
        }
    },
    "seq2vec_encoder": {
        "type": "bag_of_embeddings",
        "embedding_dim": 500
    }
};

base.config + {
    "dataset_reader" : base.reader,
     "model": BASIC_EMBEDDER_CONFIG
}