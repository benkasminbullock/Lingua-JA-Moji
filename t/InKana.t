use warnings;
use strict;
use Test::More tests => 6;
use Lingua::JA::Moji 'InKana';
use utf8;

my @kana = (qw/
                  あいうえおすごいわざきょうしつきょうじゅげげげのきゅうたろうたろー
                  アイウエオスゴイワザキョウシツキョウジュゲゲゲノキュウタロウタロー
                  ｱｲｳｴｵｽｺﾞｲﾜｻﾞｷｮｳｼﾂｷｮｳｼﾞｭｹﾞｹﾞｹﾞﾉｷｭｳﾀﾛｳﾀﾛｰ
              /);

for (@kana) {
    ok (/^\p{InKana}+$/, "matches");
}

my @not_kana = (qw/
！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［＼］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝～
ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ
abcdefg
/);

for (@not_kana) {
    ok (!/\p{InKana}/, "not matches InKana");
}

