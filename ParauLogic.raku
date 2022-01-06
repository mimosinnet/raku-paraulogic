#!/usr/bin/env raku

my $lletres = "";
until $lletres ~~ / <alpha> ** 7 / {
  $lletres = prompt("\nEscriu les lletres del paraulògic,\namb la lletra del mig al final: ");
}

# Diccionari de paraules
my $file = '/usr/share/hunspell/ca_ES.dic';

my @lletres = $lletres.split('',:skip-empty);
my $lletra_mig  = @lletres[*-1];

# Character classes for regex: 
my $regex_lletres    = '<[' ~ $lletres.substr(1..5) ~ ']>';
my $regex_no_lletres = '<[\w] - [' ~ $lletres ~ ']>';

# Get permutations of combinations of letters
my @perm = combinations(@lletres).map({ $_.join if $_.join.chars > 2 }).grep(/$lletra_mig/)
          .map({ 
             $_.split('', :skip-empty).permutations.map({ $_.join }).Slip 
          });

for $file.IO.lines -> $line {
  $line ~~ / (\w+).* /;
  my $word = $0.Str.lc;
  # remove accents
  $word = $word.trans( /<[èé]>/ => 'e', /<[òó]>/ => 'o', 'à' => 'a', 'í' => 'i', 'ú' => 'u' ); 
  # next if $word contains digits or does not contain pattern
  next if     $word ~~ /\d/           or  $word ~~ / <$regex_no_lletres> /;
  # next unless word contains letter and word contains pattern
  next unless $word ~~ /$lletra_mig/  and $word ~~ /<$regex_lletres>/;
  # letters in the word should belong to the lleters of the pattern
  next unless so $word.split('',:skip-empty).sort.map({ $_ ∈ @lletres.unique.sort }).all;

  print @perm.map( -> $x { $word if $word ~~ /$x/ }).unique.Str ~ ' ';
}
