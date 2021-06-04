set -e

root=/home/storage07/zhangjunbo/src/kaldi/egs/librispeech/s5
mdl=$root/exp/nnet3_cleaned/tdnn_sp/final.mdl
tree=$root/exp/nnet3_cleaned/tdnn_sp/tree
lexfst=$root/data/lang_nosp/L.fst
words=words.txt
phones=phones.txt
text=text
oov='<UNK>'
ivector_period=10
ivector_scp=ivector_online.scp
feats_scp=feats.scp
stage=0

. ./cmd.sh
. ./path.sh
. parse_options.sh

cat ivector_dev_clean.scp ivector_dev_other.scp > ivector_online.scp
cat feats_dev_clean.scp feats_dev_other.scp > feats.scp || exit 1

./nnet3-align-to-phones.sh --stage $stage \
    --mdl $mdl \
    --tree $tree \
    --lexfst $lexfst \
    --phones $phones \
    --words $words \
    --text $text \
    --oov $oov \
    --feats_scp $feats_scp \
    --ivector-period $ivector_period \
    --ivector_scp $ivector_scp
