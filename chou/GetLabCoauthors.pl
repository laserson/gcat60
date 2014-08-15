# GetLabCoauthors.pl
# 07/22/2014 -- JA

$infile="Publications_Excerpt_Church_Lab.htm.txt";  # edited to remove parsing problems
@alsoget=("Kim SH","Gilbert W");
$pubs="";
open(I,$infile);
while(<I>){
  s/\s*\n$//;
  $pubs.=$_;
}
close I;
$pubs=~s/<\/[Pp]>//g;
@pubsects=split/\s*<[Pp]>\s*/,$pubs;
@PUBNUM=();
%YEARAUTH=();
for($i=0;$i<@pubsects;++$i){
  if($pubsects[$i]=~/^(\d+\S)\.?([^\(]+)\((\d+)\)/){
     $pubnum=$1;
     $authors=$2;
     $year=$3;
     $authors=~s/\t//g;
     if($PUBCHECK{$pubnum}ne""){ print "Duplicate pubnum $pubnum\n";}
     if($pubnum=~/^(\d+)(\S?)$/){
       $PUBNUMCHECK[$1]++;
     }
     @PUBNUM=($pubnum,@PUBNUM);  # store in reverse order, earliest to latest
     $YEARAUTH{$pubnum}="$year\t$authors";
   }
}
for($i=1;$i<=@PUBNUMCHECK;++$i){
  if($PUBNUMCHECK[$i]eq""){
     print STDERR "Missed publication $i\n";
  }
}
# Analyze for bolded authors
foreach $pubnum(@PUBNUM){
   ($year,$authors)=split/\t/,$YEARAUTH{$pubnum};
   $isGeorgeThere=0;
   @boldauth=();
   while($authors=~m/<[Bb]>\s*([^<]+)\s*<\/[Bb]>/g){
     $bauth=$1;
     @bauth=split/\s*,\s*/,$bauth;
     for($i=0;$i<@bauth;++$i){
       push @boldauth,$bauth[$i];
       if($bauth[$i]=~/^Church\s+G/){
         $isGeorgeThere=1;
       }
     }
   }
   for($i=0;$i<@alsoget;++$i){
     if($authors=~/$alsoget[$i]/){
        push @boldauth,$alsoget[$i];
     }
   }
   if($isGeorgeThere==0){
      @boldauth=(@boldauth,"Church, GM");
   }
   if(@boldauth>1){
      print (join"\t",($pubnum,$year,@boldauth));print"\n";
   }
   else{
      push @NOCOAUTHOR,$pubnum;
   }
}
$nocoauth=scalar @NOCOAUTHOR;
print STDERR "Publications not reported due to inability to detect lab co-authors: $nocoauth\nPublication numbers: ";
print STDERR (join ", ",@NOCOAUTHOR);print STDERR "\n";
