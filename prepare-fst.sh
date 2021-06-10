lexicon_raw_nosil=resource/lexicon.txt
dict_dir=data/local/dict_nosp
stage=0

. ./cmd.sh
. ./path.sh
. parse_options.sh

mkdir -p $dict_dir

if [ $stage -le 1 ]; then
  silence_phones=$dict_dir/silence_phones.txt
  optional_silence=$dict_dir/optional_silence.txt
  nonsil_phones=$dict_dir/nonsilence_phones.txt
  extra_questions=$dict_dir/extra_questions.txt

  echo "Preparing phone lists and clustering questions"
  (echo SIL; echo SPN;) > $silence_phones
  echo SIL > $optional_silence
  # nonsilence phones; on each line is a list of phones that correspond
  # really to the same base phone.
  cp resource/nonsilence_phones.txt $nonsil_phones || exit 1;
  # A few extra questions that will be added to those obtained by automatically clustering
  # the "real" phones.  These ask about stress; there's also one for silence.
  cat $silence_phones| awk '{printf("%s ", $1);} END{printf "\n";}' > $extra_questions || exit 1;
  cat $nonsil_phones | perl -e 'while(<>){ foreach $p (split(" ", $_)) {
    $p =~ m:^([^\d]+)(\d*)$: || die "Bad phone $_"; $q{$2} .= "$p "; } } foreach $l (values %q) {print "$l\n";}' \
    >> $extra_questions || exit 1;
  echo "$(wc -l <$silence_phones) silence phones saved to: $silence_phones"
  echo "$(wc -l <$optional_silence) optional silence saved to: $optional_silence"
  echo "$(wc -l <$nonsil_phones) non-silence phones saved to: $nonsil_phones"
  echo "$(wc -l <$extra_questions) extra triphone clustering-related questions saved to: $extra_questions"
fi

if [ $stage -le 2 ]; then
  (echo '!SIL SIL'; echo '<SPOKEN_NOISE> SPN'; echo '<UNK> SPN'; ) |\
  cat - $lexicon_raw_nosil | sort | uniq >$dict_dir/lexicon.txt
  echo "Lexicon text file saved as: $dict_dir/lexicon.txt"
fi


if [ $stage -le 3 ]; then
  utils/prepare_lang.sh $dict_dir "<UNK>" data/local/lang_tmp_nosp data/lang_nosp

  # silphone=`cat $dict_dir/optional_silence.txt` || exit 1;
  # utils/lang/make_lexicon_fst_silprob.py $grammar_opts --sil-phone=$silphone \
  #        $tmpdir/lexiconp_silprob.txt $srcdir/silprob.txt | \
  #    fstcompile --isymbols=$dir/phones.txt --osymbols=$dir/words.txt \
  #      --keep_isymbols=false --keep_osymbols=false |   \
  #    fstarcsort --sort_type=olabel > $dir/L.fst || exit 1;
fi

