
### Installation

Use `install_deepspeed.sh` to install deepspeed

### Usage

```shell
# simple bag-of-embeddings model
allennlp train training_config/simple.jsonnet -s chkpt -f

# transformer model
allennlp train training_config/bert.jsonnet -s chkpt -f
```

### Initial Benchmarks

DS: 4184 / 4348, 46.91s
GD: 8936 / 10202, 20.40s