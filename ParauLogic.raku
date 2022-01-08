#!/usr/bin/env raku

sub MAIN( Str $lletres = '') {

  until ($lletres ~~ / <alpha> ** 7 /) and ($lletres.split('',:skip-empty).unique.elems == 7) {
    $lletres = prompt("\nEscriu les lletres del paraulògic,\namb la lletra del mig al final: ");
    say '*** Les lletres han de ser difernts' unless $lletres.split('',:skip-empty).unique.elems == 7; 
    say '*** Han de ser 7 lletres'            unless $lletres ~~ / <alpha> ** 7 /
  }

  # Diccionari de paraules
  my $file = '/usr/share/hunspell/ca_ES.dic';

  my @lletres = $lletres.split('',:skip-empty);
  my $lletra_mig  = @lletres[*-1];

  # Character classes for regex: 
  my $regex_lletres    = '<[' ~ $lletres.substr(0..5) ~ ']>';
  my $regex_no_lletres = '<[\w] - [' ~ $lletres ~ ']>';

  # Get permutations of combinations of letters
  my @perm = combinations(@lletres).map({ $_.join if $_.join.chars > 2 }).grep(/$lletra_mig/)
            .map({ 
               $_.split('', :skip-empty).permutations.map({ $_.join }).Slip 
            });

  for $file.IO.lines -> $line {
    # Match word or · and remove accents and ·
    my $word = $line.match(/ ( [ \w | \· ]+ ) /).lc.trans(
      'à'      => 'a', 
      /<[èé]>/ => 'e', 
      /<[íï]>/ => 'i', 
      /<[òó]>/ => 'o', 
      /<[úü]>/ => 'u', 
      '·'      => '' 
    ); 
    # next if $word contains digits or does not contain pattern
    next if     $word ~~ /\d/           or  $word ~~ / <$regex_no_lletres> /;
    # next unless word contains letter and word contains pattern
    next unless $word ~~ /$lletra_mig/  and $word ~~ /<$regex_lletres>/;
    # letters in the word should belong to the leters of the pattern
    next unless so $word.split('',:skip-empty).sort.map({ $_ ∈ @lletres.unique.sort }).all;

    # Change 'False' to 'True' to test word
    if False and ($word eq 'ampa') {
      say "\n Test: \n $line \n $word";
      exit;
    }

    print @perm.map( -> $x { $word if $word ~~ /$x/ }).unique.Str ~ ' ';
  }

}
