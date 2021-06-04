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
    nnet3-align-compiled $ivector_opts $mdl ark:exp/graphs.fst scp:feats.scp ark:exp/1.ali || exit 1
fi

if [ $stage -le 20 ]; then
    echo "Stage 20: Generating phone transcripts"
    ali-to-phones $mdl ark:exp/1.ali ark,t:exp/text.int
    utils/int2sym.pl -f 2- $phones exp/text.int > exp/trans.phn
    
    python clean-phones.py exp/trans.phn exp/trans_cleaned.phn
    echo "Find phone transcripts at exp/trans_cleaned.phn"
fi