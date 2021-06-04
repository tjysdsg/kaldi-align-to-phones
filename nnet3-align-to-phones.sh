set -e

mdl=
tree=
lexfst=
phones=
words=
text=
oov='<UNK>'
ivector_period=
ivector_scp=
feats_scp=
beam=10
retry_beam=40

stage=0

. ./cmd.sh
. ./path.sh
. parse_options.sh

ivector_opts="--online-ivectors=scp:$ivector_scp --online-ivector-period=$ivector_period"

mkdir -p exp

if [ $stage -le 0 ]; then
    echo "Stage 1: Compiling train graphs"
    sym2int.pl -f 2- --map-oov $oov $words $text > exp/text.int || exit 1
    compile-train-graphs $tree $mdl $lexfst ark:exp/text.int ark:exp/graphs.fst || exit 1
fi

if [ $stage -le 10 ]; then
    echo "Stage 10: Performing force alignment"
    nnet3-align-compiled $ivector_opts \
        --beam=$beam \
        --retry-beam=$retry_beam \
        $mdl \
        ark:exp/graphs.fst \
        scp:$feats_scp ark:exp/1.ali \
        || exit 1
fi

if [ $stage -le 20 ]; then
    echo "Stage 20: Generating phone transcripts"
    ali-to-phones $mdl ark:exp/1.ali ark,t:exp/trans.int
    utils/int2sym.pl -f 2- $phones exp/trans.int > exp/trans.txt
    
    python clean-phones.py exp/trans.txt exp/trans_cleaned.txt
    echo "Find phone transcripts at exp/trans_cleaned.txt"
fi
