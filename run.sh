set -e

subset=train  # train test dev
root=/home/storage07/zhangjunbo/src/kaldi/egs/librispeech/s5
mdl=$root/exp/nnet3_cleaned/tdnn_sp/final.mdl
tree=$root/exp/nnet3_cleaned/tdnn_sp/tree

lang=data/lang_nosp
lexfst=$lang/L.fst
words=$lang/words.txt
phones=$lang/phones.txt
oov='<UNK>'
ivector_period=10

text=exp/text
ivector_scp=exp/ivector_online.scp
feats_scp=exp/feats.scp

stage=0

. ./cmd.sh
. ./path.sh
. parse_options.sh

if [ "$subset" = "train" ]; then
  cat ivector_train_960.scp > $ivector_scp
  cat feats_train_960.scp > $feats_scp
  cat text_train_960 > $text
else
  cat ivector_${data}_clean.scp ivector_${data}_other.scp > $ivector_scp
  cat feats_${data}_clean.scp feats_${data}_other.scp > $feats_scp
  cat text_${data}_clean text_${data}_other > $text
fi

if [ $stage -le 1 ]; then
  ./prepare-fst.sh
fi

if [ $stage -le 2 ]; then
  ./nnet3-align-to-phones.sh --stage $stage \
      --mdl $mdl \
      --tree $tree \
      --lexfst $lexfst \
      --phones $phones \
      --words $words \
      --oov $oov \
      --ivector-period $ivector_period \
      --text $text \
      --feats_scp $feats_scp \
      --ivector_scp $ivector_scp
fi
