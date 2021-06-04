# Prerequisites

- Trained kaldi nnet3 model, including the following files:
    - final.mdl
    - tree
    - L.fst
    - phones.txt
    - words.txt
    - text
    - scp file for calculated ivectors
    - scp file for MFCC features

# How it works

1. Compile train graphs using the lexicon graph. This graph is specific to the individual sentences which
   leads to better performance than using the entire HCLG graph
2. Use the trained model, train graphs, ivectors, and MFCCs to perform force alignment. This produces `exp/1.ali`
3. Calculate the phone sequences from `exp/1.ali`. And use `clean-phones.py` to remove position dependency and stress

The output will be in `exp/trans_cleaned.txt`

There are other parameters that can be set in [nnet3-align-to-phones.sh](nnet3-align-to-phones.sh)
