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
nj=200

. ./cmd.sh
. ./path.sh
. parse_options.sh

ivector_opts="--online-ivectors=scp:$ivector_scp --online-ivector-period=$ivector_period"

mkdir -p exp/log

if [ $stage -le 0 ]; then
    echo "Stage 1: Compiling train graphs"

    split_dir=exp/split$nj
    python3 split_text.py $text $nj $split_dir

    tra="ark:utils/sym2int.pl -f 2- --map-oov '$oov' $words $split_dir/text.JOB |"
    $cmd JOB=1:$nj exp/log/compile_graphs.JOB.log  \
      compile-train-graphs $tree $mdl $lexfst "$tra" ark:exp/graphs.JOB.fst || exit 1
fi

if [ $stage -le 10 ]; then
    echo "Stage 10: Performing force alignment"

    $cmd JOB=1:$nj exp/log/nnet3_align_compiled.JOB.log  \
      nnet3-align-compiled $ivector_opts \
        --use-gpu=no \
        --beam=$beam \
        --retry-beam=$retry_beam \
        $mdl \
        ark:exp/graphs.JOB.fst \
        scp:$feats_scp ark:exp/JOB.ali \
        || exit 1
fi

if [ $stage -le 20 ]; then
    echo "Stage 20: Generating phone transcripts"
    $cmd JOB=1:$nj exp/log/ali_to_phones.JOB.log  \
      ali-to-phones $mdl ark:exp/JOB.ali ark,t:exp/trans.JOB.int

    cat exp/trans.*.int > exp/trans.int
    utils/int2sym.pl -f 2- $phones exp/trans.int > exp/trans.txt
    
    python clean-phones.py exp/trans.txt exp/trans_cleaned.txt
    echo "Find phone transcripts at exp/trans_cleaned.txt"
fi
