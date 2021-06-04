set -e

. ./cmd.sh
. ./path.sh
. parse_options.sh

root=/home/storage07/zhangjunbo/src/kaldi/egs/librispeech/s5
mdl=$root/exp/nnet3_cleaned/tdnn_sp/final.mdl
tree=$root/exp/nnet3_cleaned/tdnn_sp/tree
lexfst=$root/data/lang_nosp/L.fst
words=words.txt
text=text
oov='<UNK>'
ivector_period=10
ivector_opts="--online-ivectors=scp:ivector_online.scp --online-ivector-period=$ivector_period"

cat ivector_dev_clean.scp ivector_dev_other.scp > ivector_online.scp
cat feats_dev_clean.scp feats_dev_other.scp > feats.scp || exit 1

sym2int.pl -f 2- --map-oov $oov $words $text > text.int || exit 1

compile-train-graphs $tree $mdl $lexfst ark:text.int ark:graphs.fst || exit 1
nnet3-align-compiled $ivector_opts $mdl ark:graphs.fst scp:feats.scp ark:1.ali || exit 1
